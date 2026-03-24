---
name: session-start-checklist
description: "Mandatory context consumption checklist before starting work. Run this skill at the START of every session, before writing any code. This skill prevents agents from re-deriving known facts, repeating solved errors, and ignoring existing documentation. Use this skill whenever: (1) Starting a new session; (2) Switching to a different task; (3) Picking up work from another agent; (4) Resuming after compaction. If you find yourself debugging something and thinking 'has someone solved this before?' — you should have run this skill first."
---

# Session Start Checklist

This skill ensures that every agent starts with **full situational awareness** before writing a single line of code. It exists because agents consistently skip context consumption and re-derive information that was already captured — wasting hours and tokens on solved problems.

## Why This Exists

Real failures this skill prevents:
- Agent started coding without reading the schema reference that was already documented — wasted 2+ hours rediscovering the data format
- Agent debugged an issue that a previous agent had already solved but didn't capture — same fix derived twice
- Agent started work on a task without checking OpenBrain, missing critical blockers and workarounds from the previous session

The pattern: agents optimize for action. They see a task, they start coding. This skill forces a pause to consume context first.

---

## How to Use

### In Claude Code
```
/session-start-checklist
```

### In Any Agent (OpenCode, KiloCode, Codex, etc.)
Follow the protocol below manually. The steps are the same — only the trigger differs.

---

## The Checklist

### Step 0: Verify OpenBrain + Import Any Pending Fallback Captures (MANDATORY — do this FIRST)

**Test the token before doing anything else:**

```
thought_stats()    # OpenBrain MCP call — if this fails, STOP
```

**If `thought_stats` succeeds:** proceed normally.

**If `thought_stats` fails (token expired):**
1. Tell the user: "OpenBrain token is expired — please re-auth in any Claude Code session. I'll wait a minute and retry."
2. Wait ~1–2 minutes after the user re-auths (the token propagates via the OS credential store).
3. Retry `thought_stats()` — continue once it passes. **No session restart required.**

Note: Re-authing in ANY open Claude Code session refreshes the shared token. This session will pick it up automatically on the next MCP call — you do not need to close or restart anything.

**Check for pending fallback captures:**

```bash
ls docs/session-capture-*.md 2>/dev/null
```

If any `docs/session-capture-*.md` files exist, they are captures from a previous session where OpenBrain was unavailable. Import them NOW while the token is fresh:

1. Read each file
2. For each `[TASK ...]` section, call `capture_thought(...)` with the full section content
3. Confirm each capture succeeded
4. Delete the file: `git rm docs/session-capture-{date}.md`
5. Commit and push: `git commit -m "Import session capture to OpenBrain, remove fallback file" && git push`

Do not skip this — these files represent context that could not be saved previously and will be lost if ignored.

---

### Step 1: Sync Task State

```bash
bd dolt pull          # Sync latest from DoltHub
bd prime              # Current project context (~80 lines)
```

Read the output. Identify:
- What task are you about to work on?
- What's the task ID?
- Who last worked on it?
- Are there any blockers?

### Step 2: Search OpenBrain for Task Context

Search for the task ID and related keywords. These searches are **mandatory**, not optional:

```
search_thoughts("[TASK {taskId}]")         # All captures tagged to this task
search_thoughts("[HANDOFF {taskId}]")      # Previous agent's handoff note
search_thoughts("{task topic} errors")     # Known errors for this area
search_thoughts("session capture")         # Most recent session summary
```

**Read what comes back.** If OpenBrain has relevant captures, understand them before proceeding. Pay special attention to:
- **Errors and fixes**: Don't re-debug solved problems
- **Environment issues**: Windows vs macOS vs Linux differences, path handling, tool compatibility
- **Architectural decisions**: Why things are the way they are
- **Blockers and workarounds**: What's currently stuck and why

### Step 3: Read Required Context Files

Every epic/task area has key reference files. Read them **before writing code**:

| Task Area | Required Reading |
|-----------|-----------------|
| _Add project-specific entries here_ | _Relevant docs/files_ |
| Architecture questions | Query OpenBrain for "architecture" or "tech stack" |

If the task has notes from `bd show {taskId}`, check if they reference specific files — read those too.

### Step 4: Check for Active Blockers

```bash
bd ready --json       # What's unblocked and available?
bd show {taskId}      # Full details on your target task
```

Look at:
- Dependencies: Is this task blocked by something else?
- Related tasks: Are other agents working on connected tasks?
- Previous notes: What did the last agent leave?

### Step 5: Set Up Context Monitor (Claude Code Only)

Set up an automatic context usage monitor so compaction never catches you off guard:

```
CronCreate: cron "*/10 * * * *", prompt "Check context usage by running /context. If messages percentage exceeds 70% of total, IMMEDIATELY run /session-capture-checklist. If between 60-70%, warn the user: 'Context at [X]% — approaching capture threshold.' Do NOT skip or defer this."
```

This fires every 10 minutes. When context hits 70%, the agent auto-captures before compaction can wipe anything. The user no longer needs to manually babysit context levels.

**For non-Claude-Code agents:** Monitor context manually and capture when the tool's context indicator shows >70% usage.

### Step 6: Acknowledge and Proceed

Before writing any code, confirm to yourself (or state in chat):
1. "I've read the OpenBrain context for [task]"
2. "I've read the required reference files"
3. "I understand the current blockers: [list or none]"
4. "I'm aware of these previous findings: [key points]"
5. "Context monitor is active" (Claude Code only)

Then proceed with work.

---

## What to Do When OpenBrain Has Nothing

If OpenBrain searches return no results for a task, that's a signal:
- Either the task is brand new (no prior work)
- Or the previous agent didn't capture properly

If it's the latter, check git log for recent commits on related files — those commits may contain context that should have been captured.

---

## Integration with Beads

When `bd show {taskId}` returns task details, look for:
- `--notes` field: previous agent's status update
- `--assignee` field: who was working on this
- Dependencies: what tasks feed into this one

The notes field should contain OpenBrain search keywords left by the previous agent. Use those for targeted searches.

---

## For Non-Claude-Code Agents

This checklist is tool-agnostic. The core protocol is:

1. `bd dolt pull && bd prime` (shell command)
2. Search OpenBrain via MCP: `search_thoughts("[TASK {id}]")`
3. Read reference files (any file reader)
4. Check task state via bd (shell command)
5. Acknowledge context before coding

OpenBrain MCP is available from any tool that supports MCP servers. See AGENTS.md for connection details per tool.

---

## Remember

The goal is **zero re-derivation**. If a previous agent solved it, you should find it here. If you solve something new, capture it at session end with `/session-capture-checklist` so the next agent finds it here.

This is a closed loop: **consume at start, capture at end**. Both are mandatory. Breaking either side wastes everyone's time and tokens.
