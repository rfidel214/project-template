# {{PROJECT_NAME}} — {{SHORT_TAGLINE}}

> **This file is the single source of truth for all AI coding agents.** It is read natively by OpenCode, KiloCode, Codex, Cursor, Amp, Jules, and others. Claude Code reads CLAUDE.md, which points here. Do not duplicate instructions — edit this file only.

## Project Overview

{{2-4 sentence description: What does this project do? What problem does it solve? What makes it unique vs. competitors or alternatives?}}

**Domain:** {{domain.tld}}
**Current Phase:** {{e.g. "Phase 0 Validation", "v1 Alpha", "Production"}}
**Edition:** {{e.g. "Personal Edition first, then SaaS" / "Open source" / "Enterprise"}}

---

## Agent Memory Framework

This project uses a dual-layer memory system. Follow this protocol on every session start:

### Layer 1: Beads (Operational State)

Beads (`bd`) is the task tracker. It knows what work exists, what's blocked, what's ready, and what you're working on.

```bash
# SESSION START — always run these first, in order
bd dolt pull                      # Sync latest task state from DoltHub (REQUIRED before any work)
bd prime                          # ~80 lines of current project context

# FIND WORK
bd ready --json                   # Tasks with no open blockers, sorted by priority
bd show <id> --json               # Full task details and audit trail

# CLAIM AND WORK
bd update <id> --claim            # Atomically claim (sets assignee + in_progress)
bd update <id> --notes "COMPLETED: X. IN PROGRESS: Y. NEXT: Z"

# CREATE TASKS
bd create "Title" -t task -p 1 --json
bd create "Title" -t bug -p 0 --parent <epic-id> --json

# DEPENDENCIES
bd dep add <child> <parent>       # child is blocked by parent
bd dep tree <id>                  # Show dependency tree

# COMPLETE WORK
bd close <id> --reason "Done: description" --json

# SESSION END — always push
git pull --rebase && git push && git status
```

**Rules:**
- Always use `--json` flag for programmatic output
- Never use `bd edit` — it opens an interactive editor agents can't use
- P0 = critical, P1 = high, P2 = medium, P3 = low, P4 = deferred
- Always push before ending a session — unpushed work breaks coordination

### Layer 2: Open Brain (Knowledge & Decisions)

Open Brain is the institutional knowledge layer. It stores architectural decisions, research findings, and all context that explains WHY things are the way they are.

**When to query Open Brain:**
- Before making architectural decisions (search for prior decisions first)
- When a task references domain knowledge you don't have in context
- When you need PRD details, tech stack rationale, or competitive context
- Before recommending alternatives to established choices

**MCP Access:** Open Brain is available via MCP from any AI tool (Claude Code, OpenCode, KiloCode, Cursor, ChatGPT, Gemini).

**What to capture:** After significant decisions, completed research, or milestones — capture to Open Brain so future sessions have it.

### Lookup Order

1. `bd dolt pull` → sync task state from DoltHub (always first)
2. `bd prime` → current task state
3. `bd ready` → pick work by priority
4. Open Brain → architectural context and domain knowledge when needed
5. PRD / spec files → detailed specifications (see Key Files below)

---

## Tech Stack

| Layer | Technology |
|---|---|
| {{LAYER}} | {{TECHNOLOGY}} |
| {{LAYER}} | {{TECHNOLOGY}} |
| {{LAYER}} | {{TECHNOLOGY}} |
| Task Tracking | Beads (`bd`) — git-backed dependency graph |
| Knowledge Layer | Open Brain — Supabase-backed MCP memory |

---

## Architecture

{{Describe the core architecture in 3-6 bullet points or a numbered pipeline. Focus on data flow and the key design decisions. Example:}}

{{
1. **Ingestion** — ...
2. **Processing** — ...
3. **Output** — ...
}}

---

## Key Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Claude Code entrypoint — redirects to this file |
| `AGENTS.md` | This file — agent instructions and project context |
| `{{FILE}}` | {{PURPOSE}} |
| `.beads/` | Beads database — task graph, dependencies, work state |

---

## Code Style Preferences

