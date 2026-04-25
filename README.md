# MyBench

A personal AI benchmark that tests whether an AI setup actually matches your preferences, then helps improve it when it misses. The project started as a way to capture the small but real frictions of daily AI use: outputs that feel off, prompt setups that never quite stick, and the manual workaround loop that follows.

This repo is now packaged as a Docker-first OpenClaw workspace, with the actual skill living at [skills/mybench/SKILL.md](./skills/mybench/SKILL.md). The OpenClaw gateway runs in Docker, and agent tool execution runs in separate Docker sandbox containers.

## What it does

1. Takes your preference in plain English, such as `warm emails` or `concise code explanations`.
2. Generates discriminating test prompts for that preference.
3. Runs them against a default assistant and a custom prompt/config.
4. Scores each pair with an impartial judge.
5. Reports where the custom setup lost.
6. Suggests a better prompt when the benchmark path includes improvement analysis.

## What changed

- Converted the prototype into a real OpenClaw workspace skill.
- Added a Docker Compose setup that builds a gateway image with Docker CLI support and a separate sandbox image.
- Hardened the benchmark runner so it handles parsing, CLI args, missing env, API calls, and judge bias more cleanly.
- Added a local-model path for sandboxed benchmarking.
- Removed the external Node SDK dependency so the benchmark can run inside the sandbox image without an install step.

## Repo layout

```text
.
|- docker-compose.yml
|- .env.example
|- docker/
|  |- gateway.Dockerfile
|  |- sandbox.Dockerfile
|  \- start-openclaw.sh
|- skills/
|  \- mybench/
|     |- SKILL.md
|     \- scripts/
|        |- run-mybench-local.py
|        \- run-mybench.mjs
|- anthropic-ai-sdk-0.39.0.tgz
```

## Quick start

1. Create `.env` from `.env.example`.
   The default local setup uses `MYBENCH_PROVIDER=local` with `HuggingFaceTB/SmolLM2-135M-Instruct` and `MYBENCH_LOCAL_FAST=1`, so API keys are optional unless you want a hosted provider fallback.
2. Build the gateway image and the sandbox image:

   ```powershell
   docker compose build
   ```

3. Start OpenClaw:

   ```powershell
   docker compose up -d openclaw-gateway
   ```

4. Open `http://127.0.0.1:18789/`.
5. Finish onboarding if needed:

   ```powershell
   docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js onboard --mode local --no-install-daemon
   ```

Because this repo is mounted as the OpenClaw workspace, the skill will be available from `workspace/skills/mybench`.

## Example commands

```text
benchmark warm and friendly email replies
mybench concise technical explanations for non-engineers
mybench patient and encouraging coding help with prompt "You are a patient coding mentor who celebrates small wins"
```

## Sandboxing model

- `openclaw-gateway` is containerized.
- Agent tools run in sibling Docker sandbox containers, not on the host.
- Sandbox mode is set to `all`, so every session is sandboxed.
- `workspaceAccess` is set to `none`, which avoids Docker-out-of-Docker host-path mapping problems and keeps tool execution away from the host workspace.
- The sandbox image can run either the Node benchmark path or the local Python model path.

This is the practical "everything in Docker" version OpenClaw supports: the gateway is in one container, and each agent session runs tools in separate sandbox containers.

## Useful commands

Check gateway health:

```powershell
docker compose run --rm -T openclaw-cli gateway probe
```

Print the dashboard URL again:

```powershell
docker compose run --rm -T openclaw-cli dashboard --no-open
```

Inspect sandbox containers:

```powershell
docker ps --filter "ancestor=mybench-openclaw-sandbox:local"
```

## Notes

- The gateway image is built from `ghcr.io/openclaw/openclaw:2026.4.19-beta.2-slim`, which was the latest published GHCR image on April 24, 2026.
- The Docker setup defaults `OPENCLAW_DISABLE_BONJOUR=1` to avoid the recent headless Docker CPU issue reported against OpenClaw v2026.4.8 and later.
- The gateway container mounts `/var/run/docker.sock` so it can create sibling sandbox containers. That is required for Docker-backed OpenClaw sandboxing.
- The skill runner supports a local Hugging Face model path as well as optional `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` hosted-provider fallbacks.
- Local CPU inference is functional but still slow enough that a production-ready local path likely wants a faster inference backend or more aggressive caching.
- This setup assumes Docker Desktop is running Linux containers.
