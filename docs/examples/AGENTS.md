# MoldKit — AI-Powered Design-to-Builder Conversion Platform

> **This file is the single source of truth for all AI coding agents.** It is read natively by OpenCode, KiloCode, Codex, Cursor, Amp, Jules, and others. Claude Code reads CLAUDE.md, which points here. Do not duplicate instructions — edit this file only.

## Project Overview

MoldKit converts any design input (URL, GitHub repo, ZIP, Figma) into native editable elements in page builders (GHL, Bricks Builder, Gutenberg). It's the only tool that converts external websites into GHL-native elements — all competitors are GHL-to-GHL only.

**Domain:** moldkit.ai
**Current Phase:** Phase 0 Validation (3 tracks, 2 weeks)
**Edition:** Personal Edition first, then SaaS

## Agent Memory Framework

MoldKit uses a dual-layer memory system. Follow this protocol on every session start:

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
- Failed clones (Grade F) never count against subscription allowance
- Always push before ending a session — unpushed work breaks coordination

### Layer 2: Open Brain (Knowledge & Decisions)

Open Brain is the institutional knowledge layer. It stores architectural decisions, research findings, competitive analysis, pricing rationale, and all context that explains WHY things are the way they are.

**When to query Open Brain:**
- Before making architectural decisions (search for prior decisions first)
- When a task references domain knowledge you don't have in context
- When you need PRD details, tech stack rationale, or competitive context
- Before recommending alternatives to established choices

**MCP Access:** Open Brain is available via MCP from any AI tool (Claude Code, Claude.ai, Cursor, ChatGPT, Gemini).

**What to capture:** After making significant decisions, completing research, or reaching milestones, capture the outcome to Open Brain so future sessions have it.

### Lookup Order

1. `bd dolt pull` → sync task state from DoltHub (always first)
2. `bd prime` → current task state
3. `bd ready` → pick work by priority
4. Open Brain → architectural context and domain knowledge when needed
5. PRD files → detailed specifications (see Key Files below)

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 16.2 (App Router), Tailwind CSS 4, shadcn/ui |
| Backend/DB | Convex (real-time subscriptions, file storage, mutations) |
| Auth | Clerk (single-user lockdown for Personal; multi-user for SaaS) |
| Browser Automation | agent-browser (Vercel Labs, Rust-based, v0.20.x) primary; Playwright fallback |
| Cloud Browser | Browserless, Browserbase, or Kernel (stealth/anti-bot) |
| AI Conversion | Claude API — Sonnet 4.6 for complex layouts, Haiku 4.5 for simple pages |
| Worker | Node.js orchestrator (co-located for Personal, separate for SaaS) |
| Chrome Extension | ~200 lines JS — paste delivery for GHL builder DOM injection |
| Task Tracking | Beads (`bd`) — git-backed dependency graph |
| Knowledge Layer | Open Brain — Supabase-backed MCP memory |

## Architecture: Conversion Pipeline

The core pipeline has 7 steps. AI only runs at step 3.

1. **Clean HTML** (rule-based) — strip trackers, analytics, inline CSS
2. **Asset preparation** (rule-based) — upload images to Convex storage, self-host fonts
3. **AI Layout Decomposition** (Claude vision) — screenshot + HTML → semantic page tree with Section/Row/Column/Element boundaries
4. **Element mapping** (rule-based) — h1→Heading, img→Image, button→Button, video→Video; AI assists ambiguous elements
5. **Style extraction** (rule-based) — computed CSS → target platform style properties
6. **JSON assembly** (rule-based) — build target platform JSON (GHL, Bricks, Gutenberg)
7. **Fallback handling** — anything unmappable → Custom HTML block; content never lost

Steps 1-3 produce a platform-agnostic **Semantic Page Tree**. Steps 4-6 are the **output adapter** (pluggable per target platform). V1 = GHL adapter only.

**GHL Element Hierarchy:** Section → Row → Column → Element

