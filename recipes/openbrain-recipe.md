# OpenBrain Recipe — Project Template

This is the text to capture to OpenBrain so any agent can find and use the template.

## Capture Text

```
[RECIPE] Project Template Generator — bootstraps new repos with AI agent workflow infrastructure.

Repo: github.com/rfidel214/project-template
Usage: git clone https://github.com/rfidel214/project-template.git /tmp/pt && bash /tmp/pt/bootstrap.sh

What it creates:
- AGENTS.md (single source of truth for all AI tools — OpenCode, KiloCode, Codex, Claude Code)
- CLAUDE.md (redirect to AGENTS.md for Claude Code)
- .claude/skills/ (session-start-checklist, session-capture-checklist)
- .claude/settings.local.json (bd + git permissions)
- Tool-specific skill directories with symlinks (.opencode/, .kilocode/, .agents/)
- .beads/ task tracker (bd init)
- .gitignore (language-aware — Rust, Node, Python, Go)
- docs/ directory for specifications

Supports: Claude Code, OpenCode, KiloCode, Codex CLI
Requires: bd (beads), Open Brain MCP, git

Bootstrap flow:
1. Clone the template repo
2. Run bootstrap.sh (interactive — prompts for project name, language, tools)
3. Customize AGENTS.md sections for your project
4. Create GitHub repo: gh repo create <name> --source=. --push
5. Run bd setup claude (or equivalent for your tool)

Key pattern: Skills live in .claude/skills/ as canonical, symlinked to other tool dirs (.opencode/skills/, .kilocode/skills/, .agents/skills/).
Global hooks (SessionStart, PreCompact, Stop) must be configured per-tool — see AGENTS.md Tool-Specific Setup section.

Template is language/framework agnostic — generator prompts for tech stack and creates appropriate .gitignore and code style defaults.
```
