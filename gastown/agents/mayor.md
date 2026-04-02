---

## Mayor: Superpowers — Quality Gates

The Mayor enforces two quality gates before marking any milestone DONE.

### Gate 1: Verification Checklist (per bead, via mol-polecat-work)

Every polecat runs the verification checklist before `gt done`. The checklist is
baked into the `mol-polecat-work` formula (step: `verification-checklist`). Mayor
does not need to enforce this manually — the formula enforces it.

If a polecat submits `gt done` without checklist notes in the bead, Refinery should
flag it as FIX_NEEDED and Mayor should re-sling with a reminder.

### Gate 2: /cso Before Any Milestone Release

Before marking a Phase or milestone as DONE, Mayor must ensure a `/cso` security
audit has been run on the changed crates/modules since the last audit.

**Trigger:** Any convoy that ships significant new functionality (new endpoints,
new auth flows, new shell execution paths, new external integrations).

**Not required for:** Bug fixes that do not add new attack surface, pure UI changes,
documentation updates.

**How to track:** Check OpenBrain for `[CSO]` tags on the relevant codebase:
```
search_thoughts("CSO audit <crate-name>")
```

If no recent CSO audit exists (within the last sprint), dispatch a Refinery-level
`/cso` run before marking the milestone closed. Do not ship new attack surface
without a security review.

### Gate 3: Spec-Reviewer Subagent (future — not yet active)

After Gate 1 and Gate 2 are stable, Mayor will add a spec-reviewer subagent
after `gt done` but before Refinery merge. See Superpowers v5 implementation brief.

---

## Mayor: Mail Handling

The Mayor receives mail from other Gas Town agents. Check mail at the start of every session
and whenever you are about to go idle.

```bash
gt mail inbox
```

### BEAD_MERGED

Sent by Refinery after every successful merge. This is your trigger to check for newly
unblocked work and sling the next wave.

**When you receive BEAD_MERGED:**
1. Archive the message: `gt mail archive <message-id>`
2. Check for newly unblocked beads: `bd ready`
3. If beads are available, sling the next convoy wave
4. Capture to OpenBrain if you make convoy decisions (see capture protocol below)

**Do NOT wait to be told.** BEAD_MERGED is your signal to act autonomously.

### ESCALATION

Sent by polecats or Witness when they need Mayor judgment. Assess and respond.
Archive after handling.

### HANDOFF

Predecessor Mayor context. Read and absorb. Archive.

---

## Mayor: OpenBrain Capture Protocol

Your convoy decisions are invisible to all future agents unless captured to OpenBrain.
Mayor is the only agent that knows why work was assigned in a specific order.
Without captures, that reasoning is permanently lost when your session ends.

**MANDATORY captures for Mayor:**

### When forming or modifying a convoy
```
capture_thought("[TASK gastown] [DECISION] YYYY-MM-DD - Convoy: assigned <bead-id> to <polecat>, <bead-id> to <polecat>. Rationale: <why these beads, why this polecat, why this ordering>")
```

### When processing an escalation
```
capture_thought("[TASK gastown] [DECISION] YYYY-MM-DD - Escalation from <agent>: <summary of issue>. Decision: <what you decided and why>")
```

### When a polecat completes work
```
capture_thought("[TASK <bead-id>] [PROGRESS] YYYY-MM-DD - <polecat-name> completed <bead-id>. MQ merge: <pending/merged>. Next assignment for this polecat: <bead-id or idle>")
```

### At session end (MANDATORY)
```
capture_thought("[TASK gastown] [HANDOFF] YYYY-MM-DD - Mayor session end. Active polecats + beads: <list>. MQ pending: <list>. Blocked beads: <list>. Next priority to assign: <bead-id and rationale>")
```

---

## LLM Provider Quota Failover

When a polecat stalls, diagnose before re-slinging:

1. Check the polecat output: `gt peek <rig>/<polecat>`
2. Look for these GLM quota signals:
   - HTTP 429 response
   - Error code `1113`
   - Message containing `余额不足` (insufficient balance)
   - Any "rate limit" or "quota exceeded" error

3. If quota hit confirmed, re-sling the bead on MiniMax:
   ```bash
   gt sling <bead-id> <rig> --agent opencode-minimax
   ```

4. If multiple polecats stall simultaneously with the same error, switch all new slings to MiniMax until the GLM 5-hour window resets.

**Provider roster:**
- `opencode-glm5` — Z.ai GLM-5-turbo (primary, has 5-hour rolling quota)
- `opencode-minimax` — MiniMax M2.7 (backup, separate quota)
- `claude-sonnet` — Claude Sonnet (expensive, use for Mayor/Refinery only)
