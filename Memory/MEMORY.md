---
title: "MEMORY"
summary: "Key decisions, lessons learned, active projects, and important facts — updated automatically over time"
read_when:
  - Start of every session
---

# MEMORY.md - What I Know So Far

_This file is updated automatically as we work together. Keep it concise — it's loaded into every conversation._

## Active Projects

_Nothing tracked yet._

## Key Decisions

- Decided to use consolidate.sh + claude --print (Haiku) for auto-extracting long-lived facts from daily logs into MEMORY.md. Triggered at PreCompact time and via daily cron.

## Lessons Learned

_Nothing recorded yet._

## Important Facts

- Nothing Recorded yet

## Tooling & Integrations

### Nano Banana (Image Generation)
- **Skill file:** `.claude/skills/nano-banana/SKILL.md` — invoke via `/nano-banana` or automatically when image generation is needed
- **How it works:** Uses `gemini` CLI (v0.37.0) + nanobanana extension at `~/.gemini/extensions/nanobanana/`
- **API key:** `GEMINI_API_KEY` stored in `.env` (gitignored), auto-loaded at session start via `session-start.sh`
- **Billing:** Google Cloud billing must be enabled on the project tied to the API key (free tier quota is too low)
- **Output:** Extension hardcodes output to `nanobanana-output/` (can't be changed without rebuilding) — SKILL.md moves files to `Content/images/` after generation
- **Model:** Default is `gemini-2.5-flash-image`; set `NANOBANANA_MODEL` env var to override
