---
name: session-capture-checklist
description: "Mandatory session capture checklist for OpenBrain with task-tagged structured captures. Run this skill WHENEVER: (1) Ending a session; (2) Handing off to another agent; (3) After solving a significant error; (4) Before marking work complete; (5) Before compaction. This skill ensures ALL errors, discoveries, environment issues, blockers, and handoff context are captured to OpenBrain with task ID tags so future agents can find them. Every capture MUST be tagged with the beads task ID. Never skip this — incomplete captures cause other agents to waste hours re-deriving solved problems."
---

# Session Capture Checklist for OpenBrain

This skill ensures that **every piece of important context** from your session gets captured to OpenBrain in a **structured, searchable format** with task ID tags, so any future agent on any tool can find it.

## Two Modes: Quick Capture vs Full Checklist

### Quick Capture (auto-triggered by context monitor or user request)

When the context monitor fires at 70%+ usage, or the user says "capture to OpenBrain", run a **quick capture** — not the full checklist:

1. Identify the current task ID from the most recent `bd` output or conversation context
2. Capture what's been done since the last capture:
   ```
   capture_thought("[TASK <id>] [PROGRESS] <date> — <what was accomplished since last capture, key decisions, any errors hit>")
   ```
3. If errors were solved, capture each one separately:
   ```
   capture_thought("[TASK <id>] [ERROR] <exact error, root cause, fix>")
   ```
4. Update beads notes: `bd update <id> --notes "PROGRESS: <summary>. OpenBrain: search [TASK <id>]"`
5. Done — resume work. No need for the full checklist categories.

**Quick capture takes 30 seconds.** It's designed to run frequently without disrupting flow. The full checklist below is for session end / handoff only.

---

### Full Checklist (session end, handoff, or major milestone)

Use the full checklist below when:
- Ending a session
- Handing off to another agent
- Context is above 80% and you need to wrap up
- Completing a major milestone

---

## Why This Matters

Real cost of skipped/incomplete captures:
- A discovery was known but not captured — next agent spent 2+ hours rediscovering it
- The correct package name was solved but poorly tagged — rediscovered in a different session
- A platform-specific bug fix was captured but without the task ID — hard to find when working on related tasks

The pattern: agents capture what they think is important, skip what seems minor, and use free-form text that's hard to search. This skill enforces structure.

---

## Critical Rule: Every Capture Gets a Task Tag

**Before capturing anything**, identify the beads task ID you're working on:

```bash
bd prime    # Shows current task state — find your task ID
```

**Every OpenBrain capture MUST start with a tag:**

```
[TASK {id}] [ERROR] Build failed — missing dependency in Cargo.toml
[TASK {id}] [DISCOVERY] API uses pagination with cursor tokens, not page numbers
[TASK {id}] [HANDOFF] Session complete — feature implemented, next: write tests
```

**Tag format:** `[TASK {id}]` followed by a category tag:

| Category | When to Use |
|----------|-------------|
| `[ERROR]` | Any error encountered (exact message, root cause, fix) |
| `[DISCOVERY]` | New finding about architecture, behavior, or environment |
| `[BLOCKER]` | Something that prevents progress (with workaround if any) |
| `[DECISION]` | Architectural or implementation choice made (with rationale) |
| `[ENVIRONMENT]` | Platform-specific finding (Windows vs macOS vs Linux, tool versions) |
| `[HANDOFF]` | End-of-session briefing for the next agent |

---

## The Checklist (All Categories Mandatory)

When you run this skill, go through EVERY category below. If a category has nothing to report, explicitly confirm "None this session." Do not skip categories silently.

### 1. Task Identification (MANDATORY)

- What task ID are you working on?
- What epic does it belong to?
- What's the current status (in_progress, blocked, complete)?

```
Task: {id} ({task title})
Epic: {epic-id} ({epic title})
Status: {status} — {brief description of where things stand}
```

### 2. Errors & Fixes (MANDATORY — capture ALL, even "minor" ones)

For EVERY error encountered this session, capture:

```
[TASK {id}] [ERROR] — {date}

Error: "{exact error message}"
Context: {what you were doing when the error occurred}
Root cause: {what actually caused the error}
Environment: {OS, tool versions, relevant config}
Fix applied: {what you did to fix it}
Status: Fixed / Workaround / Unresolved
```

**Rules:**
- Capture EXACT error messages, not paraphrases
- Include the file path where the error occurred
- Include what you tried AND why it failed (not just the final fix)
- "Minor" errors are mandatory — they compound across sessions

### 3. Discoveries (MANDATORY — capture everything you learned)

Anything you learned about the system, architecture, tools, or third-party services:

```
[TASK {id}] [DISCOVERY] — {date}

Finding: {what you discovered}
Detail: {full explanation}
Impact: {how this affects the project — "so what?"}
Files affected: {list of relevant files}
```

**Rules:**
- Include the practical impact ("so what?")
- List affected files
- If this discovery relates to documented reference files, note which ones

### 4. Environment Issues (MANDATORY)

Platform-specific findings that differ between environments:

```
[TASK {id}] [ENVIRONMENT] — {date}

Platform: {OS + tool versions}
Issue: {what's different or broken on this platform}
Detail: {full explanation}
Workaround: {how to work around it}
Impact: {what this means for development or deployment}
```

If no environment issues: state "No environment-specific issues this session."

### 5. Blockers (MANDATORY)

