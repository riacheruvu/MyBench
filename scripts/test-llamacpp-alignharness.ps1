param(
  [int]$Port = 8080
)

$ErrorActionPreference = "Stop"

$env:ALIGNHARNESS_PROVIDER = "llamacpp"
$env:ALIGNHARNESS_LLAMACPP_URL = "http://127.0.0.1:$Port"
$env:ALIGNHARNESS_NO_THINK = "1"

node skills\alignharness\scripts\run-profile.mjs `
  --profile examples\public-agent-profile.yaml `
  --case-file examples\public-agent-cases.json `
  --prompt-file examples\public-agent-system-prompt.txt `
  --cases 1 `
  --repeat 1