## Key Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — agent instructions and project context |
| `moldkit-prd-saas.md` | SaaS PRD v3.0 — full specifications, pricing, data models |
| `moldkit-prd-personal.md` | Personal Edition PRD v2.0 — subset for single-user deployment |
| `.beads/` | Beads database — task graph, dependencies, work state |

## Phase 0 Validation (Current)

Three parallel tracks, 2 weeks. Check `bd ready` for current active tasks.

**Track A — Cloning Engine:** Test agent-browser vs Playwright on 30 real-world sites (5 categories: simple landing pages, SPAs, GHL-built, WordPress, complex JS-heavy, anti-bot). Success: ≥22/30 Grade B+, ≥25/30 GHL import success, median <45s.

**Track B — GHL Schema Reverse-Engineering:** Extract JSON from 10-15 free GHL pre-built templates using GHL Schema Extractor Toolkit. Document the internal JSON schema as the target format for the converter.

**Track C — AI Layout Decomposition:** Test Claude Sonnet 4.6 vs Haiku 4.5 on same 30 sites. Measure section/column detection accuracy and structured JSON output reliability.

**Cross-track dependencies:** Track B schema output feeds Track A import testing. Track C AI results validate Track A fidelity grades.

## Code Style Preferences

- Production-ready, clean code — no extraneous documentation or TODO comments in committed code
- PowerShell-compatible commands for Windows environments
- Robust error handling with meaningful error messages
- When writing scripts: logging, multi-method fallback, clean exit codes

## Important Decisions (Query Open Brain for Full Context)

- **agent-browser over Playwright** — Rust-based, native cloud browser support, stealth/anti-bot
- **Convex over Supabase** — real-time subscriptions, file storage, simpler auth integration with Clerk
- **CLI over MCP for agent access** — moldkit-cli planned for v1.1 (~200 tokens vs ~15,000+ for MCP schema)
- **Chrome extension required for GHL** — GHL has no public API for page creation; DOM injection is the only path (same approach SmartCloner uses)
- **Beads over Gastown** — multi-agent orchestration deferred; Beads alone provides task tracking + dependency graphs without orchestration overhead
- **Personal Edition first** — architecturally designed as Phase 1 of SaaS; upgrade path is purely additive

## What NOT to Do