Anything preventing progress:

```
[TASK {id}] [BLOCKER] — {date}

Blocker: {what's blocking progress}
Status: {investigating / workaround found / unresolved}
Workaround: {temporary fix if any}
Next step: {what needs to happen to unblock}
```

If no blockers: state "No blockers this session."

### 6. Handoff Note (MANDATORY — always the last capture)

This is the most important capture. It's what the next agent reads first.

```
[TASK {id}] [HANDOFF] — {date}

Session summary: {1-2 sentences of what was accomplished}

What's working:
- {item} ✅
- {item} ✅

What's not working:
- {item} — {brief explanation}

Next agent should:
1. Search OpenBrain for "[TASK {id}]" to get full error history
2. {specific next step}
3. {specific next step}

Required reading:
- {file path}
- {file path}

Known issues to NOT re-debug:
- "{error}" — SOLVED ({brief fix})
```

---

## Capture Execution

### Path A: OpenBrain is available (normal)

First, verify the token is alive:

```
thought_stats()    # If this succeeds, proceed with Path A
```

Send each capture to OpenBrain:

```
capture_thought("[TASK {id}] [ERROR] ...")
capture_thought("[TASK {id}] [DISCOVERY] ...")
capture_thought("[TASK {id}] [HANDOFF] ...")
```

**Then update beads:**

```bash
bd update {taskId} --notes "COMPLETED: X. IN PROGRESS: Y. NEXT: Z. OpenBrain: search [TASK {id}]"
bd close {taskId} --reason "Done: description" --json    # If task is complete
```

**Then push:**

```bash
git pull --rebase && git push
bd dolt push
git status    # Must show "up to date with origin"
```

---

### Path B: OpenBrain token is expired (fallback)

If `thought_stats()` fails, first try: ask the user to re-auth in any Claude Code session, wait 1–2 minutes, and retry — no restart needed. The token is shared via the OS credential store and propagates automatically.

If it still fails after re-auth, do NOT lose the context. Write everything to a fallback markdown file instead:

**File:** `docs/session-capture-{YYYY-MM-DD}.md`

**Format:** Write each capture as its own section, exactly as you would have passed it to `capture_thought`. Use the same `[TASK {id}] [CATEGORY]` heading format so the import step can replay them:

```markdown
# Session Capture Fallback — {date}

**STATUS: PENDING IMPORT TO OPENBRAIN**
OpenBrain was unavailable during this session (token expired). Import this file at the
start of the next session using /session-start-checklist Step 0.

---

## Capture 1
[TASK {id}] [ERROR] — {date}

Error: "..."
...full content...

---

## Capture 2
[TASK {id}] [DISCOVERY] — {date}

Finding: ...
...full content...

---

## Capture N
[TASK {id}] [HANDOFF] — {date}
...full content...
```

**Then commit and push the fallback file:**

```bash
git add docs/session-capture-{date}.md
git commit -m "Session capture fallback {date} — pending OpenBrain import"
git push
bd dolt push
```

The `/session-start-checklist` Step 0 will detect this file at the next session start, import it to OpenBrain when the token is fresh, and delete it.

**Important:** Still update beads notes even if OpenBrain failed — beads does not depend on OpenBrain:

```bash
bd update {taskId} --notes "COMPLETED: X. NEXT: Y. OpenBrain: pending import from docs/session-capture-{date}.md"
```

---

## Verification

Before ending the session, verify:

**If OpenBrain was available (Path A):**
- [ ] `thought_stats()` confirmed token alive before capturing
- [ ] All errors captured with `[TASK {id}] [ERROR]` tag
- [ ] All discoveries captured with `[TASK {id}] [DISCOVERY]` tag
- [ ] Environment issues captured (or explicitly noted as "none")
- [ ] Blockers captured (or explicitly noted as "none")
- [ ] Handoff note captured with `[TASK {id}] [HANDOFF]` tag
- [ ] Beads task updated with notes
- [ ] Code committed and pushed
- [ ] `bd dolt push` completed

**If OpenBrain was unavailable (Path B fallback):**
- [ ] `docs/session-capture-{date}.md` written with all captures in structured format
- [ ] Fallback file committed and pushed to git
- [ ] Beads task updated with notes (references fallback file)
- [ ] `bd dolt push` completed
- [ ] Context is NOT lost — it will be imported next session via `/session-start-checklist` Step 0

---

## For Non-Claude-Code Agents

This checklist is tool-agnostic. The core protocol:

1. Identify task ID from `bd prime`
2. Capture to OpenBrain via MCP: `capture_thought("[TASK {id}] [CATEGORY] ...")`
3. Update beads: `bd update {id} --notes "..."`
4. Push code: `git push`
5. Push beads: `bd dolt push`

OpenBrain MCP is available from any tool that supports MCP servers. See AGENTS.md for connection details per tool.

---

## What NOT to Skip

These are the captures that seem minor but cause the biggest handoff failures:

- **"I figured out the right package name"** — capture it (agents will try the wrong one)
- **"The API uses a specific format"** — capture it (agents will assume the wrong format)
- **"This file path is important"** — capture it (agents won't know where to look)
- **"I tried X and it didn't work"** — capture it (agents will try X again)
- **"The error was misleading, the real cause was Y"** — capture it (agents will chase the misleading error)

When in doubt, capture it. The cost of over-capturing is near zero. The cost of under-capturing is hours of wasted work.
