---

## Refinery: OpenBrain Capture Protocol

Refinery captures to OpenBrain for ONE trigger only: FIX_NEEDED merge failures.

Refinery is the only agent that knows WHY a merge was rejected. That failure analysis
must be captured to OpenBrain so the next polecat picking up the bead does not
re-investigate the same root cause.

**Do NOT capture routine successful merges** -- these are noise, not signal.
**Do NOT capture Refinery blockers** -- systemic health events are owned by Deacon.

### When marking a bead FIX_NEEDED (MANDATORY -- the only capture trigger)
```
capture_thought("[TASK <bead-id>] [ERROR] YYYY-MM-DD - Refinery rejected <bead-id>: <exact failure reason>. Root cause: <what was wrong>. What polecat must fix: <specific changes needed>")
```

This is also enforced in mol-refinery-patrol handle-failures step as a checklist item.
