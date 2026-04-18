---
name: route
version: 0.1.0
description: Pre-flight workflow router. Asks 3-4 structured questions about a piece of work and recommends GAS_TOWN, OMO, or DEFAULT mode. Captures the routing decision to OpenBrain for later loop-tuning.
triggers:
  - before starting any non-trivial work session
  - when unsure whether work warrants a workflow
  - when a 20-minute trigger fires on an unrouted session
inputs:
  - work_description: one-line description of what you're about to do
outputs:
  - recommendation: GAS_TOWN | OMO | DEFAULT
  - confidence: HIGH | MEDIUM | LOW
  - reasoning: 2-3 sentences
  - suggested_bead_title (if workflow recommended)
  - suggested_system_tags (for Phase 1 OpenBrain query)
  - openbrain_capture: [ROUTE-DECISION] thought captured
---

# route — Pre-Flight Workflow Router

## Purpose

Decide which workflow (Gas Town, OMO, or Default mode) is appropriate
for a piece of work BEFORE starting it. Capture the decision so the
routing logic itself becomes a Karpathy loop target — over time, the
[ROUTE-DECISION] captures with actual-outcome fields filled in tell
you whether your routing questions are predictive or need tuning.

## When to invoke

Run `route "<one-line work description>"` before starting work that
feels like it might warrant a workflow. Skip for obviously-trivial
default-mode work (quick lookups, config tweaks, single questions).

If a 20-minute trigger fires on an unrouted session, stop and run
`route` retroactively — the question becomes "should I migrate what
I've done into OMO, or is this genuinely default-mode work?"

## When NOT to invoke

- One-off questions ("what does this error mean?")
- Lookups ("how do I do X in lib Y?")
- Config tweaks under 5 minutes
- Exploratory pokes where you don't yet know what you're looking for

These are default mode. Just open Claude and do the thing. No ceremony.

## The four questions

Ask in this order. Stop and recommend as soon as a strong signal fires.

### Q1 — Parallelism

> "Does this work split into independent pieces that could run in
> parallel by separate agents?"

- **Yes** → strong signal for GAS_TOWN. The whole point of convoy
  orchestration is parallel polecats with dependency tracking. If
  the work doesn't parallelize, Gas Town is overhead.
- **No** → continue to Q2.

### Q2 — Duration estimate

> "Best guess: how long will this take in focused work?"

- **< 20 min** → likely DEFAULT mode. Recommend skipping the workflow
  unless Q4 (trace value) overrides.
- **20–90 min** → OMO is the natural fit.
- **> 90 min OR unknown** → continue to Q3.

### Q3 — Coordination need

> "Does this work depend on outputs from other in-flight work, OR will
> other work depend on outputs from this?"

- **Yes** → GAS_TOWN. The dependency graph IS the value of the convoy.
  An OMO session can't coordinate with parallel work.
- **No** → OMO. Long-running serial work is exactly OMO's strength
  when context discipline matters.

### Q4 — Trace value (override question)

> "If you got stuck halfway, would the reasoning trace be valuable to
> a future session?"

- **Yes** → workflow required. Use OMO at minimum (or GAS_TOWN per
  Q1/Q3). Even short work earns a workflow if the reasoning compounds.
- **No, this is throwaway exploration** → DEFAULT mode is fine even
  if duration creeps past 20 min.

## Output format

```
ROUTE RECOMMENDATION
====================
Workflow:     [GAS_TOWN | OMO | DEFAULT]
Confidence:   [HIGH | MEDIUM | LOW]

Reasoning:
  <2-3 sentences explaining the recommendation based on which
   questions fired and why>

Suggested bead title:    <only if GAS_TOWN or OMO recommended>
Suggested system tags:   <comma-separated, used for Phase 1 OpenBrain
                          context query at session start>

Captured to OpenBrain:   [ROUTE-DECISION] <work-description>
```

## Confidence rules

- **HIGH** — A single question fired strongly (Q1 yes, Q3 yes, or Q4
  no with Q2 < 20 min).
- **MEDIUM** — Multiple questions contributed, no single dominant signal.
- **LOW** — Borderline case, multiple questions ambiguous.

If confidence is LOW, append this prompt to the output:

> "This is borderline. Default to OMO unless you're sure parallelism
> is needed — parallelism is the genuine differentiator for GAS_TOWN.
> Default to DEFAULT mode only if you're sure the trace value is zero."

## OpenBrain capture (mandatory)

Every invocation of `route` captures a thought, regardless of outcome:

```
[ROUTE-DECISION] <work-description>
- Workflow chosen: <GAS_TOWN | OMO | DEFAULT>
- Confidence: <HIGH | MEDIUM | LOW>
- Reasoning: <why this routing>
- Suggested bead title: <if applicable>
- Suggested system tags: <if applicable>
- Actual outcome: PENDING — fill in at session end
SEARCH TAGS: routing, route-decision, <workflow-chosen>, <work-domain-tag>
```

