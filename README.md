# Project Template

Bootstrap new repos with AI agent workflow infrastructure. Creates a complete development environment with session management, task tracking, and cross-tool compatibility.

## What You Get

- **AGENTS.md** — single source of truth for all AI coding tools
- **Session skills** — start-of-session context consumption + end-of-session capture checklists
- **Beads integration** — `bd` task tracking with Dolt-backed dependency graphs
- **OpenBrain memory** — persistent knowledge layer across sessions and agents
- **Cross-tool support** — native skill/rule files for Claude Code, OpenCode, KiloCode, and Codex CLI

## Prerequisites

- **git** — version control
- **[bd (beads)](https://github.com/joshka/beads)** — task tracking CLI
- **[Open Brain](https://openbrain.app)** — MCP-based memory (optional but recommended)
- One or more AI coding tools: Claude Code, OpenCode, KiloCode, Codex CLI

## Quick Start

```bash
git clone https://github.com/rfidel214/project-template.git /tmp/project-template
bash /tmp/project-template/bootstrap.sh
```

The script will prompt for:
1. Project name and description
2. Primary language (Rust, Node, Python, Go, or other)
3. Target platforms (Windows, macOS, Linux)
4. Which AI coding tools you use
5. OpenBrain MCP URL (optional)

## What Gets Created

```
your-project/
├── AGENTS.md                          # Agent instructions (all tools read this)
├── CLAUDE.md                          # Claude Code entrypoint → AGENTS.md
├── .gitignore                         # Language-aware patterns
├── docs/                              # Specification documents
├── .beads/                            # Task tracking database
├── .claude/
│   ├── settings.local.json            # Permissions (bd + git)
│   └── skills/
│       ├── session-start-checklist/   # Context consumption protocol
│       └── session-capture-checklist/ # Session capture protocol
├── .opencode/skills/                  # Symlinked → .claude/skills/
├── .kilocode/skills/                  # Symlinked → .claude/skills/
└── .agents/skills/                    # Symlinked → .claude/skills/ (Codex)
```

## Tool Compatibility

| Tool | Instructions | Skills | Hooks |
|------|-------------|--------|-------|
| Claude Code | CLAUDE.md → AGENTS.md | `.claude/skills/` | Full (SessionStart, PreCompact) |
| OpenCode | AGENTS.md (native) | `.opencode/skills/` | Plugin system |
| KiloCode | AGENTS.md (via rules) | `.kilocode/skills/` | Manual (follows AGENTS.md) |
| Codex CLI | AGENTS.md (native) | `.agents/skills/` | Manual (follows AGENTS.md) |

## After Bootstrap

1. **Customize AGENTS.md** — fill in tech stack, architecture, code style, and testing sections
2. **Set up hooks** — run `bd setup claude` (or equivalent for your tool)
3. **Create GitHub repo** — `gh repo create <name> --source=. --push`
4. **Start working** — run `/session-start-checklist` in your AI tool

## The Workflow Loop

```
Session Start                    Session End
     │                                │
     ▼                                ▼
/session-start-checklist     /session-capture-checklist
     │                                │
     ├── bd dolt pull                 ├── Capture errors to OpenBrain
     ├── bd prime                     ├── Capture discoveries
     ├── Search OpenBrain             ├── Write handoff note
     ├── Read reference files         ├── Update beads
     └── Set up context monitor       ├── git push
                                      └── bd dolt push
```

## Cross-Platform

The bootstrap script works on macOS, Linux, and Windows (Git Bash / WSL). On Windows without symlink support, skills are copied instead of symlinked.