- Do not use GitHub Issues or any other issue tracker — Beads is canonical
- Do not create markdown task lists — use `bd create` instead
- Do not hardcode GHL JSON schema — it must be reverse-engineered in Phase 0
- Do not build MCP server for MoldKit — CLI is the planned agent interface (v1.1)
- Do not add Stripe, rate limiting, or multi-user auth to Personal Edition
- Do not commit `.beads/` test data to the main database — use `BEADS_DB=/tmp/test.db` for testing

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
      "url": "https://fsbrtmevmbgxvrqojgzu.supabase.co/functions/v1/open-brain-mcp?key=2c285773aebf06f763027b21ea21718dad63111dd941954a942381e74851be53",
      "enabled": true
    }
  }
}
```

OpenCode reads AGENTS.md via the `instructions` field. It has a full plugin system (`@opencode-ai/plugin`) with lifecycle events including `session.compacting`, `session.created`, `tool.execute.before/after`, and more. For pre-compaction capture, install oh-my-opencode or write a custom plugin that captures to OpenBrain on the `session.compacting` event.

### KiloCode CLI

Config at `%USERPROFILE%\.config\kilo\opencode.json`:

```json
{
  "instructions": ["AGENTS.md"],
  "mcp": {
    "open-brain": {
      "type": "remote",
      "url": "https://fsbrtmevmbgxvrqojgzu.supabase.co/functions/v1/open-brain-mcp?key=2c285773aebf06f763027b21ea21718dad63111dd941954a942381e74851be53",
      "enabled": true
    }
  }
}
```

KiloCode reads AGENTS.md via the `instructions` field. Hook support is not yet available (GitHub issue #5827). Until hooks ship, KiloCode agents must follow the session lifecycle protocol in AGENTS.md manually. Open Brain MCP gives it access to all captured context from other agents.

### Open Brain

Available via MCP from any tool that supports MCP servers. All configs above include the Open Brain MCP connection. This is the shared knowledge layer that makes multi-agent work possible — every agent reads from and writes to the same brain.

## MCP Server Configuration

All AI tools (Claude Code, OpenCode, KiloCode, Cursor, Codex) use these MCP servers for enhanced capabilities.

### OpenBrain MCP (Session Memory & Context)

Open Brain stores all session context: errors, environment findings, architectural decisions, and handoff notes. Access it from any agent via MCP to prevent lost context between sessions.

**For OpenCode (VS Code Extension):**

OpenCode automatically reads this AGENTS.md file. It can access Open Brain via remote MCP without additional setup.

**Commands:**
```
/open-brain search "query"           # Search captured thoughts
/open-brain list                     # List recent thoughts
/open-brain capture "thought text"   # Capture a new thought
```

**For OpenCode CLI:**

OpenCode CLI uses a standard MCP configuration. Create or edit `%USERPROFILE%\.config\opencode\opencode.json`:

```json
{
  "mcp": {
    "open-brain": {
      "type": "remote",
      "url": "https://fsbrtmevmbgxvrqojgzu.supabase.co/functions/v1/open-brain-mcp?key=2c285773aebf06f763027b21ea21718dad63111dd941954a942381e74851be53",
      "enabled": true
    }
  }
}
```

Then restart OpenCode CLI. Verify connection by running:
```
/mcps
```

Should show `open-brain` as connected ✅

**Commands (same as other tools):**
```
/open-brain search "session-capture-checklist"   # Find how to capture context
/open-brain list                                 # Show all captured thoughts
/open-brain capture "Session finding"            # Add new context
```

**For KiloCode CLI:**

Create or edit `%USERPROFILE%\.config\kilo\opencode.json`:

```json
{
  "mcp": {
    "open-brain": {
      "type": "remote",
      "url": "https://fsbrtmevmbgxvrqojgzu.supabase.co/functions/v1/open-brain-mcp?key=2c285773aebf06f763027b21ea21718dad63111dd941954a942381e74851be53",
      "enabled": true
    }
  }
}
```

Then restart KiloCode CLI. Verify connection by running:
```
/mcps
```

Should show `open-brain` as connected ✅

**Commands (same as OpenCode):**
```
/open-brain search "Convex errors"   # Search for specific context
/open-brain list                     # Show all captured thoughts
/open-brain capture "My finding"     # Add new context
```

### Session Lifecycle (MANDATORY for All Agents)

MoldKit uses a closed-loop context system. Both ends are mandatory — breaking either side wastes hours of agent work.

#### Session Start Protocol

**Run BEFORE writing any code.** In Claude Code: `/session-start-checklist`. In other agents: follow these steps manually.

1. `bd dolt pull && bd prime` — sync task state, identify your task
2. Search OpenBrain for task context (MANDATORY, not optional):
   ```
   search_thoughts("[TASK {taskId}]")        # All captures for this task
   search_thoughts("[HANDOFF {taskId}]")     # Previous agent's handoff
   search_thoughts("{topic} errors")         # Known errors in this area
   ```
3. Read required context files (see Required Reading table below)
4. Check `bd show {taskId}` for previous agent notes and blockers
5. Acknowledge context before proceeding — don't start coding until you've consumed prior knowledge

#### Session End Protocol

**Run BEFORE ending a session or handing off.** In Claude Code: `/session-capture-checklist`. In other agents: follow the capture format below.

Every OpenBrain capture **MUST** be tagged with the beads task ID:

```
[TASK r7x.5] [ERROR] Exact error message — root cause and fix
[TASK r7x.5] [DISCOVERY] New finding — what you learned and its impact
[TASK r7x.5] [BLOCKER] What's stuck — workaround if any
[TASK r7x.5] [ENVIRONMENT] Platform-specific issue — Windows/Linux/WSL
[TASK r7x.5] [DECISION] Choice made — rationale and alternatives considered
[TASK r7x.5] [HANDOFF] Session summary — what's done, what's next, required reading
```

**Mandatory categories:** Errors, Discoveries, Environment, Blockers, Handoff. If a category has nothing to report, explicitly state "None this session." Never skip categories silently.

**Then push everything:**
```bash
bd update {taskId} --notes "COMPLETED: X. IN PROGRESS: Y. NEXT: Z. OpenBrain: search [TASK {id}]"
git pull --rebase && git push && bd dolt push
```

#### Required Reading by Task Area

| Task Area | Files to Read Before Starting |
|-----------|-------------------------------|
| GHL adapter (r7x.4) | `documents/validation/ghl-schema-reference.md` |
| Chrome extension (r7x.5) | `documents/validation/ghl-schema-reference.md`, `extension/popup.js` |
| Cloning engine (r7x.2) | `documents/validation/` capture results |
| AI decomposition (r7x.3) | `documents/validation/` decomposition scores |
| Any Phase 1 task | `documents/MILESTONES.md` |
| Architecture questions | OpenBrain: search "architecture" or "tech stack" |

#### Multi-Agent Handoff Protocol

When transitioning between agents (any tool → any tool):

1. **Outgoing agent:** Run session-capture-checklist with ALL mandatory categories. Ensure handoff note includes:
   - What's working, what's not
   - Next steps (specific, actionable)
   - Required reading for the incoming agent
   - OpenBrain search keywords
2. **Incoming agent:** Run session-start-checklist. Search OpenBrain for `[HANDOFF {taskId}]`. Read all required files. Acknowledge context before coding.
3. **Verification:** If the incoming agent can't find prior context in OpenBrain, the outgoing agent failed to capture. Check git log for recent commits as a fallback.

#### Git Worktree Convention (Multi-Agent Parallel Work)

When multiple agents work simultaneously, use standard git worktrees to prevent file collisions:

```bash
# Agent claims a task and creates an isolated worktree:
git worktree add ../moldkit-{taskId} -b agent/{agent-name}/{taskId}
cd ../moldkit-{taskId}
bd update {taskId} --claim

