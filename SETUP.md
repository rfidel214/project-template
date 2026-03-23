# Project Setup — Read This First

This repo was created from a project template. You are an AI agent. Your job is to customize this template for the specific project and then delete this file.

**Do not write any code until setup is complete.**

See `docs/examples/` for a fully completed AGENTS.md and CLAUDE.md from a real project (MoldKit).

---

## Context You Need

Before filling anything in, gather context from these sources **in order**:

### 1. Query Open Brain (start here)

Search for prior context about this project — decisions, architecture notes, research findings, and handoffs from previous sessions may already exist:

```
search_thoughts("{{PROJECT_NAME}}")
search_thoughts("architecture decisions")
search_thoughts("tech stack")
list_thoughts()
```

If this is a brand new project with no prior OpenBrain context, proceed to the next step.

### 2. Ask the user

Fill any gaps OpenBrain didn't answer:

1. What does this project do? (1-2 sentences)
2. What problem does it solve? What's unique about it?
3. What's the tech stack? (language, frameworks, databases, infra)
4. What phase is it in? (idea, validation, alpha, production)
5. What are the 2-3 most important architectural decisions already made?
6. What should agents NOT do? (constraints, off-limits tools, anti-patterns)
7. What's the Open Brain MCP URL for this user/project?

### 3. Read any existing docs

If there are PRDs, spec files, or design docs already in this repo or linked by the user, read them before filling in AGENTS.md. They are the authoritative source for the Important Decisions and Architecture sections.

---

## Steps

### Step 1. Fill in AGENTS.md

Replace every `{{PLACEHOLDER}}` with real content. The placeholders are:

| Placeholder | What to put there |
|---|---|
| `{{PROJECT_NAME}}` | The project's name |
| `{{SHORT_TAGLINE}}` | 5-8 word description (e.g. "AI-Powered Design-to-Builder Conversion Platform") |
| Project Overview block | 2-4 sentences: what, who, unique value |
| `{{domain.tld}}` | Project domain if known, otherwise remove the line |
| `{{Current Phase}}` | e.g. "Phase 0 Validation", "v1 Alpha", "Production" |
| `{{Edition}}` | e.g. "Personal Edition first, then SaaS" |
| Tech Stack table | Fill every row; delete placeholder rows |
| Architecture section | Replace with the actual architecture (pipeline, layers, data flow) |
| Key Files table | Real files that exist or will exist |
| Code Style Preferences | Project-specific rules; keep universals, add project ones |
| Important Decisions | Real decisions already made; query user if unsure |
| What NOT to Do | Real constraints; always keep the Beads rules |
| `{{OPEN_BRAIN_MCP_URL}}` | The user's Open Brain MCP endpoint URL |

### Step 2. Fill in CLAUDE.md

Replace `{{PROJECT_NAME}}` at the top. Everything else stays as-is — `bd setup claude` will append the beads block automatically.

### Step 3. Fill in README.md

Replace all `{{PLACEHOLDER}}` values. Delete any table rows that don't apply yet (documents, scripts, results tables can start empty).

For badges, replace:
- `{{STATUS}}` / `{{STATUS_COLOR}}` — e.g. `active` / `green`, `wip` / `yellow`, `archived` / `red`
- `{{PHASE}}` — e.g. `validation`, `alpha`, `v1`
- `{{GITHUB_USER}}` / `{{REPO_NAME}}` — GitHub username and repo slug

### Step 4. Initialize Beads

```bash
bd init
bd setup claude
```

This wires up SessionStart and PreCompact hooks in Claude Code, and appends the beads integration block to CLAUDE.md.

### Step 5. Create the first issues

Based on what you now know about the project, create at least 3 beads issues for the next chunk of real work:

```bash
bd create "{{FIRST_TASK}}" -t task -p 1
bd create "{{SECOND_TASK}}" -t task -p 2
```

### Step 6. Push to GitHub

Create the remote repo and push:

```bash
# Create the GitHub repo (choose public or private)
gh repo create {{GITHUB_USER}}/{{REPO_NAME}} --public --source=. --remote=origin
# OR if you created the repo manually on GitHub:
git remote add origin https://github.com/{{GITHUB_USER}}/{{REPO_NAME}}.git

# Push
git pull --rebase
git push -u origin main
git status   # must show "up to date with origin"
```

### Step 7. Capture initial context to Open Brain

Capture a project initialization thought so future agents have immediate context:

```
capture_thought("[PROJECT {{PROJECT_NAME}}] [DISCOVERY] Project initialized from template. Stack: {{STACK_SUMMARY}}. Phase: {{PHASE}}. Key decisions: {{DECISIONS_SUMMARY}}. Repo: https://github.com/{{GITHUB_USER}}/{{REPO_NAME}}")
```

### Step 8. Delete this file

```bash
git rm SETUP.md
git commit -m "chore: complete template setup, remove SETUP.md"
git push
bd dolt push
```

---

## Done

When SETUP.md is gone, everything is pushed, and the initial OpenBrain capture is done — the project is ready for normal agent workflow. Use `bd prime` to start every future session.
