const int Fixed = 256;
const int ProjectedLimit = 1 << 20;

int FloorQ8(int value) => value >= 0 ? value / Fixed : -((-value + Fixed - 1) / Fixed);
int CeilQ8(int value) => value >= 0 ? (value + Fixed - 1) / Fixed : -((-value) / Fixed);
int ClampProjected(int value) => Math.Clamp(value, -ProjectedLimit, ProjectedLimit);
int Int24(int value)
{
    value &= 0xFFFFFF;
    return (value & 0x800000) != 0 ? value - 0x1000000 : value;
}

int EdgeStep(int dx, int dy)
{
    int index = (dy + 8) >> 4;
    if (dy < Fixed || index >= 2048 || dx > 32767 || dx < -32767)
        return unchecked(dx * Fixed) / dy;
    int denominator = index << 4;
    int reciprocal = ((1 << 20) + denominator / 2) / denominator;
    reciprocal = Math.Min(reciprocal, 65535);
    return unchecked(dx * reciprocal) >> 12;
}

Bounds? GetBounds(Pt[] points, Layer layer)
{
    int step = 1 << layer.Shift;
    int origin = step >> 1;
    int minimumY = points.Min(p => p.Y);
    int maximumY = points.Max(p => p.Y);
    int first = CeilQ8(minimumY - Fixed / 2);
    int last = FloorQ8(maximumY - 1 - Fixed / 2);
    if (layer.Shift == 0)
    {
        first = Math.Max(first, layer.First);
        last = Math.Min(last, layer.Last);
    }
    else
    {
        int clipFirst = (layer.First >> layer.Shift) * step + origin;
        int clipLast = (layer.Last >> layer.Shift) * step + origin;
        first = Math.Max(first, clipFirst);
        last = Math.Min(last, clipLast);
    }
    first = Math.Max(first, 0);
    last = Math.Min(last, layer.Height - 1);
    if (first <= origin) first = origin;
    else first = origin + (((first - origin + step - 1) >> layer.Shift) << layer.Shift);
    if (last < origin) return null;
    last = origin + (((last - origin) >> layer.Shift) << layer.Shift);
    return first <= last ? new Bounds(step, first, last) : null;
}

(byte Left, byte Right) FinishSpan(int left, int right, int width)
{
    int first = CeilQ8(ClampProjected(left) - Fixed / 2);
    int last = FloorQ8(ClampProjected(right) - Fixed / 2);
    first = Math.Max(first, 0);
    last = Math.Min(last, width - 1);
    return first <= last ? ((byte)first, (byte)last) : ((byte)255, (byte)0);
}

Result Reference(Pt[] points, Layer layer)
{
    Bounds? optional = GetBounds(points, layer);
    if (optional is null) return Result.Empty;
    Bounds bounds = optional.Value;
    int[] left = Enumerable.Repeat(ProjectedLimit + 1, layer.Height).ToArray();
    int[] right = Enumerable.Repeat(-ProjectedLimit - 1, layer.Height).ToArray();
    for (int index = 0; index < points.Length; ++index)
    {
        Pt a = points[index];
        Pt b = points[(index + 1) % points.Length];
        if (a.Y == b.Y) continue;
        if (a.Y > b.Y) (a, b) = (b, a);
        int edgeFirst = Math.Max(CeilQ8(a.Y - Fixed / 2), bounds.First);
        int edgeLast = Math.Min(FloorQ8(b.Y - 1 - Fixed / 2), bounds.Last);
        int origin = bounds.Step >> 1;
        if (edgeFirst <= origin) edgeFirst = origin;
        else edgeFirst = origin + (((edgeFirst - origin + bounds.Step - 1) >> layer.Shift) << layer.Shift);
        if (edgeFirst > edgeLast) continue;
        int xStep = EdgeStep(b.X - a.X, b.Y - a.Y);
        int x = unchecked(a.X + ((xStep * (edgeFirst * Fixed + Fixed / 2 - a.Y)) >> 8));
        for (int row = edgeFirst; row <= edgeLast; row += bounds.Step)
        {
            if (x < left[row]) left[row] = ClampProjected(x);
            if (x > right[row]) right[row] = ClampProjected(x);
            if (row + bounds.Step <= edgeLast) x = unchecked(x + xStep * bounds.Step);
        }
    }
    return FinishResult(bounds, layer, left, right);
}

Result FinishResult(Bounds bounds, Layer layer, int[] left, int[] right)
{
    byte[] spanLeft = Enumerable.Repeat((byte)255, layer.Height).ToArray();
    byte[] spanRight = new byte[layer.Height];
    bool any = false;
    for (int row = bounds.First; row <= bounds.Last; row += bounds.Step)
    {
        if (left[row] == ProjectedLimit + 1) continue;
        (spanLeft[row], spanRight[row]) = FinishSpan(left[row], right[row], layer.Width);
        if (spanLeft[row] <= spanRight[row] &&
            (layer.Shift != 0 || (row >= layer.First && row <= layer.Last &&
             spanRight[row] >= layer.RowLeft[row] && spanLeft[row] <= layer.RowRight[row])))
            any = true;
    }
    return new Result(any, bounds.First, bounds.Last, spanLeft, spanRight, false);
}

