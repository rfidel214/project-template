#!/usr/bin/env bash
set -euo pipefail

# Project Template Bootstrap Script
# Works on macOS, Linux, and Windows (Git Bash / WSL)
# Creates a new project with AI agent workflow infrastructure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

# Colors (safe for all terminals)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)   echo "linux" ;;
        Darwin*)  echo "macos" ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

OS=$(detect_os)

# Check if symlinks are supported
can_symlink() {
    local test_link="/tmp/.symlink_test_$$"
    local test_target="/tmp/.symlink_target_$$"
    touch "$test_target" 2>/dev/null || return 1
    ln -s "$test_target" "$test_link" 2>/dev/null
    local result=$?
    rm -f "$test_link" "$test_target" 2>/dev/null
    return $result
}

echo ""
echo "========================================"
echo "  Project Template Bootstrap"
echo "  AI Agent Workflow Infrastructure"
echo "========================================"
echo ""

# --- Prompts ---

read -rp "Project name (e.g., My SaaS App): " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
    error "Project name is required."
    exit 1
fi

# Derive a default slug from the project name
DEFAULT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
read -rp "Repo slug [$DEFAULT_SLUG]: " REPO_SLUG
REPO_SLUG="${REPO_SLUG:-$DEFAULT_SLUG}"

read -rp "Brief description: " PROJECT_DESCRIPTION
PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-A new project.}"

read -rp "Current phase (e.g., Phase 1 — MVP): " PROJECT_PHASE
PROJECT_PHASE="${PROJECT_PHASE:-Phase 1 — Getting Started}"

echo ""
info "Primary language?"
echo "  1) Rust"
echo "  2) Node.js / TypeScript"
echo "  3) Python"
echo "  4) Go"
echo "  5) Other / Multiple"
read -rp "Choice [5]: " LANG_CHOICE
LANG_CHOICE="${LANG_CHOICE:-5}"

echo ""
info "Target platforms? (select all that apply)"
echo "  1) Windows"
echo "  2) macOS"
echo "  3) Linux"
echo "  4) All / Cross-platform"
read -rp "Choice [4]: " PLATFORM_CHOICE
PLATFORM_CHOICE="${PLATFORM_CHOICE:-4}"

echo ""
info "Which AI coding tools do you use? (comma-separated)"
echo "  1) Claude Code"
echo "  2) OpenCode"
echo "  3) KiloCode"
echo "  4) Codex CLI"
echo "  a) All of the above"
read -rp "Choice [a]: " TOOLS_CHOICE
TOOLS_CHOICE="${TOOLS_CHOICE:-a}"

echo ""
read -rp "OpenBrain MCP URL (or 'skip'): " OPENBRAIN_URL
OPENBRAIN_URL="${OPENBRAIN_URL:-skip}"

echo ""
info "Use Gas Town for multi-agent orchestration? (requires Linux VM with gt installed)"
read -rp "Enable Gas Town? (y/N): " GT_CHOICE
GT_CHOICE="${GT_CHOICE:-N}"

# --- Determine output directory ---

read -rp "Output directory [./$REPO_SLUG]: " OUTPUT_DIR
OUTPUT_DIR="${OUTPUT_DIR:-./$REPO_SLUG}"

if [[ -d "$OUTPUT_DIR" ]]; then
    warn "Directory $OUTPUT_DIR already exists."
    read -rp "Continue anyway? (y/N): " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

mkdir -p "$OUTPUT_DIR"
info "Creating project in $OUTPUT_DIR..."

# --- Generate .gitignore ---

