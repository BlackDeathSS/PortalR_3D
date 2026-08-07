param()

$ErrorActionPreference = 'Stop'
$Width = 320
$Height = 240
$HudColor = 12

$engineSource = Get-Content -Raw -LiteralPath (
    Join-Path $PSScriptRoot '..\src\engine.c'
)
$fontMatch = [regex]::Match(
    $engineSource,
    '(?s)hud_glyph_rows\[5\]\[HUD_GLYPH_COUNT\]\s*=\s*\{(.*?)\n\};'
)
if (-not $fontMatch.Success) { throw 'Could not locate the candidate HUD font.' }
$rowMatches = [regex]::Matches($fontMatch.Groups[1].Value, '\{([^}]*)\}')
if ($rowMatches.Count -ne 5) {
    throw "Expected 5 candidate glyph rows, found $($rowMatches.Count)."
}
$fontRows = foreach ($rowMatch in $rowMatches) {
    $values = [regex]::Matches($rowMatch.Groups[1].Value, '\d+') | ForEach-Object {
        [byte]$_.Value
    }
    if ($values.Count -ne 21) {
        throw "Expected 21 values in a glyph row, found $($values.Count)."
    }
    ,([byte[]]$values)
}
$glyphs = for ($glyph = 0; $glyph -lt 21; ++$glyph) {
    ,([byte[]]@(
        $fontRows[0][$glyph], $fontRows[1][$glyph], $fontRows[2][$glyph],
        $fontRows[3][$glyph], $fontRows[4][$glyph]
    ))
}

$F = 0; $P = 1; $S = 2; $R = 3; $E = 4; $C = 5; $A = 6; $M = 7
$Space = 8; $Dash = 9; $Dot = 10; $Digit0 = 11
$freecamGlyphs = [byte[]]@($F, $R, $E, $E, $C, $A, $M)

function Clear-Rectangle {
    param(
        [byte[]]$Frame,
        [int]$X,
        [int]$Y,
        [int]$RectangleWidth,
        [int]$RectangleHeight
    )
    if ($X -lt 0 -or $Y -lt 0 -or
        $X + $RectangleWidth -gt $Width -or
        $Y + $RectangleHeight -gt $Height) {
        throw 'Candidate rectangle exceeded framebuffer bounds.'
    }
    for ($row = $Y; $row -lt $Y + $RectangleHeight; ++$row) {
        $start = $row * $Width + $X
        [Array]::Clear($Frame, $start, $RectangleWidth)
    }
}

function Draw-Text {
    param([byte[]]$Frame, [int]$X, [byte[]]$GlyphIndices)
    foreach ($glyphIndex in $GlyphIndices) {
        if ($glyphIndex -ge $glyphs.Count) {
            throw "Glyph index $glyphIndex exceeded the font table."
        }
        for ($row = 0; $row -lt 5; ++$row) {
            $bits = $glyphs[$glyphIndex][$row]
            for ($column = 0; $column -lt 3; ++$column) {
                $Frame[(2 + $row) * $Width + $X + $column] = if (
                    ($bits -band (4 -shr $column)) -ne 0
                ) { $HudColor } else { 0 }
            }
        }
        $X += 4
    }
}

function Get-FpsGlyphs {
    param([uint16]$FpsTenths)
    $result = [Collections.Generic.List[byte]]::new()
    @($F, $P, $S, $Space) | ForEach-Object { $result.Add([byte]$_) }
    if ($FpsTenths -eq 0) {
        @($Dash, $Dash, $Dot, $Dash) | ForEach-Object { $result.Add([byte]$_) }
        return ,$result.ToArray()
    }

    $whole = [int][Math]::Floor($FpsTenths / 10)
    $digitCount = if ($whole -ge 100) { 3 } elseif ($whole -ge 10) { 2 } else { 1 }
    if ($digitCount -eq 3) {
        $whole %= 1000
        $result.Add([byte]($Digit0 + [Math]::Floor($whole / 100)))
    }
    if ($digitCount -ge 2) {
        $result.Add([byte]($Digit0 + [Math]::Floor($whole / 10) % 10))
    }
    $result.Add([byte]($Digit0 + $whole % 10))
    $result.Add([byte]$Dot)
    $result.Add([byte]($Digit0 + $FpsTenths % 10))
    return ,$result.ToArray()
}

