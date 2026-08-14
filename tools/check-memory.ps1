param(
    [string]$MapPath = "bin/PORTAL3D.map",
    [string]$ObjectPath = "obj",
    [int]$MaximumBytes = 153600,
    [int]$ReservedStackBytes = 8192
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $MapPath)) {
    throw "Linker map not found at '$MapPath'. Build the project with CEdev first."
}

$largestSections = @{
    ".header" = 0
    ".init" = 0
    ".text" = 0
    ".rodata" = 0
    ".data" = 0
    ".bss" = 0
}

foreach ($line in Get-Content -LiteralPath $MapPath) {
    if ($line -match '^\.(header|init|text|rodata|data|bss)\s+0x[0-9a-fA-F]+\s+0x([0-9a-fA-F]+)') {
        $name = "." + $Matches[1]
        $size = [Convert]::ToInt32($Matches[2], 16)
        if ($size -gt $largestSections[$name]) {
            $largestSections[$name] = $size
        }
    } elseif ($line -match '^\.(header|init|text|rodata|data|bss)\s+\$[0-9a-fA-F]+\s+\$([0-9a-fA-F]+)') {
        $name = "." + $Matches[1]
        $size = [Convert]::ToInt32($Matches[2], 16)
        if ($size -gt $largestSections[$name]) {
            $largestSections[$name] = $size
        }
    }
}

if ($largestSections[".text"] -eq 0 -or $largestSections[".bss"] -eq 0) {
    throw "No top-level .text or .bss sizes were recognized in '$MapPath'. Update the parser for this linker-map format."
}

$largestFrame = 0
$largestFrameSource = "not reported"
if (Test-Path -LiteralPath $ObjectPath) {
    foreach ($usageFile in Get-ChildItem -LiteralPath $ObjectPath -Recurse -Filter "*.su" -ErrorAction SilentlyContinue) {
        foreach ($line in Get-Content -LiteralPath $usageFile.FullName) {
            if ($line -match '\t([0-9]+)\t') {
                $frame = [int]$Matches[1]
                if ($frame -gt $largestFrame) {
                    $largestFrame = $frame
                    $largestFrameSource = $line
                }
            }
        }
    }
}

$residentProgramBytes = $largestSections[".header"] +
    $largestSections[".init"] +
    $largestSections[".text"] +
    $largestSections[".rodata"] +
    $largestSections[".data"]
$mutableBytes = $largestSections[".bss"]
$budgetedBytes = $residentProgramBytes + $mutableBytes + $ReservedStackBytes

Write-Output ("resident program:   {0,6} bytes" -f $residentProgramBytes)
Write-Output ("  .header:           {0,6} bytes" -f $largestSections[".header"])
Write-Output ("  .init:             {0,6} bytes" -f $largestSections[".init"])
Write-Output ("  .text:             {0,6} bytes" -f $largestSections[".text"])
Write-Output ("  .rodata:           {0,6} bytes" -f $largestSections[".rodata"])
Write-Output ("  .data:             {0,6} bytes" -f $largestSections[".data"])
Write-Output (".bss:                {0,6} bytes" -f $largestSections[".bss"])
Write-Output ("reserved stack:     {0,6} bytes" -f $ReservedStackBytes)
Write-Output ("budgeted RAM total: {0,6} bytes" -f $budgetedBytes)
Write-Output ("RAM limit:          {0,6} bytes" -f $MaximumBytes)
Write-Output ("largest stack frame: {0} bytes ({1})" -f $largestFrame, $largestFrameSource)

if ($budgetedBytes -gt $MaximumBytes) {
    throw "RAM budget exceeded by $($budgetedBytes - $MaximumBytes) bytes."
}

Write-Output ("PASS: {0} bytes remain in the RAM budget." -f ($MaximumBytes - $budgetedBytes))
