---
name: alignharness
description: Benchmark whether an AI setup matches a user preference by generating test prompts, comparing a default response against a custom prompt, and proposing an improved system prompt when the custom setup loses.
metadata: {"openclaw":{"requires":{"bins":["node","python3"]}},"codex":{"requires":{"bins":["node","python3"]}}}
---

# AlignHarness

Use this skill when the user wants to test whether an AI actually behaves the way they prefer, or wants to compare a default assistant against a custom system prompt.

## Agent surfaces

- In Codex, install this folder to `~/.codex/skills/alignharness` or run `scripts/install-codex-skill.ps1` from this skill directory on Windows.
- In Claude Code, use the repo slash command at `.claude/commands/alignharness.md`.
- In OpenClaw, keep using this same `skills/alignharness` folder as the workspace skill.
- Keep all agent surfaces pointed at the same runners: `scripts/run-alignharness.mjs` for single-intent checks and `scripts/run-profile.mjs` for the full preference profile.

## Provider options

| Provider | How it works | When to use |
|---|---|---|
| `local` | llama-cpp-python loads a GGUF file directly | No server, offline, laptop-friendly |
| `llamacpp` | Node runner calls an OpenAI-compatible `/v1/chat/completions` API | llama.cpp server, Ollama/vLLM, or remote hosted endpoint |
| `openai` | OpenAI API | Cloud, best quality |
| `anthropic` | Anthropic API | Cloud, best quality |

## Quick start (local GGUF, no Docker needed)

```bash
pip install llama-cpp-python
export ALIGNHARNESS_GGUF_PATH=~/models/phi-3-mini-4k-instruct-q4.gguf
python3 "{baseDir}/scripts/run-alignharness-local.py" --intent "concise technical explanations"
```

## Quick start (llama.cpp server)

```bash
# Terminal 1 - start the server
llama-server -m ~/models/phi-3-mini-4k-instruct-q4.gguf --port 8080

# Terminal 2 - run the benchmark
ALIGNHARNESS_PROVIDER=llamacpp node "{baseDir}/scripts/run-alignharness.mjs" --intent "warm email replies"
```

## Workflow

1. Confirm the benchmark intent in a short phrase such as `warm and friendly email replies` or `concise technical explanations for non-engineers`.
2. For profile runs, start with `run-profile.mjs --validate-profile`; for model runs, use `--smoke-test` when provider connectivity is uncertain.
3. If the user supplied a custom system prompt, pass it with `--prompt` for short prompts or `--prompt-file` for multiline prompts.
4. Run the benchmark using one of the commands above.
5. Summarize the result with the score breakdown, verdict, main failure modes, and improved prompt if one was generated.
6. For serious profile comparisons, prefer `--judge-provider` / `--judge-model`, `--repeat N`, and `--save-report`.

## Commands

Short custom prompt:

```bash
python3 "{baseDir}/scripts/run-alignharness-local.py" --intent "friendly support replies" --prompt "You are warm, brief, and practical."
```

Prompt from file:

```bash
python3 "{baseDir}/scripts/run-alignharness-local.py" --intent "patient coding help" --prompt-file "/path/to/prompt.txt"
```

Node runner with llamacpp server:

```bash
ALIGNHARNESS_PROVIDER=llamacpp node "{baseDir}/scripts/run-alignharness.mjs" --intent "warm emails" --json
```

Full profile with a separate judge and saved report:

```bash
node "{baseDir}/scripts/run-profile.mjs" --cases 3 --repeat 3 --judge-provider openai --judge-model gpt-4.1-mini --save-report --improve
```

Profile parser check without model calls:

```bash
node "{baseDir}/scripts/run-profile.mjs" --validate-profile
```

Compare model versions:

```bash
node "{baseDir}/scripts/compare-models.mjs" --provider openai --models "gpt-5.5,gpt-5.4,gpt-5.4-mini" --profile preferences.yaml --cases 3 --repeat 3 --judge-provider openai --judge-model gpt-5.5
```

