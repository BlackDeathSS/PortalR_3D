$ErrorActionPreference = 'Stop'
$editorRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$server = Join-Path $editorRoot 'server.py'
$bundledPython = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'

if (Test-Path -LiteralPath $bundledPython) {
    & $bundledPython $server
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 $server
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    & python $server
} else {
    throw 'Python 3 is required to run the build-enabled editor.'
}
