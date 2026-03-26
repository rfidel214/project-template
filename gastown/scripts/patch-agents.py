#!/usr/bin/env python3
"""
Patch Gas Town AGENTS.md files with OpenBrain capture protocol.

Usage:
    python3 patch-agents.py [--gt-dir ~/gt] [--rig <rig-name>]
"""
import sys
import argparse
import json
from pathlib import Path

def load_content(filename):
    path = Path(__file__).parent.parent / "agents" / filename
    with open(path, "r") as f:
        return f.read()

def patch(path, content, guard, label):
    path = Path(path).expanduser()
    if not path.exists():
        print(f"SKIP {label}: file not found at {path}")
        return False
    text = path.read_text()
    if guard in text:
        print(f"SKIP {label}: already patched")
        return True
    with open(path, "a") as f:
        f.write(content)
    print(f"OK   {label}: patched")
    return True

def detect_rig(gt_dir):
    rigs_file = Path(gt_dir) / "rigs.json"
    if not rigs_file.exists():
        return None
    data = json.loads(rigs_file.read_text())
    rigs = list(data.get("rigs", {}).keys())
    return rigs[0] if rigs else None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gt-dir", default="~/gt")
    parser.add_argument("--rig")
    args = parser.parse_args()

    gt_dir = Path(args.gt_dir).expanduser()
    if not gt_dir.exists():
        print(f"ERROR: Gas Town directory not found: {gt_dir}")
        sys.exit(1)

    errors = []

    patch(
        gt_dir / "AGENTS.md",
        load_content("gt-workspace.md"),
        "## OpenBrain Capture Protocol (All Gas Town Agents)",
        "~/gt/AGENTS.md",
    ) or errors.append("~/gt/AGENTS.md")

    patch(
        gt_dir / "mayor" / "AGENTS.md",
        load_content("mayor.md"),
        "## Mayor: OpenBrain Capture Protocol",
        "~/gt/mayor/AGENTS.md",
    ) or errors.append("~/gt/mayor/AGENTS.md")

    rig = args.rig or detect_rig(gt_dir)
    if rig:
        patch(
            gt_dir / rig / "refinery" / "rig" / "AGENTS.md",
            load_content("refinery.md"),
            "## Refinery: OpenBrain Capture Protocol",
            f"~/gt/{rig}/refinery/rig/AGENTS.md",
        ) or print(f"  Note: refinery AGENTS.md not found for rig '{rig}' — run after rig setup")
    else:
        print("NOTE: No rig detected — skipping refinery patch (run with --rig <name> after rig setup)")

    if errors:
        print(f"\nFAILED: {errors}")
        sys.exit(1)
    print("\nAll agent patches applied.")

if __name__ == "__main__":
    main()
