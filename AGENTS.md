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
# SESSION START — always run first
bd prime                          # ~80 lines of current project context (beads is local, no remote pull needed)

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

# SESSION END — always push code and back up beads
git pull --rebase && git push && git status
bd backup export-git              # Back up beads to beads-backup branch on GitHub
```

**Rules:**
- Always use `--json` flag for programmatic output
- Never use `bd edit` — it opens an interactive editor agents can't use
- P0 = critical, P1 = high, P2 = medium, P3 = low, P4 = deferred
- Always push before ending a session — unpushed work breaks coordination
- Beads data is local (Dolt database on this machine). Backup is via `bd backup export-git` which pushes JSONL to a `beads-backup` branch on GitHub. No DoltHub account needed.

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

1. `bd prime` → current task state (beads is local, no remote sync needed)
2. `bd ready` → pick work by priority
3. Open Brain → architectural context and domain knowledge when needed
4. PRD / spec files → detailed specifications (see Key Files below)

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

## Gas Town Integration (if applicable)

If this project uses Gas Town for multi-agent orchestration, follow this protocol:

### Mayor Coordination Protocol

When working with the user and Mayor action is needed, **do not ask for permission to draft a prompt.** Just write it and present it. The user copies and sends — that's the only approval step.

This applies to:
- Dispatching idle polecats
- Filing obvious beads (bugs, security findings, follow-on work)
- Responding to patrol reports that have clear action items
- Re-filing lost beads

**Pattern:** Patrol report arrives → assess → draft Mayor prompt → present it. No "want me to write a prompt?" loop.

### Agent Dispatch Rules (Claude Code sessions)

**Do not do research, searches, or status checks in the main Sonnet context.** Dispatch subagents instead:

- **Haiku** — all searches, file reads, status checks, OpenBrain queries, SSH commands, bead lookups. Fast and cheap.
- **Sonnet** — synthesis, judgment, writing prompts, architectural decisions, reasoning across multiple sources.

**Pattern:** Need to check something? `Agent(model: haiku, ...)`. Get the result. Then reason over it in Sonnet. Never burn Sonnet tokens on mechanical lookups.

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

---

# Workflow Architecture

This project uses a **two-workflows-plus-default** routing model. Before
starting non-trivial work, route it. The router lives at
`.claude/skills/route/SKILL.md`.

## The three modes

### Default mode
Open Claude, do the thing. No bead, no capture, no ceremony.

**Use for:** one-off questions, lookups, config tweaks under 5 min,
exploratory pokes where you don't yet know what you're looking for.

**Trigger:** if you've been in default mode for 20 minutes without an
active bead, the shell watchdog fires a notification asking you to route.
Either dismiss (genuinely default mode) or stop and run `route` to
migrate to OMO with what you've already done as initial context.

### OMO (single-agent serial work)
Single-agent focused work that produces a discrete deliverable and a
reasoning trace. Lightweight middle layer between raw Claude Code and
Gas Town orchestration.

**Use for:** feature builds, refactors, focused debugging with clear
trace value, project-level work that doesn't parallelize.

**Startup ritual:** see "OMO startup" below.

### Gas Town (multi-agent orchestration)
Parallel polecat work coordinated by Mayor through convoys. Used when
the work splits into independent pieces OR when cross-agent coordination
is the value.

**Use for:** SaaS-scale parallel feature builds, multi-tier deployments
where each tier is an independent unit, work with explicit dependency
graphs.

**Startup ritual:** see "Gas Town startup" below.

## The router

Before starting non-trivial work:

```bash
route "<one-line work description>"
```

The route skill asks 3-4 structured questions and outputs a
recommendation: GAS_TOWN, OMO, or DEFAULT, with confidence level,
reasoning, suggested bead title, and suggested system tags.

Every invocation captures a `[ROUTE-DECISION]` thought to OpenBrain.
At session end, the actual-outcome field gets updated — that data
feeds the route skill's own Karpathy loop over time.

**Skip routing for:** obviously-trivial work. Don't ceremonialize quick
lookups.

**Always route for:** anything you'd want a trace of, anything that
might take more than 20 minutes, anything that might need a teammate
or future-you to pick up.

## OMO startup

1. **Route the work.** `route "<description>"` → confirms OMO is appropriate, returns suggested bead title and tags.

2. **Create and claim the bead.**
   ```bash
   bd create "<suggested bead title>" --tags "<suggested tags>"
   bd start <bead-id>
   ```

3. **Create isolated worktree.**
   ```bash
   git worktree add ../<project>-omo-<bead-id> -b omo/<bead-id>
   cd ../<project>-omo-<bead-id>
   ```

4. **Launch the agent.**
   ```bash
   omo run <persona> --bead <bead-id>
   # OR for raw Claude Code:
   claude
   ```

5. **Phase 1 — Session-start context load (agent does this).**
   - Read active bead via `bd list --status in_progress`
   - Search OpenBrain for prior `[OMO-BLOCKED]` and `[CHRONICLER-PATTERN]` captures matching the bead's tags
   - Read suggested-next-action and continuity-hint fields if any prior session blocked on this work

6. **Work the bead.** Standard discipline: bd update before significant actions, commit incrementally to the omo branch, capture `[OMO-CHECKPOINT]` thoughts at non-obvious decision points.

7. **Phase 3 — Session-exit ritual (MANDATORY).** Before `bd close`, capture exactly one structured thought:
   - On success: `[OMO-COMPLETE]` with approach-that-worked and approaches-discarded
   - On BLOCKED: `[OMO-BLOCKED]` with what-attempted, where-stuck, failure-mode, suggested-next-action, continuity-hint, and confidence
   - Then update the `[ROUTE-DECISION]` from step 1 with the actual-outcome field

8. **Merge or discard.**
   - Clean: `git merge omo/<bead-id>` to main, `bd close <bead-id>`, `git worktree remove ../<project>-omo-<bead-id>`
   - BLOCKED: `bd update <bead-id> --status blocked`, leave worktree for next session resume

## Gas Town startup

1. **Route the work.** `route "<description>"` → confirms GAS_TOWN is appropriate, returns suggested bead title and tags.

2. **Create the bead** (Mayor will pick it up).
   ```bash
   bd create "<suggested bead title>" --tags "<suggested tags>"
   ```

3. **Attach Mayor.**
   ```bash
   gtm  # alias for: gt mayor attach --agent claude-sonnet
   ```

4. **Mayor handles the rest.**
   - Creates the convoy
   - Dispatches polecats per the bead's parallelism
   - Polecats work in their own worktrees
   - Refinery merges completed work back via `mol-refinery-patrol`
   - Witness monitors polecat health
   - On BLOCKED escalation: Mayor receives the failure trace and re-dispatches with continuity hint (when Chronicler city_agent is built — see roadmap)

5. **Phase 3 — Session-exit ritual** is handled per-polecat by `mol-polecat-work` formula gate (already enforced). Mayor-level captures fire via `precompact-capture.sh` hook and `openbrain-capture` step in `mol-mayor-patrol`.

6. **Update `[ROUTE-DECISION]`** at the end of the convoy with actual-outcome.

## Skill registry

Skills live under `.claude/skills/` in this project. The bootstrap
template provides:

- `route/` — pre-flight workflow router (this skill)
- `chronicler/` — capture format definitions and OpenBrain protocol *(when built)*

Superpowers enforcement skills (when built) will live in their own
locations and call into `chronicler/` for format consistency.

## OpenBrain capture conventions

All workflow events capture to OpenBrain via the `open-brain` MCP
(`capture_thought`). Format conventions:

- **Bracketed type tag** at the start: `[OMO-COMPLETE]`, `[OMO-BLOCKED]`, `[OMO-CHECKPOINT]`, `[ROUTE-DECISION]`, `[CHRONICLER-PATTERN]`, etc.
- **One capture per event** — don't batch
- **SEARCH TAGS line** at the end with comma-separated tags for retrieval
- **Two-capture pattern** for major decisions: separate `[DECISION]` (the WHY) from `[REFERENCE]` (the HOW)

## What's NOT in version control

- The unrouted-session shell watchdog (lives in your dotfiles, not here)
- Your personal `~/.claude.json` MCP config (per-machine)
- Worktree directories (`../*-omo-*` paths — already in `.gitignore`)

## Roadmap (workflow architecture)

These are not yet implemented but are referenced in the architecture:

- `session-start-context-load` Superpowers skill (currently agents do Phase 1 manually)
- `decision-checkpoint-capture` Superpowers skill (currently agents do mid-session captures manually)
- `session-exit-reflect` Superpowers skill (currently agents do Phase 3 manually)
- Chronicler skill defining capture formats (currently formats live in this AGENTS.md)
- Chronicler city_agent for Gas Town (replaces manual Mayor capture discipline)
- Beads-heartbeat watcher (replaces shell-only unrouted-session watchdog)

Until these are built, the workflow architecture relies on agent
discipline plus AGENTS.md enforcement — same model as Mayor today.
Acceptable for v1.0; harden incrementally.