- {{STYLE_RULE_1 — e.g. "Production-ready, clean code — no extraneous TODO comments in committed code"}}
- {{STYLE_RULE_2 — e.g. "TypeScript strict mode, no `any`"}}
- {{STYLE_RULE_3 — e.g. "Robust error handling with meaningful error messages"}}
- {{STYLE_RULE_4 — e.g. "When writing scripts: logging, multi-method fallback, clean exit codes"}}

---

## Important Decisions (Query Open Brain for Full Context)

- **{{DECISION_TITLE}}** — {{one-line rationale}}
- **{{DECISION_TITLE}}** — {{one-line rationale}}
- **{{DECISION_TITLE}}** — {{one-line rationale}}

---

## What NOT to Do

- Do not use GitHub Issues or any other issue tracker — Beads is canonical
- Do not create markdown task lists — use `bd create` instead
- {{PROJECT_SPECIFIC_CONSTRAINT_1}}
- {{PROJECT_SPECIFIC_CONSTRAINT_2}}
- {{PROJECT_SPECIFIC_CONSTRAINT_3}}

---

## Tool-Specific Setup & Enforcement

### Hook Capabilities by Tool

Not all tools support lifecycle hooks. Where hooks exist, use them to enforce the session lifecycle. Where they don't, AGENTS.md instructions are the enforcement mechanism.

| Tool | Hooks | Pre-Compact Capture | Session Start Enforcement | Config Location |
|------|-------|--------------------|----|-----------------|
| Claude Code | ✅ Full (command, agent, prompt) | ✅ Agent-type PreCompact hook captures to OpenBrain | ✅ SessionStart hook + system message | `~/.claude/settings.json` |
| OpenCode CLI | ✅ Plugin system + oh-my-opencode | ✅ `session.compacting` event | ✅ Plugin hooks available | `~/.config/opencode/opencode.json` |
| KiloCode CLI | ❌ Not yet (GitHub issue #5827) | ❌ Must follow AGENTS.md manually | ❌ Must follow AGENTS.md manually | `~/.config/kilo/opencode.json` |
| Cursor | ❌ Rules only, no hooks | ❌ Must follow AGENTS.md manually | ❌ Rules-based reminder only | `.cursor/rules/` |
| Codex | ❌ No hooks | ❌ Must follow AGENTS.md manually | ❌ AGENTS.md only | AGENTS.md |

### Beads Setup

```bash
bd setup claude    # Claude Code — installs SessionStart/PreCompact hooks
bd setup cursor    # Cursor IDE — creates .cursor/rules/beads.mdc
bd setup aider     # Aider — creates .aider.conf.yml
bd setup codex     # Codex CLI — creates/updates AGENTS.md snippet
bd setup mux       # Mux — creates/updates AGENTS.md snippet
```

### OpenCode CLI

Config at `%USERPROFILE%\.config\opencode\opencode.json`:

```json
{
  "instructions": ["AGENTS.md"],
  "mcp": {
    "open-brain": {
      "type": "remote",
      "url": "{{OPEN_BRAIN_MCP_URL}}",
      "enabled": true
    }
  }
}
```

### KiloCode CLI

Config at `%USERPROFILE%\.config\kilo\opencode.json`:

```json
{
  "instructions": ["AGENTS.md"],
  "mcp": {
    "open-brain": {
      "type": "remote",
      "url": "{{OPEN_BRAIN_MCP_URL}}",
      "enabled": true
    }
  }
}
```

### Open Brain

Available via MCP from any tool that supports MCP servers. This is the shared knowledge layer that makes multi-agent work possible — every agent reads from and writes to the same brain.

---

## MCP Server Configuration

### OpenBrain MCP (Session Memory & Context)

**Commands:**
```
/open-brain search "query"           # Search captured thoughts
/open-brain list                     # List recent thoughts
/open-brain capture "thought text"   # Capture a new thought
```

**For Claude Code** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "open-brain": {
      "type": "sse",
      "url": "{{OPEN_BRAIN_MCP_URL}}"
    }
  }
}
```

**For OpenCode / KiloCode CLI:** See tool-specific sections above.
