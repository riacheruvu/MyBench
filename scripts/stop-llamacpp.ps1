$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$pidPath = Join-Path $repoRoot "state\llama-server.pid"

if (-not (Test-Path $pidPath)) {
  Write-Host "No llama-server pid file found."
  exit 0
}

$pidValue = Get-Content -LiteralPath $pidPath -ErrorAction SilentlyContinue
if ($pidValue -and (Get-Process -Id $pidValue -ErrorAction SilentlyContinue)) {
  Stop-Process -Id $pidValue -Force
  Write-Host "Stopped llama-server PID $pidValue"
} else {
  Write-Host "llama-server PID $pidValue is not running."
}

Remove-Item -LiteralPath $pidPath -Force -ErrorAction SilentlyContinue