generate_gitignore() {
    local outfile="$OUTPUT_DIR/.gitignore"

    # Base section (always included)
    sed -n '1,/^# {{LANG_SECTION_RUST}}/p' "$TEMPLATE_DIR/gitignore.tmpl" | head -n -1 > "$outfile"

    # Language-specific sections (uncommented)
    case "$LANG_CHOICE" in
        1) # Rust
            echo "" >> "$outfile"
            echo "# Rust" >> "$outfile"
            echo "target/" >> "$outfile"
            echo "*.pdb" >> "$outfile"
            ;;
        2) # Node
            echo "" >> "$outfile"
            echo "# Node" >> "$outfile"
            echo "node_modules/" >> "$outfile"
            echo ".next/" >> "$outfile"
            echo ".nuxt/" >> "$outfile"
            echo ".output/" >> "$outfile"
            echo "npm-debug.log*" >> "$outfile"
            echo "yarn-debug.log*" >> "$outfile"
            echo "yarn-error.log*" >> "$outfile"
            ;;
        3) # Python
            echo "" >> "$outfile"
            echo "# Python" >> "$outfile"
            echo "__pycache__/" >> "$outfile"
            echo "*.py[cod]" >> "$outfile"
            echo "*\$py.class" >> "$outfile"
            echo ".venv/" >> "$outfile"
            echo "venv/" >> "$outfile"
            echo "*.egg-info/" >> "$outfile"
            ;;
        4) # Go
            echo "" >> "$outfile"
            echo "# Go" >> "$outfile"
            echo "vendor/" >> "$outfile"
            ;;
        5) # Other — include all language sections commented
            echo "" >> "$outfile"
            echo "# Uncomment sections for your language:" >> "$outfile"
            echo "# # Rust" >> "$outfile"
            echo "# target/" >> "$outfile"
            echo "# *.pdb" >> "$outfile"
            echo "" >> "$outfile"
            echo "# # Node" >> "$outfile"
            echo "# node_modules/" >> "$outfile"
            echo "# .next/" >> "$outfile"
            echo "" >> "$outfile"
            echo "# # Python" >> "$outfile"
            echo "# __pycache__/" >> "$outfile"
            echo "# .venv/" >> "$outfile"
            echo "" >> "$outfile"
            echo "# # Go" >> "$outfile"
            echo "# vendor/" >> "$outfile"
            ;;
    esac

    ok ".gitignore created"
}

# --- Substitute placeholders ---

substitute() {
    local infile="$1"
    local outfile="$2"

    # Use | as delimiter since it's unlikely in user input
    # Escape any | in user values first
    local safe_name="${PROJECT_NAME//|/\\|}"
    local safe_desc="${PROJECT_DESCRIPTION//|/\\|}"
    local safe_phase="${PROJECT_PHASE//|/\\|}"
    local safe_slug="${REPO_SLUG//|/\\|}"
    local safe_url="${OPENBRAIN_URL//|/\\|}"

    sed \
        -e "s|{{PROJECT_NAME}}|${safe_name}|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|${safe_desc}|g" \
        -e "s|{{PROJECT_PHASE}}|${safe_phase}|g" \
        -e "s|{{REPO_SLUG}}|${safe_slug}|g" \
        -e "s|{{OPEN_BRAIN_MCP_URL}}|${safe_url}|g" \
        "$infile" > "$outfile"
}

# --- Default content for placeholder sections ---

generate_defaults() {
    local agents_file="$OUTPUT_DIR/AGENTS.md"
    local tmpfile="${agents_file}.tmp"

    # Build replacement content based on language choice
    local tech_stack_file=$(mktemp)
    cat > "$tech_stack_file" << 'TECHEOF'
| Layer | Technology |
|---|---|
| _Frontend_ | _TBD_ |
| _Backend_ | _TBD_ |
| _Database_ | _TBD_ |
TECHEOF

    local code_style_file=$(mktemp)
    case "$LANG_CHOICE" in
        1) cat > "$code_style_file" << 'EOF'
- Production-ready Rust — no extraneous TODO comments in committed code
- Use `async`/`await` with Tokio throughout; no blocking calls on the async runtime
- Error handling with `anyhow` or typed errors — no silent `.unwrap()` in non-prototype code
- Non-interactive shell flags always: `cp -f`, `mv -f`, `rm -f`, `rm -rf`
EOF
        ;;
        2) cat > "$code_style_file" << 'EOF'
- TypeScript strict mode enabled
- ESLint + Prettier for formatting
- Prefer `const` over `let`, never use `var`
- Use async/await over raw Promises
EOF
        ;;
        3) cat > "$code_style_file" << 'EOF'
- Python 3.10+ with type hints
- Black for formatting, ruff for linting
- Use `pathlib.Path` over `os.path`
- Prefer dataclasses or Pydantic models
EOF
        ;;
        4) cat > "$code_style_file" << 'EOF'
- Follow Go standard project layout
- Use `go fmt` and `golangci-lint`
- Error handling: always check returned errors
- Prefer interfaces for testability
EOF
        ;;
        *) echo "- _Add language-specific code style rules here_" > "$code_style_file" ;;
    esac

    local testing_file=$(mktemp)
    case "$LANG_CHOICE" in
        1) cat > "$testing_file" << 'EOF'