bool BeginChain(Pt[] points, Chain chain, int row, int step)
{
    while (chain.EdgesLeft != 0)
    {
        Pt a = points[chain.Vertex];
        int next;
        if (chain.Direction > 0)
        {
            next = chain.Vertex + 1;
            if (next == points.Length) next = 0;
        }
        else next = chain.Vertex == 0 ? points.Length - 1 : chain.Vertex - 1;
        chain.Vertex = next;
        --chain.EdgesLeft;
        Pt b = points[next];
        if (a.Y == b.Y) continue;
        if (a.Y > b.Y) return false;
        int first = CeilQ8(a.Y - Fixed / 2);
        int last = FloorQ8(b.Y - 1 - Fixed / 2);
        if (last < row) continue;
        if (first > row) return false;
        int xStep = EdgeStep(b.X - a.X, b.Y - a.Y);
        chain.Last = last;
        chain.X = Int24(unchecked(a.X + ((xStep * (row * Fixed + Fixed / 2 - a.Y)) >> 8)));
        chain.Advance = Int24(unchecked(xStep * step));
        return true;
    }
    return false;
}

Result Candidate(Pt[] points, Layer layer)
{
    Bounds? optional = GetBounds(points, layer);
    if (optional is null) return Result.Empty;
    Bounds bounds = optional.Value;
    int top = 0;
    for (int index = 1; index < points.Length; ++index)
        if (points[index].Y < points[top].Y) top = index;
    Chain first = new(top, 1, points.Length);
    Chain second = new(top, -1, points.Length);
    if (!BeginChain(points, first, bounds.First, bounds.Step) ||
        !BeginChain(points, second, bounds.First, bounds.Step))
        return Result.Failed;
    int[] left = new int[layer.Height];
    int[] right = new int[layer.Height];
    for (int row = bounds.First; row <= bounds.Last; row += bounds.Step)
    {
        if (row > first.Last && !BeginChain(points, first, row, bounds.Step)) return Result.Failed;
        if (row > second.Last && !BeginChain(points, second, row, bounds.Step)) return Result.Failed;
        left[row] = first.X;
        right[row] = second.X;
        if (left[row] > right[row]) (left[row], right[row]) = (right[row], left[row]);
        if (row + bounds.Step <= first.Last) first.X = Int24(unchecked(first.X + first.Advance));
        if (row + bounds.Step <= second.Last) second.X = Int24(unchecked(second.X + second.Advance));
    }
    return FinishResult(bounds, layer, left, right);
}

long Cross(Pt origin, Pt a, Pt b) =>
    (long)(a.X - origin.X) * (b.Y - origin.Y) - (long)(a.Y - origin.Y) * (b.X - origin.X);

Pt[] Hull(IEnumerable<Pt> source)
{
    Pt[] points = source.Distinct().OrderBy(p => p.X).ThenBy(p => p.Y).ToArray();
    if (points.Length < 3) return [];
    List<Pt> lower = [];
    foreach (Pt point in points)
    {
        while (lower.Count >= 2 && Cross(lower[^2], lower[^1], point) <= 0) lower.RemoveAt(lower.Count - 1);
        lower.Add(point);
    }
    List<Pt> upper = [];
    foreach (Pt point in points.Reverse())
    {
        while (upper.Count >= 2 && Cross(upper[^2], upper[^1], point) <= 0) upper.RemoveAt(upper.Count - 1);
        upper.Add(point);
    }
    lower.RemoveAt(lower.Count - 1);
    upper.RemoveAt(upper.Count - 1);
    return lower.Concat(upper).ToArray();
}

Pt Project(Vec3 point, int shift)
{
    int index;
    int scale;
    if (point.Z >= 2048 << 2)
    {
        index = Math.Min(point.Z >> 5, 2047);
        scale = (42 * Fixed * 64) / (index << 5);
    }
    else
    {
        index = Math.Clamp(point.Z >> 2, 1, 2047);
        scale = index < (32 >> 2) ? 65535 : (42 * Fixed * 64) / (index << 2);
    }
    int x = ClampProjected(32 * Fixed + unchecked((point.X * scale) >> 6));
    int y = ClampProjected(24 * Fixed - unchecked((point.Y * scale) >> 6));
    return new(x >> shift, y >> shift);
}

Vec3 NearIntersection(Vec3 first, Vec3 second)
{
    Vec3 lower = first.Z <= second.Z ? first : second;
    Vec3 upper = first.Z <= second.Z ? second : first;
    int delta = upper.Z - lower.Z;
    int fraction = (((32 - lower.Z) << 14) + delta / 2) / delta;
    return new(
        lower.X + (((upper.X - lower.X) * fraction) >> 14),
        lower.Y + (((upper.Y - lower.Y) * fraction) >> 14), 32);
}

