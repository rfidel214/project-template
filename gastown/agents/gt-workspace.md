---

## OpenBrain Capture Protocol — Tiered Write Policy

OpenBrain (`capture_thought` / `search_thoughts` MCP tools) is the shared knowledge layer
across all agents and sessions. Write access is role-gated — not all agents capture.

OpenBrain MCP is configured in `~/.config/opencode/config.json` (server: `open-brain`).
Claude Code agents use the MCP tool natively. OpenCode agents use the remote MCP URL.

### Who captures what

| Role | Write Access | Trigger | Do NOT capture |
|------|-------------|---------|----------------|
| **Mayor** | Full | Convoy formation, escalation received, session handoff | Routine status pings |
| **Flint (crew)** | Full | Design decisions, discoveries, session end | -- |
| **Refinery** | Conditional | FIX_NEEDED events ONLY (merge failures) | Routine successful merges |
| **Deacon** | Conditional | Same failure type 3+ times in one patrol session | Individual transient events |
| **Witness** | Read only | Query known failure patterns at patrol start | Never writes |
| **Polecats** | None | Exception: `gt escalate` auto-captures via Mayor | Everything else |
| **Dogs** | None | Infrastructure workers -- no synthesis capability | Everything |

### Capture format

```
capture_thought("[TASK <id>] [CATEGORY] YYYY-MM-DD - <summary>")
```

Use `[TASK gastown]` for Mayor/coordinator-level decisions.
Use `[TASK <bead-id>]` for bead-specific work (e.g. `[TASK hq-cv-v3u4i]`).

Category tags: `[DECISION]` `[ERROR]` `[DISCOVERY]` `[PROGRESS]` `[BLOCKER]` `[HANDOFF]`

### Capture ownership

- **Polecats** are execution units. They code, commit, and call `gt done`. Context capture
  is handled by coordinator agents who have full system visibility.
- **Do NOT capture to OpenBrain** from polecat sessions — the Mayor synthesizes convoy
  outcomes, Refinery captures merge failures, Deacon captures systemic patterns.
- The one exception: `gt escalate` sends the escalation to Mayor, who captures it.

### Rationale

Polecats lack project-level context to distinguish signal from noise. Their execution
traces pollute the semantic space. Knowledge flows upward: Refinery captures merge
failures, Deacon captures systemic patterns, Mayor synthesizes convoy outcomes.
Witness queries OpenBrain at patrol start to make smarter recovery decisions -- it reads
known failure patterns without writing new noise.

Beads = what (task state). OpenBrain = why + how (reasoning, patterns, decisions).