**Every new feature or bug fix must include unit tests. No exceptions.**

- Write tests in `#[cfg(test)]` modules within the same file
- `cargo test` must pass before any commit
EOF
        ;;
        2) cat > "$testing_file" << 'EOF'
**Every new feature or bug fix must include tests. No exceptions.**

- Use your project's test framework (Jest, Vitest, etc.)
- Tests must pass before any commit
EOF
        ;;
        3) cat > "$testing_file" << 'EOF'
**Every new feature or bug fix must include tests. No exceptions.**

- Use pytest for all tests
- Tests must pass before any commit
EOF
        ;;
        4) cat > "$testing_file" << 'EOF'
**Every new feature or bug fix must include tests. No exceptions.**

- Use Go's built-in testing package
- `go test ./...` must pass before any commit
EOF
        ;;
        *) cat > "$testing_file" << 'EOF'
**Every new feature or bug fix must include tests. No exceptions.**

- _Configure your test framework and add rules here_
EOF
        ;;
    esac

    # Load Gas Town section if enabled
    local gastown_file="$TEMPLATE_DIR/../gastown/agents/gt-workspace.md"
    local USE_GASTOWN="false"
    if [[ "$GT_CHOICE" == "y" || "$GT_CHOICE" == "Y" ]]; then
        USE_GASTOWN="true"
    fi

    # Use Python for reliable multi-line replacements (available on all platforms)
    # Convert Git Bash paths to Windows paths if needed
    local py_agents_file="$agents_file"
    local py_gastown_file="$gastown_file"
    local py_tech_file="$tech_stack_file"
    local py_style_file="$code_style_file"
    local py_test_file="$testing_file"
    if [[ "$OS" == "windows" ]]; then
        py_agents_file=$(cygpath -w "$agents_file" 2>/dev/null || echo "$agents_file")
        py_tech_file=$(cygpath -w "$tech_stack_file" 2>/dev/null || echo "$tech_stack_file")
        py_style_file=$(cygpath -w "$code_style_file" 2>/dev/null || echo "$code_style_file")
        py_test_file=$(cygpath -w "$testing_file" 2>/dev/null || echo "$testing_file")
        py_gastown_file=$(cygpath -w "$gastown_file" 2>/dev/null || echo "$gastown_file")
    fi

    if command -v python3 &>/dev/null; then
        python3 << PYEOF
import sys

with open(r"$py_agents_file", "r") as f:
    content = f.read()

replacements = {
    "{{TECH_STACK_TABLE}}": open(r"$py_tech_file").read().strip(),
    "{{ARCHITECTURE_SECTION}}": "_Describe your system architecture here._",
    "{{KEY_FILES_TABLE}}": "",
    "{{CODE_STYLE_SECTION}}": open(r"$py_style_file").read().strip(),
    "{{TESTING_SECTION}}": open(r"$py_test_file").read().strip(),
    "{{DECISIONS_SECTION}}": "_No decisions logged yet. Use Open Brain to capture decisions as they're made._",
    "{{DONTS_SECTION}}": "",
    "{{GASTOWN_SECTION}}": open(r"$py_gastown_file").read().strip() if "$USE_GASTOWN" == "true" else "",
}

for placeholder, replacement in replacements.items():
    content = content.replace(placeholder, replacement)

with open(r"$py_agents_file", "w") as f:
    f.write(content)
PYEOF
    else
        # Fallback: simple sed for single-line replacements only
        sed -i \
            -e "s|{{TECH_STACK_TABLE}}|_See AGENTS.md and fill in your tech stack_|" \
            -e "s|{{ARCHITECTURE_SECTION}}|_Describe your system architecture here._|" \
            -e "s|{{KEY_FILES_TABLE}}||" \
            -e "s|{{CODE_STYLE_SECTION}}|_Add code style rules here_|" \
            -e "s|{{TESTING_SECTION}}|_Add testing policy here_|" \
            -e "s|{{DECISIONS_SECTION}}|_No decisions logged yet._|" \
            -e "s|{{DONTS_SECTION}}||" \
            -e "s|{{GASTOWN_SECTION}}||" \
            "$agents_file"
        warn "python3 not found — AGENTS.md has simplified defaults. Edit manually."
    fi

    # Cleanup temp files
    rm -f "$tech_stack_file" "$code_style_file" "$testing_file"
}

# --- Create tool-specific directories ---

