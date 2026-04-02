---

## OMO: Role and Positioning

**OMO** (oh-my-openagent) is the middle execution layer. It handles medium and large
single-agent work that is too structured for raw Claude Code but doesn't need Gas Town's
full multi-agent convoy infrastructure.

### The Three-Layer Model

```
Raw Claude Code    — Quick fixes, <5 files, low stakes
       ↓
     OMO           — Features, 5–20+ files, single agent, worktree isolation
       ↓
  Gas Town         — Parallel workstreams, convoy scale, Refinery merge gates
```

### What OMO Provides Over Raw Claude Code

- **Worktree isolation** — `/start-work --worktree` creates a dedicated git worktree,
  so the agent can't accidentally corrupt main while working
- **Specialist agents** — Sisyphus delegates to Prometheus (planning), Atlas (execution),
  Momus (verification) instead of one agent doing everything
- **Hierarchical AGENTS.md** — Context is scoped to where the agent is working, reducing
  context bloat on large repos
- **Guardrails** — `.sisyphus/guardrails.yml` intercepts dangerous operations before
  they execute (no direct main pushes, no force pushes, no DROP TABLE)
- **Code quality rules** — `.sisyphus/rules/` markdown files enforce project conventions
  at the agent level, not just the PR review level
- **Multi-provider fallback** — Per-agent model routing (Claude → Haiku fallback, or
  route planning to a different model than execution)

---

## OMO: Agent Roster

| Agent | Role | Analogy |
|-------|------|---------|
| **Sisyphus** | Orchestrator — delegates and tracks | Mayor (Gas Town) |
| **Prometheus** | Strategic planner — creates worktree-aware plans | /office-hours + /plan-eng-review |
| **Atlas** | Executor — writes code, runs tests, commits | Polecat (Gas Town) |
| **Momus** | Verifier — reviews implementation vs spec | Refinery (Gas Town) |

### Key Difference from Gas Town

Gas Town agents run as separate processes on a server, coordinated by the Mayor.
OMO agents are sub-contexts within a single OpenCode session — faster, simpler,
and appropriate for one developer working on one feature.

---

## OMO: Workflow

### Session Start

```bash
# From project root — create isolated worktree
git worktree add ../worktrees/feat-<task-id> -b feat/<task-id>
cd ../worktrees/feat-<task-id>

# Start OMO
opencode

# Inside OMO:
# 1. Prime context
#    /start-work --worktree
#    search_thoughts("[TASK <task-id>]")    ← check OpenBrain for prior context
#    bd prime                               ← load beads state

# 2. Read the task
#    bd show <task-id>                      ← understand acceptance criteria

# 3. Plan (Prometheus)
#    /writing-plans                         ← or let Sisyphus delegate to Prometheus

# 4. Execute (Atlas)
#    Implement, matching existing conventions
#    /test-driven-development if complex

# 5. Verify (Momus)
#    /verification-before-completion        ← gate before marking done
#    /requesting-code-review
#    /receiving-code-review
```

### Session End

```bash
# From inside worktree:
git push -u origin feat/<task-id>
bd close <task-id>
capture_thought("[TASK <task-id>] [COMPLETED] ...")

# From project root — merge and clean up:
cd <project-root>
git merge feat/<task-id>
git push
git worktree remove ../worktrees/feat-<task-id>
git branch -d feat/<task-id>
git push origin --delete feat/<task-id>
```

---

## OMO: Configuration

### opencode.json (global — ~/.config/opencode/opencode.json)

```json
{
  "plugins": ["oh-my-openagent"],
  "instructions": ["AGENTS.md"],
  "mcp": {
    "open-brain": {
      "type": "remote",
      "url": "<your-openbrain-mcp-url>",
      "enabled": true
    }
  },
  "providers": {
    "anthropic": {
      "models": ["claude-sonnet-4-6", "claude-haiku-4-5-20251001"],
      "apiKey": "${ANTHROPIC_API_KEY}"
    }
  }
}
```

### .sisyphus/rules/ (project-local — markdown files)

One file per rule category. Format:

```markdown
# Rule Name
**Application scope:** globs (e.g., **/*.ts)
**Severity:** blocking | warning

## Rules
[Rule descriptions in plain prose]
```

### .sisyphus/guardrails.yml (project-local — YAML)

Intercepts tool calls before execution. Format:

```yaml
rules:
  - id: rule-id
    description: "What this blocks"
    trigger: git_push | file_write | shell_command
    pattern: "regex to match"
    severity: block | warn
    message: "Message shown when triggered"
```

---

## OMO: Hard Rules

- **Never work in main** — always create a worktree for OMO sessions
- **Never skip verification** — run `/verification-before-completion` before closing a task
- **Never push to main directly** — the `no-direct-main-push` guardrail enforces this
- **Always capture to OpenBrain at session end** — OMO sessions are single-agent but
  institutional knowledge must persist for future sessions
- **Keep .sisyphus/ in the repo** — these are project conventions, not personal config.
  Other developers (and other OMO sessions) inherit the same guardrails.
