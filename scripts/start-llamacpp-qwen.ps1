param(
  [string]$Model = "Qwen/Qwen3-0.6B-GGUF:Q8_0",
  [int]$Port = 8080,
  [string]$HostAddress = "127.0.0.1",
  [int]$ContextSize = 4096
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$server = Join-Path $repoRoot "tools\llama.cpp\llama-server.exe"
$stateDir = Join-Path $repoRoot "state"
$logDir = Join-Path $repoRoot "logs"
$pidPath = Join-Path $stateDir "llama-server.pid"
$stdoutPath = Join-Path $logDir "llama-server.out.log"
$stderrPath = Join-Path $logDir "llama-server.err.log"

if (-not (Test-Path $server)) {
  throw "llama-server.exe not found at $server. Install llama.cpp first."
}

New-Item -ItemType Directory -Force -Path $stateDir, $logDir | Out-Null

if (Test-Path $pidPath) {
  $oldPid = Get-Content -LiteralPath $pidPath -ErrorAction SilentlyContinue
  if ($oldPid -and (Get-Process -Id $oldPid -ErrorAction SilentlyContinue)) {
    Write-Host "llama-server already running with PID $oldPid"
    Write-Host "Base URL: http://$HostAddress`:$Port/v1"
    exit 0
  }
}

$args = @(
  "-hf", $Model,
  "--host", $HostAddress,
  "--port", "$Port",
  "-c", "$ContextSize"
)

$process = Start-Process -FilePath $server -ArgumentList $args -PassThru -WindowStyle Hidden -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
$process.Id | Set-Content -LiteralPath $pidPath

Write-Host "Started llama-server PID $($process.Id)"
Write-Host "Model: $Model"
Write-Host "Base URL: http://$HostAddress`:$Port/v1"
Write-Host "Stdout log: $stdoutPath"
Write-Host "Stderr log: $stderrPath"