setup_tools() {
    local use_claude=false
    local use_opencode=false
    local use_kilocode=false
    local use_codex=false

    case "$TOOLS_CHOICE" in
        a|A) use_claude=true; use_opencode=true; use_kilocode=true; use_codex=true ;;
        *)
            [[ "$TOOLS_CHOICE" == *"1"* ]] && use_claude=true
            [[ "$TOOLS_CHOICE" == *"2"* ]] && use_opencode=true
            [[ "$TOOLS_CHOICE" == *"3"* ]] && use_kilocode=true
            [[ "$TOOLS_CHOICE" == *"4"* ]] && use_codex=true
            ;;
    esac

    # Claude Code — canonical skill location
    if $use_claude; then
        mkdir -p "$OUTPUT_DIR/.claude/skills/session-start-checklist"
        mkdir -p "$OUTPUT_DIR/.claude/skills/session-capture-checklist"
        cp -f "$TEMPLATE_DIR/skills/session-start-checklist/SKILL.md" \
              "$OUTPUT_DIR/.claude/skills/session-start-checklist/SKILL.md"
        cp -f "$TEMPLATE_DIR/skills/session-capture-checklist/SKILL.md" \
              "$OUTPUT_DIR/.claude/skills/session-capture-checklist/SKILL.md"
        cp -f "$TEMPLATE_DIR/settings.local.json.tmpl" \
              "$OUTPUT_DIR/.claude/settings.local.json"
        ok "Claude Code: .claude/skills/ and settings.local.json created"
    fi

    # gstack — virtual engineering team skills (optional)
    if $use_claude; then
        echo ""
        info "Install gstack (Garry Tan's software factory)? Adds /office-hours, /review, /qa, /cso, and 24 more skills."
        read -rp "Install gstack? (Y/n): " GSTACK_CHOICE
        GSTACK_CHOICE="${GSTACK_CHOICE:-Y}"
        if [[ "$GSTACK_CHOICE" == "y" || "$GSTACK_CHOICE" == "Y" ]]; then
            if command -v bun &>/dev/null; then
                git clone https://github.com/garrytan/gstack.git "$OUTPUT_DIR/.claude/skills/gstack" 2>/dev/null
                cd "$OUTPUT_DIR/.claude/skills/gstack" && ./setup 2>/dev/null
                cd "$OUTPUT_DIR"
                ok "gstack installed (28 skills)"
            else
                warn "bun not found — gstack requires Bun v1.0+. Install bun (bun.sh) then run:"
                echo "  cd $OUTPUT_DIR/.claude/skills/gstack && ./setup"
                git clone https://github.com/garrytan/gstack.git "$OUTPUT_DIR/.claude/skills/gstack" 2>/dev/null
                ok "gstack cloned (run setup after installing bun)"
            fi
        fi
    fi

    # Determine symlink or copy strategy
    local link_cmd="copy"
    if can_symlink; then
        link_cmd="symlink"
    fi

    link_skills() {
        local target_dir="$1"
        local tool_name="$2"
        mkdir -p "$target_dir/session-start-checklist"
        mkdir -p "$target_dir/session-capture-checklist"

        if [[ "$link_cmd" == "symlink" && $use_claude == true ]]; then
            # Symlink to .claude/skills/ as canonical
            local rel_start
            local rel_capture
            # Use relative paths for portability
            rel_start=$(python3 -c "import os.path; print(os.path.relpath('$OUTPUT_DIR/.claude/skills/session-start-checklist/SKILL.md', '$target_dir/session-start-checklist'))" 2>/dev/null || echo "")
            rel_capture=$(python3 -c "import os.path; print(os.path.relpath('$OUTPUT_DIR/.claude/skills/session-capture-checklist/SKILL.md', '$target_dir/session-capture-checklist'))" 2>/dev/null || echo "")

            if [[ -n "$rel_start" ]]; then
                ln -sf "$rel_start" "$target_dir/session-start-checklist/SKILL.md"
                ln -sf "$rel_capture" "$target_dir/session-capture-checklist/SKILL.md"
                ok "$tool_name: symlinked to .claude/skills/"
            else
                # Fallback: copy if python3 not available
                cp -f "$TEMPLATE_DIR/skills/session-start-checklist/SKILL.md" \
                      "$target_dir/session-start-checklist/SKILL.md"
                cp -f "$TEMPLATE_DIR/skills/session-capture-checklist/SKILL.md" \
                      "$target_dir/session-capture-checklist/SKILL.md"
                ok "$tool_name: skills copied (symlink fallback)"
            fi
        else
            # Copy skills directly
            cp -f "$TEMPLATE_DIR/skills/session-start-checklist/SKILL.md" \
                  "$target_dir/session-start-checklist/SKILL.md"
            cp -f "$TEMPLATE_DIR/skills/session-capture-checklist/SKILL.md" \
                  "$target_dir/session-capture-checklist/SKILL.md"
            ok "$tool_name: skills copied"
        fi
    }

    # OpenCode
    if $use_opencode; then
        link_skills "$OUTPUT_DIR/.opencode/skills" "OpenCode"
        # Install context monitor plugin
        mkdir -p "$OUTPUT_DIR/.opencode/plugins"
        cp -f "$TEMPLATE_DIR/opencode-plugins/context-monitor.js" \
              "$OUTPUT_DIR/.opencode/plugins/context-monitor.js"
        ok "OpenCode: context-monitor plugin installed (.opencode/plugins/)"
    fi

    # KiloCode
    if $use_kilocode; then
        link_skills "$OUTPUT_DIR/.kilocode/skills" "KiloCode"
    fi

    # Codex CLI
    if $use_codex; then
        link_skills "$OUTPUT_DIR/.agents/skills" "Codex CLI"
    fi
}