Pt[] ClipAndProject(Vec3[] source, int shift)
{
    List<Vec3> output = [];
    for (int index = 0; index < source.Length; ++index)
    {
        Vec3 current = source[index];
        Vec3 previous = source[(index + source.Length - 1) % source.Length];
        bool currentInside = current.Z >= 32;
        bool previousInside = previous.Z >= 32;
        if (currentInside != previousInside) output.Add(NearIntersection(previous, current));
        if (currentInside) output.Add(current);
    }
    return output.Count >= 3 ? output.Select(p => Project(p, shift)).ToArray() : [];
}

void Check(Pt[] source, Random random, int ordinal, string label, ref int checkedCount)
{
    if (source.Length is < 3 or > 8) return;
    Pt[] points = random.Next(2) == 0 ? source : source.Reverse().ToArray();
    int rotate = random.Next(points.Length);
    points = points.Skip(rotate).Concat(points.Take(rotate)).ToArray();
    int shift = random.Next(3);
    int width = 64;
    int height = 48;
    int first = random.Next(height);
    int last = random.Next(first, height);
    byte[] rowLeft = new byte[height];
    byte[] rowRight = new byte[height];
    for (int row = 0; row < height; ++row)
    {
        rowLeft[row] = (byte)random.Next(width);
        rowRight[row] = (byte)random.Next(rowLeft[row], width);
    }
    Layer layer = new(shift, first, last, width, height, rowLeft, rowRight);
    Result expected = Reference(points, layer);
    Result actual = Candidate(points, layer);
    if (!expected.Same(actual))
        throw new Exception($"{label} case {ordinal} mismatch\npoints={string.Join(';', points)}\n" +
            $"shift={shift} clip={first}..{last}\nexpected={expected}\nactual={actual}");
    ++checkedCount;
}

Random random = new(unchecked((int)0x3D202608));
int screenChecked = 0;
int nearChecked = 0;
for (int ordinal = 0; ordinal < 200_000; ++ordinal)
{
    int count = random.Next(3, 13);
    Pt[] hull = Hull(Enumerable.Range(0, count).Select(_ =>
        new Pt(random.Next(-96 * Fixed, 160 * Fixed), random.Next(-96 * Fixed, 144 * Fixed))));
    Check(hull, random, ordinal, "screen", ref screenChecked);
}
for (int ordinal = 0; ordinal < 100_000; ++ordinal)
{
    Vec3 center = new(random.Next(-2 * Fixed, 2 * Fixed), random.Next(-2 * Fixed, 2 * Fixed), random.Next(-Fixed, 7 * Fixed));
    Vec3 u = new(random.Next(Fixed / 4, 2 * Fixed), random.Next(-Fixed / 2, Fixed / 2), random.Next(-2 * Fixed, 2 * Fixed));
    Vec3 v = new(random.Next(-Fixed / 2, Fixed / 2), random.Next(Fixed / 4, 2 * Fixed), random.Next(-2 * Fixed, 2 * Fixed));
    Vec3[] quad = [center - u - v, center + u - v, center + u + v, center - u + v];
    Pt[] points = ClipAndProject(quad, random.Next(2));
    Pt[] hull = Hull(points);
    if (points.Length == points.Distinct().Count() && hull.Length == points.Length)
        Check(points, random, ordinal, "near", ref nearChecked);
}
Console.WriteLine($"PASS seed=0x3D202608 screen={screenChecked} near_clipped_or_projected={nearChecked} total={screenChecked + nearChecked}");

readonly record struct Pt(int X, int Y);
readonly record struct Vec3(int X, int Y, int Z)
{
    public static Vec3 operator +(Vec3 a, Vec3 b) => new(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
    public static Vec3 operator -(Vec3 a, Vec3 b) => new(a.X - b.X, a.Y - b.Y, a.Z - b.Z);
}
readonly record struct Bounds(int Step, int First, int Last);
readonly record struct Layer(int Shift, int First, int Last, int Width, int Height, byte[] RowLeft, byte[] RowRight);
sealed class Chain(int vertex, int direction, int edgesLeft)
{
    public int Vertex = vertex;
    public int Direction = direction;
    public int EdgesLeft = edgesLeft;
    public int Last;
    public int X;
    public int Advance;
}
sealed class Result(bool any, int first, int last, byte[] left, byte[] right, bool failed)
{
    readonly bool _any = any;
    readonly int _first = first;
    readonly int _last = last;
    readonly byte[] _left = left;
    readonly byte[] _right = right;
    readonly bool _failed = failed;
    public static Result Empty { get; } = new(false, -1, -1, [], [], false);
    public static Result Failed { get; } = new(false, -1, -1, [], [], true);
    public bool Same(Result other) =>
        _any == other._any && _first == other._first && _last == other._last && _failed == other._failed &&
        _left.SequenceEqual(other._left) && _right.SequenceEqual(other._right);
    public override string ToString() => $"any={_any}, rows={_first}..{_last}, failed={_failed}, " +
        string.Join(',', _left.Zip(_right).Select((span, row) => span.First <= span.Second ? $"{row}:{span.First}-{span.Second}" : ""));
}