The `Actual outcome: PENDING` field is the critical loop-closing piece.
At session end (for routed work, via Superpowers' session-exit-reflect)
or at next-day review (for default mode), update this capture with:

- "Routing was correct" — work fit the chosen mode well
- "Should have been <other workflow>" — routing was wrong, with reason
- "Mode boundaries unclear" — work spanned categories

After ~20 [ROUTE-DECISION] captures with actual-outcome filled in,
run a Reflector pass to find patterns:
- Are certain work-domain-tags consistently mis-routed?
- Is the < 20 min threshold too low or too high?
- Are there question categories missing (e.g., "involves external
  service that might fail" might be a useful Q5)?

That's the Karpathy loop on the routing skill itself.

## Examples

### Example 1: Clear OMO

```
> route "refactor the MoldKit Decompose step to use streaming output"

Q1: Parallelism? No — this is one focused refactor on one file.
Q2: Duration? ~45 min.
Q3: Skipped (Q2 answered).
Q4: Trace value? Yes — if I get stuck on streaming edge cases,
    the reasoning will help next session.

ROUTE RECOMMENDATION
====================
Workflow:     OMO
Confidence:   HIGH

Reasoning:
  Single-agent serial refactor, ~45 min duration, with clear trace
  value if streaming edge cases cause issues. No parallelism, no
  cross-agent coordination needed.

Suggested bead title:    Refactor MoldKit Decompose step to streaming output
Suggested system tags:   moldkit, decompose, streaming, claude-haiku

Captured to OpenBrain:   [ROUTE-DECISION] refactor MoldKit Decompose to streaming
```

### Example 2: Clear GAS_TOWN

```
> route "update Cortex MSP onboarding docs across 4 client tiers
         and regenerate the deployment scripts for each"

Q1: Parallelism? Yes — 4 tiers can be updated independently, and
    deployment script regeneration parallelizes per tier.

ROUTE RECOMMENDATION
====================
Workflow:     GAS_TOWN
Confidence:   HIGH

Reasoning:
  Work splits into 4+ independent units that can run as parallel
  polecats. Convoy orchestration adds value through dependency
  tracking (script regen depends on doc update per tier).

Suggested bead title:    Cortex tier docs + deployment script regen
Suggested system tags:   cortex, msp, onboarding, tiers, deployment

Captured to OpenBrain:   [ROUTE-DECISION] Cortex tier docs + script regen
```

### Example 3: DEFAULT mode

```
> route "figure out why my Hetzner Dolt port keeps timing out"

Q1: Parallelism? No.
Q2: Duration? Unknown — debugging.
Q3: Coordination? No.
Q4: Trace value? Maybe — if I find the cause, it's worth a
    one-line OpenBrain capture, but the debugging itself is
    exploratory.

ROUTE RECOMMENDATION
====================
Workflow:     DEFAULT
Confidence:   MEDIUM

Reasoning:
  Exploratory debugging with unclear duration. No parallelism or
  coordination. Trace value is conditional on finding the cause —
  if you do, capture a one-line [OBSERVATION] to OpenBrain at the
  end. Otherwise default mode is appropriate.

Note: If 20-min trigger fires and you're still debugging, re-route.
You may have found enough structure that OMO becomes appropriate.

Captured to OpenBrain:   [ROUTE-DECISION] Hetzner Dolt port timeout debug
```

### Example 4: LOW confidence borderline

```
> route "add a couple of validation checks to the gt doctor CSV parser"

Q1: Parallelism? No.
Q2: Duration? 15-30 min, hard to say.
Q3: Coordination? No.
Q4: Trace value? Maybe — depends on whether the CSV bug is
    weirder than expected.

ROUTE RECOMMENDATION
====================
Workflow:     OMO
Confidence:   LOW

Reasoning:
  Borderline between DEFAULT and OMO. Duration straddles the
  threshold. Trace value is conditional. Defaulting to OMO since
  parallelism isn't a factor — better to have a trace you don't
  need than miss a trace you do.

Suggested bead title:    gt doctor CSV parser validation hardening
Suggested system tags:   gas-town, gt-doctor, csv-parser, validation

This is borderline. Default to OMO unless you're sure parallelism
is needed — parallelism is the genuine differentiator for GAS_TOWN.
Default to DEFAULT mode only if you're sure the trace value is zero.

Captured to OpenBrain:   [ROUTE-DECISION] gt doctor CSV parser validation
```

## Karpathy triplet for the route skill itself

This skill is a loop target:

- **Editable surface:** this SKILL.md file (the four questions, the
  confidence rules, the output format)
- **Metric:** % of [ROUTE-DECISION] captures whose actual-outcome
  field reads "Routing was correct"
- **Time budget:** route invocation completes in under 60 seconds

If the metric climbs over the first month, the questions are
predictive. If it stays flat or drops, the questions need revision —
add Q5, swap thresholds, or restructure the decision tree.

## Failure modes to watch

1. **Default-mode escape hatch** — if `route` consistently outputs
   DEFAULT, check whether the trace-value question is being
   under-weighted. The bias should be slightly toward routing,
   not away from it.

2. **Routing without commitment** — if you run `route`, get an
   OMO recommendation, and then proceed in default mode anyway,
   the skill is overhead without value. Either trust the output
   or change the questions.

3. **Routing fatigue** — if invoking `route` feels heavy, the
   questions are too long. Tighten them. The whole skill should
   complete in under a minute.

4. **Mid-session re-routing** — if you find yourself running
   `route` mid-session because the work changed shape, that's
   useful signal. Capture it in the actual-outcome field
   ("re-routed mid-session, started DEFAULT, migrated to OMO
   at minute 25").
