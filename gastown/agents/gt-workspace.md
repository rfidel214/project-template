---

## OpenBrain Capture Protocol (Coordinator Agents Only)

OpenBrain (`capture_thought` MCP tool) is the shared memory layer across all sessions.
**Coordinator agents MUST capture to OpenBrain** at key lifecycle moments.

> **Polecats do NOT capture to OpenBrain.** Polecats are execution units — they code,
> commit, and submit to Refinery. Context capture is the responsibility of Mayor,
> Refinery, Deacon, and Witness. This is by design: coordinators have the full
> picture; polecats only see their own bead.

**Who captures:**

| Agent | Captures | Does NOT capture |
|-------|----------|-----------------|
| Mayor | Convoy decisions, escalations, handoffs | — |
| Refinery | Merge results, FIX_NEEDED reasons | — |
| Deacon | Health events, cross-rig escalations | — |
| Witness | Stuck agent recoveries | — |
| Flint (crew) | When doing direct user collaboration | — |
| Polecats | — | Everything — not their job |

OpenBrain MCP is configured in `~/.config/opencode/config.json` (server: `open-brain`).
Call it with: `capture_thought("<text>")`

### Required capture triggers (coordinators)

| Event | Category tag | Who |
|-------|-------------|-----|
| Key decision made | `[DECISION]` | Mayor, Refinery |
| Error hit and fixed | `[ERROR]` | Any coordinator |
| Non-obvious discovery | `[DISCOVERY]` | Any coordinator |
| Significant work completed | `[PROGRESS]` | Refinery, Mayor |
| Blocker encountered | `[BLOCKER]` | Any coordinator |
| Session ending | `[HANDOFF]` | Mayor |

### Format

```
capture_thought("[TASK <id>] [CATEGORY] YYYY-MM-DD - <summary>")
```

Use `[TASK gastown]` for Mayor/coordinator-level decisions.
Use `[TASK <bead-id>]` for bead-specific outcomes (Refinery merge/reject).

### Why OpenBrain over beads notes

Beads notes are short status strings. OpenBrain holds full structured reasoning:
error context, decision rationale, architectural discoveries, failure analysis.
Both matter. Neither replaces the other. Beads = what. OpenBrain = why + how.