Run a profile with real seeded user-research cases:

```bash
node "{baseDir}/scripts/run-profile.mjs" --profile examples/public-agent-profile.yaml --case-file examples/public-agent-cases.json --prompt-file examples/public-agent-system-prompt.txt --cases 2 --repeat 3 --save-report
```

Compare prompt/memory/skill config candidates:

```bash
node "{baseDir}/scripts/compare-configs.mjs" --config-dir examples/config-candidates --profile examples/public-agent-profile.yaml --case-file examples/public-agent-cases.json --cases 2 --repeat 3
```

Run an iterative self-improvement loop:

```bash
node "{baseDir}/scripts/optimize-config.mjs" --profile examples/public-agent-profile.yaml --case-file examples/public-agent-cases.json --prompt-file examples/config-candidates/generic-supportive.txt --iterations 3 --cases 2 --repeat 2
```

Run the literature-backed complex user preference profile:

```bash
node "{baseDir}/scripts/run-profile.mjs" --profile examples/literature-backed-user-preferences.yaml --case-file examples/literature-backed-user-cases.json --prompt-file examples/complex-use-case-system-prompt.txt --cases 2 --repeat 3 --judge-provider openai --judge-model gpt-5.5 --save-report
```

Compare OSS models through Ollama or another OpenAI-compatible local router:

```bash
ALIGNHARNESS_PROVIDER=llamacpp ALIGNHARNESS_LLAMACPP_URL=http://127.0.0.1:11434/v1 node "{baseDir}/scripts/compare-models.mjs" --provider llamacpp --models "qwen3:8b,llama3.1:8b,gemma3:12b" --profile examples/public-agent-profile.yaml --case-file examples/public-agent-cases.json --prompt-file examples/public-agent-system-prompt.txt --cases 2 --repeat 3
```

## Guardrails

- For the local path, `ALIGNHARNESS_GGUF_PATH` must point to a valid GGUF file. Good options: Phi-3-mini Q4, Llama-3.2-3B Q4_K_M, Mistral-7B Q4_K_M.
- For the llamacpp server path, `llama-server` must be running before calling the Node runner.
- For hosted OpenAI-compatible endpoints through `llamacpp`, set `ALIGNHARNESS_LLAMACPP_API_KEY` if the endpoint requires a bearer token. For native hosted providers, set `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`.
- Prefer a separate judge provider/model for serious profile runs so one model is not generating cases, answering, and judging itself.
- Use `--repeat N` when comparing close prompts; report mean/stdev instead of trusting a tiny single run.
- Use `--improve` after profile runs to analyze losses and generate a revised system prompt; rerun the benchmark against that revised prompt before treating it as better.
- Use `compare-models.mjs` for model-version comparisons; rank primarily by candidate rubric score, not only A/B win rate, because A/B mode was originally designed for prompt comparisons.
- Use `compare-configs.mjs` to compare system prompts, memory summaries, skill instructions, or bundled config variants. Treat each candidate file as the assembled config shown to the model.
- Use `optimize-config.mjs` for a loop: benchmark, analyze losses, write an improved config, rerun. Use a reliable judge; tiny local models may fail JSON scoring.
- Use `--case-file` with a JSON object keyed by preference id or type when real user interactions are available; seeded cases are more stable than generated cases for regression tests.
- For OSS models, prefer an OpenAI-compatible router: Ollama at `http://127.0.0.1:11434/v1`, llama.cpp at `http://127.0.0.1:8080`, LM Studio/vLLM/SGLang/TGI as configured. Use `examples/oss-model-presets.json` as editable starting points.
- For demos meant to convince someone else, use the literature-backed profile plus a strong separate judge. The local 0.6B Qwen model is good for privacy-preserving plumbing tests, not reliable judging.
- Docker is optional - both runners work without it. Use Docker when you want sandboxed tool execution via OpenClaw.
- Keep the benchmark size modest unless the user explicitly asks for more cases.
