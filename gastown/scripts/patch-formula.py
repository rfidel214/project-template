#!/usr/bin/env python3
"""
Patch mol-polecat-work formula to add mandatory capture-findings step.

Usage:
    python3 patch-formula.py [--gt-dir ~/gt]
"""
import sys
import argparse
from pathlib import Path

FORMULA_NAME = "mol-polecat-work.formula.toml"
INSERT_BEFORE = '\n[[steps]]\nid = "pre-verify"'
GUARD = 'id = "capture-findings"'

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gt-dir", default="~/gt")
    args = parser.parse_args()

    gt_dir = Path(args.gt_dir).expanduser()
    formula_path = gt_dir / ".beads" / "formulas" / FORMULA_NAME
    step_path = Path(__file__).parent.parent / "formulas" / "capture-step.toml"

    if not formula_path.exists():
        print(f"ERROR: formula not found at {formula_path}")
        sys.exit(1)

    content = formula_path.read_text()
    if GUARD in content:
        print("SKIP: mol-polecat-work already has capture-findings step")
        sys.exit(0)

    idx = content.find(INSERT_BEFORE)
    if idx == -1:
        print("ERROR: could not find pre-verify insertion point")
        sys.exit(1)

    formula_path.write_text(content[:idx] + step_path.read_text() + content[idx:])
    print(f"OK: inserted capture-findings step into {FORMULA_NAME}")

    verify = formula_path.read_text()
    if GUARD in verify:
        import re
        steps = re.findall(r'^id = "', verify, re.MULTILINE)
        print(f"VERIFIED: {len(steps)} steps total")
        if 'needs = ["capture-findings"]' not in verify:
            print("NOTE: update pre-verify needs = [\"capture-findings\"] manually if not already set")
    else:
        print("ERROR: verification failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