# Agent works in isolation (no collisions with other agents)
# ...

# When done, push branch and create PR:
git push origin agent/{agent-name}/{taskId}
# PR reviewed and merged to main

# Cleanup:
git worktree remove ../moldkit-{taskId}
```

This is standard git — works in any agent, any tool, any platform. No tool-specific features required.

**Skill locations:**
- Session start: `C:\Users\admin\.claude\skills\session-start-checklist\SKILL.md`
- Session capture: `C:\Users\admin\.claude\skills\session-capture-checklist\SKILL.md`

<!-- BEGIN BEADS INTEGRATION v:1 profile:full hash:d4f96305 -->
## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Dolt-powered version control with native sync
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**

```bash
bd ready --json
```

**Create new issues:**

```bash
bd create "Issue title" --description="Detailed context" -t bug|feature|task -p 0-4 --json
bd create "Issue title" --description="What this issue is about" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**

```bash
bd update <id> --claim --json
bd update bd-42 --priority 1 --json
```

**Complete work:**

```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task atomically**: `bd update <id> --claim`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" --description="Details about what was found" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Auto-Sync

bd automatically syncs via Dolt:

- Each write auto-commits to Dolt history
- Use `bd dolt push`/`bd dolt pull` for remote sync
- No manual export/import needed!

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems

### Windows Environment Note

On this machine, `bd` is installed at `C:\Users\admin\AppData\Local\Programs\bd\bd.exe` and symlinked into `~/.local/bin/` so it's on PATH for all shells (PowerShell, Git Bash, and Claude Code's bash). If `bd` stops working in Claude Code, verify the symlink exists:

```bash
ls -la ~/.local/bin/bd.exe  # Should point to /c/Users/admin/AppData/Local/Programs/bd/bd.exe
```

Claude Code's Bash tool runs non-interactive non-login bash — `.bashrc` and `.bash_profile` are **not sourced**. Only binaries in directories already on the default PATH will work. `~/.local/bin` is on the default PATH.

For more details, see README.md and docs/QUICKSTART.md.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

<!-- END BEADS INTEGRATION -->