# --- Main ---

info "Generating files..."

# AGENTS.md
substitute "$TEMPLATE_DIR/AGENTS.md.tmpl" "$OUTPUT_DIR/AGENTS.md"
generate_defaults
ok "AGENTS.md created"

# CLAUDE.md
substitute "$TEMPLATE_DIR/CLAUDE.md.tmpl" "$OUTPUT_DIR/CLAUDE.md"
ok "CLAUDE.md created"

# .gitignore
generate_gitignore

# Tool-specific directories
setup_tools

# Create docs directory
mkdir -p "$OUTPUT_DIR/docs"
ok "docs/ directory created"

# Initialize git
if command -v git &>/dev/null; then
    cd "$OUTPUT_DIR"
    if [[ ! -d .git ]]; then
        git init -q
        ok "git initialized"
    fi
fi

# Initialize beads
if command -v bd &>/dev/null; then
    cd "$OUTPUT_DIR"
    if [[ ! -d .beads ]]; then
        bd init 2>/dev/null && ok "beads initialized" || warn "bd init failed — run manually later"
    fi
else
    warn "bd (beads) not found — install it and run 'bd init' manually"
fi

echo ""
echo "========================================"
echo "  Project created: $OUTPUT_DIR"
echo "========================================"
echo ""
info "Next steps:"
echo "  1. cd $OUTPUT_DIR"
echo "  2. Review and customize AGENTS.md (fill in architecture, tech stack, etc.)"
echo "  3. Run 'bd init' if beads wasn't initialized above"
echo "  4. Run 'git add -A && git commit -m \"Initial project setup\"'"
echo "  5. Create GitHub repo: gh repo create $REPO_SLUG --source=. --push"
echo ""

if [[ "$OPENBRAIN_URL" != "skip" ]]; then
    info "OpenBrain MCP URL configured in AGENTS.md."
    echo "  Add it to your tool's MCP config — see AGENTS.md 'Tool-Specific Setup' section."
fi

echo ""
info "Global hooks (SessionStart, PreCompact) must be configured separately."
echo "  For Claude Code: run 'bd setup claude' in the new project."
echo "  For OpenCode: add plugin hooks per AGENTS.md instructions."

# Gas Town infrastructure setup (optional)
if [[ "$GT_CHOICE" == "y" || "$GT_CHOICE" == "Y" ]]; then
    echo ""
    info "Gas Town infrastructure setup (patches ~/gt/ on Linux VM)"
    read -rp "Set up ~/gt/ now? (y/N): " GT_INFRA_NOW
    if [[ "$GT_INFRA_NOW" == "y" || "$GT_INFRA_NOW" == "Y" ]]; then
        bash "$SCRIPT_DIR/gastown/setup.sh"
    else
        echo "  Run later: bash $(realpath "$SCRIPT_DIR/gastown/setup.sh")"
        echo "  Or if on Windows: scp gastown/setup.sh <linux-vm>:/tmp/ && ssh <vm> 'bash /tmp/setup.sh'"
    fi
fi

echo ""
ok "Done!"
