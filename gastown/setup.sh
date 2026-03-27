#!/usr/bin/env bash
# Gas Town infrastructure setup
# Patches ~/gt/ with OpenBrain capture protocol, formula gates, and MCP config.
# Called by bootstrap.sh when Gas Town is enabled, or run standalone.
# Safe to run multiple times — all patches are idempotent.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "--- Gas Town Infrastructure Setup ---"

# Locate Gas Town directory
GT_DIR="${GT_DIR:-$HOME/gt}"
read -rp "Gas Town directory [${GT_DIR}]: " input
GT_DIR="${input:-$GT_DIR}"
GT_DIR="${GT_DIR/#\~/$HOME}"

if [ ! -d "$GT_DIR" ]; then
    echo "ERROR: Gas Town directory not found: $GT_DIR"
    echo "Install Gas Town first: go install github.com/steveyegge/gastown/cmd/gt@latest"
    exit 1
fi

# Configure OpenBrain MCP in opencode config
OPENCODE_CONFIG="$HOME/.config/opencode/config.json"
if [ -f "$OPENCODE_CONFIG" ] && grep -q "open-brain" "$OPENCODE_CONFIG" 2>/dev/null; then
    echo "SKIP opencode config: open-brain MCP already configured"
else
    read -rp "OpenBrain URL (leave blank to skip): " OPENBRAIN_URL
    if [ -n "$OPENBRAIN_URL" ]; then
        mkdir -p "$(dirname "$OPENCODE_CONFIG")"
        if [ -f "$OPENCODE_CONFIG" ]; then
            python3 - <<PYEOF
import json
with open("$OPENCODE_CONFIG", "r") as f:
    cfg = json.load(f)
cfg.setdefault("mcp", {})["open-brain"] = {"type": "remote", "url": "$OPENBRAIN_URL"}
with open("$OPENCODE_CONFIG", "w") as f:
    json.dump(cfg, f, indent=2)
print("OK   opencode config: open-brain MCP added")
PYEOF
        else
            sed "s|OPENBRAIN_URL_PLACEHOLDER|$OPENBRAIN_URL|g" \
                "$SCRIPT_DIR/opencode/config-template.json" > "$OPENCODE_CONFIG"
            echo "OK   opencode config: created with open-brain MCP"
        fi
    else
        echo "SKIP opencode config: no URL provided"
    fi
fi

# Detect rig
RIG=""
RIGS_FILE="$GT_DIR/rigs.json"
if [ -f "$RIGS_FILE" ]; then
    RIG=$(python3 -c "
import json
data = json.load(open('$RIGS_FILE'))
rigs = list(data.get('rigs', {}).keys())
print(rigs[0] if rigs else '')
" 2>/dev/null || echo "")
fi
if [ -z "$RIG" ]; then
    read -rp "Rig name (leave blank to skip refinery patch): " RIG
fi

# Patch AGENTS.md files
echo "Patching AGENTS.md files..."
PATCH_ARGS="--gt-dir $GT_DIR"
[ -n "$RIG" ] && PATCH_ARGS="$PATCH_ARGS --rig $RIG"
python3 "$SCRIPT_DIR/scripts/patch-agents.py" $PATCH_ARGS

# Patch mol-refinery-patrol formula (inject BEAD_MERGED Mayor notification)
echo "Patching mol-refinery-patrol formula..."
python3 "$SCRIPT_DIR/scripts/patch-refinery.py" --gt-dir "$GT_DIR"

# Install custom formulas (new formulas not in Gas Town defaults)
FORMULAS_DIR="$SCRIPT_DIR/formulas"
if [ -d "$FORMULAS_DIR" ]; then
    FORMULA_COUNT=0
    for formula in "$FORMULAS_DIR"/*.formula.toml; do
        [ -f "$formula" ] || continue
        fname="$(basename "$formula")"
        dest="$GT_DIR/.beads/formulas/$fname"
        if [ -f "$dest" ]; then
            cp "$formula" "$dest"
            echo "OK   formula updated: $fname (overwrote existing)"
        else
            cp "$formula" "$dest"
            echo "OK   formula installed: $fname (new)"
        fi
        FORMULA_COUNT=$((FORMULA_COUNT + 1))
    done
    if [ "$FORMULA_COUNT" -eq 0 ]; then
        echo "SKIP formulas: none found in $FORMULAS_DIR"
    else
        echo "OK   $FORMULA_COUNT formula(s) installed"
    fi
fi

echo ""
echo "Gas Town setup complete."
echo "Restart Gas Town to pick up changes: gt down --all && gt start && gt rig boot <rig>"
