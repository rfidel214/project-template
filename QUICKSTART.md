# New Project Cheat Sheet

## Step 1: Bootstrap

```bash
git clone https://github.com/rfidel214/project-template.git /tmp/pt
bash /tmp/pt/bootstrap.sh
```

Follow the prompts (project name, language, tools). Output goes to a new directory.

## Step 2: Customize

Open `AGENTS.md` and fill in:
- [ ] Tech Stack table
- [ ] Architecture section
- [ ] Key Files table
- [ ] Code Style (defaults provided based on language choice)
- [ ] Testing Policy (defaults provided)
- [ ] Important Decisions (add as you go)
- [ ] What NOT to Do (add project-specific rules)

## Step 3: Push to GitHub

```bash
cd your-project
git add -A && git commit -m "Initial project setup"
gh repo create your-repo-name --source=. --push
```

## Step 4: Configure Tools

```bash
# Beads — set up DoltHub remote
bd dolt remote add origin <your-dolthub-remote>

# Claude Code — install hooks
bd setup claude

# OpenCode / KiloCode — add MCP config
# See AGENTS.md → Tool-Specific Setup section
```

## Step 5: Start Working

Open your AI coding tool and say:
> "Run /session-start-checklist"

Or if the tool doesn't support skills, tell it:
> "Read AGENTS.md, run bd dolt pull && bd prime, search OpenBrain for this project"

---

## From Inside Any AI Agent

If you're already in a session and want to bootstrap a new project, just say:

> "Search OpenBrain for [RECIPE] project template and follow the instructions to create a new repo called ___"

The agent will find the recipe and run the bootstrap for you.

---

## What You Get

```
your-project/
├── AGENTS.md              ← Edit this (your project's brain)
├── CLAUDE.md              ← Auto-redirect, don't touch
├── .gitignore             ← Language-aware, ready to go
├── docs/                  ← Put specs here
├── .beads/                ← Task tracking (bd commands)
├── .claude/skills/        ← Session skills (canonical)
├── .opencode/skills/      ← Symlinked ↑
├── .kilocode/skills/      ← Symlinked ↑
└── .agents/skills/        ← Symlinked ↑ (Codex)
```

## Daily Workflow

| When | Do |
|------|-----|
| Start session | `/session-start-checklist` |
| Find work | `bd ready` |
| Claim task | `bd update <id> --claim` |
| Finish task | `bd close <id>` + capture to OpenBrain |
| End session | `/session-capture-checklist` then `git push` |
