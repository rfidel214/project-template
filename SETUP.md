# Project Setup — Read This First

This repo was created from a project template. You are an AI agent. Your job is to customize this template for the specific project and then delete this file.

**Do not write any code until setup is complete.**

---

## Context You Need

Before filling anything in, ask the user (or read existing files/notes) to understand:

1. What does this project do? (1-2 sentences)
2. What problem does it solve? What's unique about it?
3. What's the tech stack? (language, frameworks, databases, infra)
4. What phase is it in? (idea, validation, alpha, production)
5. What are the 2-3 most important architectural decisions already made?
6. What should agents NOT do? (constraints, off-limits tools, anti-patterns)
7. What's the Open Brain MCP URL for this user/project?

---

## Steps

### 1. Fill in AGENTS.md

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

### 2. Fill in CLAUDE.md

Replace `{{PROJECT_NAME}}` at the top. Everything else stays as-is — `bd setup claude` will append the beads block automatically.

### 3. Fill in README.md

Replace all `{{PLACEHOLDER}}` values. Delete any table rows that don't apply yet (documents, scripts, results tables can start empty).

For badges, replace:
- `{{STATUS}}` / `{{STATUS_COLOR}}` — e.g. `active` / `green`, `wip` / `yellow`, `archived` / `red`
- `{{PHASE}}` — e.g. `validation`, `alpha`, `v1`
- `{{GITHUB_USER}}` / `{{REPO_NAME}}` — GitHub username and repo slug

### 4. Initialize Beads

```bash
bd init
bd setup claude
```

This wires up SessionStart and PreCompact hooks in Claude Code, and appends the beads integration block to CLAUDE.md.

### 5. Create the first issues

Based on what you now know about the project, create at least 3 beads issues for the next chunk of real work:

```bash
bd create "{{FIRST_TASK}}" -t task -p 1
bd create "{{SECOND_TASK}}" -t task -p 2
```

### 6. Initial commit

```bash
git add CLAUDE.md AGENTS.md README.md .gitignore .claude/
git commit -m "chore: initialize project from template"
git push
```

### 7. Delete this file

```bash
git rm SETUP.md
git commit -m "chore: complete template setup, remove SETUP.md"
git push
```

---

## Done

When SETUP.md is gone and everything is pushed, the project is ready for normal agent workflow. Use `bd prime` to start every future session.
