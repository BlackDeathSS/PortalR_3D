param(
    [int[]]$Resolutions = @(64, 80, 160),
    [int[]]$BodyLayouts = @(0, 1, 2),
    [string]$CEmuAutotester = "C:\CEdev\bin\cemu-autotester.exe",
    [string]$Python = "C:\Users\refiorlk_admin\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe",
    [switch]$SkipHardwarePackaging
)

$ErrorActionPreference = "Stop"
$t3d3Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$cemuDirectory = Join-Path $t3d3Root "tests\cemu"
$config = Join-Path $cemuDirectory "body_performance_autotest.json"
$dump = Join-Path $cemuDirectory "failure_hashresult_num1_dump.bin"
$decoder = (Resolve-Path (Join-Path $t3d3Root "..\true3d\tools\decode-live-benchmark.py")).Path
$engineHeader = Get-Content (Join-Path $t3d3Root "src\engine.h") -Raw
if ($engineHeader -notmatch 'TRUE3D_BUILD_VERSION\s+0x([0-9A-Fa-f]+)UL') {
    throw "Could not read TRUE3D_BUILD_VERSION from src/engine.h"
}
$resultRoot = Join-Path $t3d3Root "benchmark-results\resolution-$($Matches[1])"
$layoutNames = @{0 = "no-body"; 1 = "root-eight"; 2 = "portal-eight"}

foreach ($resolution in $Resolutions) {
    if ($resolution -notin @(64, 80, 160)) {
        throw "Unsupported logical width $resolution. Expected 64, 80, or 160."
    }
    $height = [int]($resolution * 3 / 4)
    foreach ($layout in $BodyLayouts) {
        if (-not $layoutNames.ContainsKey($layout)) {
            throw "Unsupported body layout $layout. Expected 0, 1, or 2."
        }
        $layoutName = $layoutNames[$layout]
        $outputDirectory = Join-Path $resultRoot "${resolution}x${height}\$layoutName"
        New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

        Write-Host "Building ${resolution}x${height} $layoutName"
        Push-Location $t3d3Root
        try {
            & make -B -j4 LIVE_BENCHMARK=1 LIVE_BENCHMARK_AUTOTEST=1 BODY_BENCHMARK=$layout RENDER_WIDTH=$resolution
            if ($LASTEXITCODE -ne 0) { throw "Build failed with exit code $LASTEXITCODE" }
            Copy-Item "bin\T3D3LVAT.8xp*" $outputDirectory -Force
        } finally {
            Pop-Location
        }

        $started = Get-Date
        Push-Location $cemuDirectory
        try {
            $cemuOutput = & $CEmuAutotester -d $config 2>&1
            $cemuOutput | Select-String "Autotest|Hash #result" | ForEach-Object { Write-Host $_.Line }
        } finally {
            Pop-Location
        }
        if (-not (Test-Path $dump)) { throw "CEmu did not produce $dump" }
        if ((Get-Item $dump).LastWriteTime -lt $started) {
            throw "CEmu dump was not refreshed for ${resolution}x${height} $layoutName"
        }

        & $Python $decoder $dump --output-dir $outputDirectory --prefix $layoutName
        if ($LASTEXITCODE -ne 0) { throw "Benchmark decode failed with exit code $LASTEXITCODE" }

        if (-not $SkipHardwarePackaging) {
            Write-Host "Packaging hardware benchmark ${resolution}x${height} $layoutName"
            Push-Location $t3d3Root
            try {
                & make -B -j4 LIVE_BENCHMARK=1 BODY_BENCHMARK=$layout RENDER_WIDTH=$resolution
                if ($LASTEXITCODE -ne 0) { throw "Hardware build failed with exit code $LASTEXITCODE" }
                Copy-Item "bin\T3D3LIVE.8xp*" $outputDirectory -Force
            } finally {
                Pop-Location
            }
        }
    }
}
