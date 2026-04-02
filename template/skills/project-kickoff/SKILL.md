---
name: project-kickoff
description: "Project classification and toolchain routing. Run this skill at the START of any new project or major feature — before writing any code, creating any beads, or choosing any tools. It asks 4 questions and outputs the exact recommended toolchain sequence for your specific situation. Prevents defaulting to Gas Town for solo work or raw Claude Code for high-risk changes."
---

# Project Kickoff — Toolchain Decision Framework

This skill exists because **the entry point changes everything**. The same codebase, different task size, means a completely different toolchain. Defaulting to your most familiar tool wastes time on small tasks and creates unacceptable risk on large ones.

Run this before every project or major feature. It takes 2 minutes and saves hours.

---

## Step 1 — Answer the 4 Trigger Questions

Ask the user (or reason through yourself if operating autonomously):

### Q1: What's the starting point?
- **A)** New idea, no code exists yet
- **B)** Existing repo

### Q2: How many files/components will be affected?
- **A)** Fewer than 5 files
- **B)** 5–20 files
- **C)** More than 20 files, or a whole new product

### Q3: What's the risk if this goes wrong?
- **A)** Fully isolated — touches nothing in prod or shared systems
- **B)** Medium — touches prod but can be reverted
- **C)** High — touches shared infrastructure, databases, or external APIs

### Q4: How many independent workstreams are needed?
- **A)** One agent, sequential work
- **B)** Multiple agents working in parallel

---

## Step 2 — Route to the Right Toolchain

### PATH 1 — New idea, no code yet
**Trigger:** Q1 = A (any other answers)

```
/office-hours              ← YC partner mode: validate the idea, kill bad assumptions
/plan-ceo-review           ← Founder mode: scope, prioritization, what NOT to build
/plan-design-review        ← Designer's eye: UX, flows, visual direction
/plan-eng-review           ← Eng manager: architecture, risks, phase sequencing
  → Decision point: OMO or Gas Town? (see below)
```

**Decision point — OMO vs Gas Town:**
- Single developer building solo → **OMO in worktree**
- Multiple parallel agents needed → **Gas Town**

---

### PATH 2 — Existing repo, quick fix
**Trigger:** Q1 = B, Q2 = A, Q3 = A or B

```
Claude Code directly        ← No planning overhead needed
  → implement
  → /verification-before-completion   ← Superpowers gate
  → git push
```

No gstack. No OMO. No Gas Town. Just do it.

---

### PATH 3 — Existing repo, medium project
**Trigger:** Q1 = B, Q2 = B, Q3 = A or B, Q4 = A

```
/plan-eng-review            ← gstack: validate technical approach, catch risks
/writing-plans              ← Superpowers: formalize plan for OMO consumption
  → OMO in git worktree     ← execute in isolation (feat/xxx branch)
    /verification-before-completion   ← gate each phase before proceeding
    /requesting-code-review           ← spec compliance check
    /receiving-code-review            ← code quality check
  → /finishing-a-development-branch   ← final merge gate
  → merge to master
→ capture to OpenBrain
```

**Real example:** cortex-web Next.js migration (~15 files, medium risk, single agent) → Path 3.

---

### PATH 4 — Existing repo, large feature
**Trigger:** Q1 = B, Q2 = C, Q3 = B or C, Q4 = A

```
/autoplan                   ← gstack full pipeline: CEO + design + eng review
/writing-plans              ← Superpowers: formalize
  → OMO in git worktree     ← execute
    /test-driven-development          ← write tests first
    /verification-before-completion   ← gate each phase
    /requesting-code-review + /receiving-code-review
  → /finishing-a-development-branch
  → merge
→ consider Gas Town if parallel workstreams emerge mid-project
```

---

### PATH 5 — Parallel workstreams (any size)
**Trigger:** Q4 = B

```
Gas Town convoy             ← Mayor + polecats + Refinery
```

Gas Town is the right tool when:
- 3+ independent tasks can run simultaneously
- Work is too large for one agent to hold in context
- You need a Refinery review gate between polecats

---

## Step 3 — Output the Sequence

After routing, output a clean checklist the user can follow:

```
PROJECT: [name]
PATH: [1/2/3/4/5] — [label]
BRANCH: [branch name if applicable]

SEQUENCE:
[ ] Step 1: [tool/skill]
[ ] Step 2: [tool/skill]
[ ] Step 3: [tool/skill]
...

RISK FLAGS:
- [Any specific risks identified from Q3 answers]

CAPTURE TO OPENBRAIN:
- After completion, capture: what worked, what broke, decisions made
```

---

## Toolchain Reference

| Tool | Owns | When |
|------|------|------|
| gstack `/office-hours` | Idea validation | New idea, pre-code |
| gstack `/plan-*-review` | Plan validation | Before any build |
| gstack `/autoplan` | Full plan pipeline | Large or high-risk work |
| Superpowers `/writing-plans` | Plan formalization | Before OMO |
| Superpowers `/test-driven-development` | Tests first | Any feature/fix |
| Superpowers `/verification-before-completion` | Phase gates | Every phase |
| Superpowers `/requesting-code-review` | Spec compliance | After implementation |
| Superpowers `/receiving-code-review` | Quality check | After spec passes |
| Superpowers `/finishing-a-development-branch` | Merge gate | Before merging |
| OMO in worktree | Execution | Medium/large, single agent |
| Gas Town | Parallel execution | Multi-agent, convoy scale |

---

## Anti-Patterns to Avoid

- **Don't default to Gas Town** for solo single-agent work — OMO is right
- **Don't skip gstack** for anything touching prod — at minimum run `/plan-eng-review`
- **Don't use raw Claude Code** for 20+ file changes without a worktree
- **Don't skip OpenBrain capture** — every run builds institutional knowledge
- **Don't run full `/autoplan`** for a 3-file bug fix — overhead kills momentum