function Convert-LabelToGlyphs {
    param([string]$Label)
    $map = @{
        'F' = $F; 'P' = $P; 'S' = $S; 'R' = $R; 'E' = $E
        'C' = $C; 'A' = $A; 'M' = $M; ' ' = $Space; '-' = $Dash
        '.' = $Dot; '0' = $Digit0; '1' = $Digit0 + 1; '2' = $Digit0 + 2
        '3' = $Digit0 + 3; '4' = $Digit0 + 4; '5' = $Digit0 + 5
        '6' = $Digit0 + 6; '7' = $Digit0 + 7; '8' = $Digit0 + 8
        '9' = $Digit0 + 9
    }
    return ,[byte[]]($Label.ToCharArray() | ForEach-Object { $map[[string]$_] })
}

function Draw-CandidateHud {
    param([byte[]]$Frame, [uint16]$FpsTenths, [bool]$DevMode)
    Clear-Rectangle $Frame 0 0 38 8
    if ($DevMode) { Clear-Rectangle $Frame 78 0 31 8 }
    Draw-Text $Frame 2 (Get-FpsGlyphs $FpsTenths)
    if ($DevMode) { Draw-Text $Frame 80 $freecamGlyphs }

    $centerX = [int]($Width / 2)
    $centerY = [int]($Height / 2)
    for ($x = $centerX - 2; $x -le $centerX + 2; ++$x) {
        $Frame[$centerY * $Width + $x] = $HudColor
    }
    for ($y = $centerY - 2; $y -le $centerY + 2; ++$y) {
        $Frame[$y * $Width + $centerX] = $HudColor
    }
}

$cases = @(
    @(0, $false, 'FPS --.-'), @(1, $false, 'FPS 0.1'),
    @(99, $false, 'FPS 9.9'), @(100, $false, 'FPS 10.0'),
    @(300, $false, 'FPS 30.0'), @(999, $true, 'FPS 99.9'),
    @(1000, $true, 'FPS 100.0'), @(9999, $true, 'FPS 999.9'),
    @(10000, $true, 'FPS 000.0'), @(65535, $true, 'FPS 553.5')
)
$hashes = [Collections.Generic.List[string]]::new()
$sha256 = [Security.Cryptography.SHA256]::Create()
$initialTemplate = New-Object byte[] ($Width * $Height)
$pattern = [byte[]](0..255)
for ($offset = 0; $offset -lt $initialTemplate.Length; $offset += $pattern.Length) {
    $length = [Math]::Min($pattern.Length, $initialTemplate.Length - $offset)
    [Buffer]::BlockCopy($pattern, 0, $initialTemplate, $offset, $length)
}
foreach ($case in $cases) {
    $fpsTenths = [uint16]$case[0]
    $devMode = [bool]$case[1]
    $expectedGlyphs = Convert-LabelToGlyphs ([string]$case[2])
    $candidateGlyphs = Get-FpsGlyphs $fpsTenths
    if (-not [Collections.StructuralComparisons]::StructuralEqualityComparer.Equals(
        $candidateGlyphs, $expectedGlyphs
    )) {
        throw "Incorrect text content for FPS=$fpsTenths."
    }
    $initial = [byte[]]$initialTemplate.Clone()
    $first = [byte[]]$initial.Clone()
    $second = [byte[]]$initial.Clone()
    Draw-CandidateHud $first $fpsTenths $devMode
    Draw-CandidateHud $second $fpsTenths $devMode
    if (-not [Collections.StructuralComparisons]::StructuralEqualityComparer.Equals(
        $first, $second
    )) {
        throw "Non-deterministic output for FPS=$fpsTenths dev=$devMode."
    }

    $outside = [byte[]]$first.Clone()
    for ($row = 0; $row -lt 8; ++$row) {
        [Buffer]::BlockCopy($initial, $row * $Width, $outside, $row * $Width, 38)
        if ($devMode) {
            [Buffer]::BlockCopy(
                $initial, $row * $Width + 78,
                $outside, $row * $Width + 78,
                31
            )
        }
    }
    for ($x = 158; $x -le 162; ++$x) {
        $outside[120 * $Width + $x] = $initial[120 * $Width + $x]
    }
    for ($y = 118; $y -le 122; ++$y) {
        $outside[$y * $Width + 160] = $initial[$y * $Width + 160]
    }
    if (-not [Collections.StructuralComparisons]::StructuralEqualityComparer.Equals(
        $outside, $initial
    )) {
        throw 'A scene pixel changed outside the allowed HUD bounds.'
    }
    $digest = $sha256.ComputeHash($first)
    $hashes.Add(([BitConverter]::ToString($digest, 0, 8) -replace '-', '').ToLowerInvariant())
}

Write-Output "direct HUD: $($cases.Count) bounds/determinism cases passed"
Write-Output "frame hashes: $($hashes -join ' ')"
Write-Output 'touched bounds: FPS=38x8 FREECAM=31x8 crosshair=9 unique pixels'
