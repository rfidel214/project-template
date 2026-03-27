#!/usr/bin/env python3
"""
Patch mol-refinery-patrol.formula.toml with BEAD_MERGED Mayor notification.

Injects Step 2.5 (notify Mayor after every successful merge) into Gas Town's
system formula. This is idempotent — safe to run multiple times.

Usage:
    python3 patch-refinery.py [--gt-dir ~/gt]
"""
import sys
import argparse
from pathlib import Path

GUARD = "Step 2.5: Notify Mayor (REQUIRED)"

STEP_2_5 = """

**Step 2.5: Notify Mayor (REQUIRED)**

After notifying Witness, notify Mayor that a bead was merged. This triggers Mayor
to check if new beads are unblocked and sling the next wave:

```bash
gt mail send <rig>/mayor -s "BEAD_MERGED <issue-id>" -m "Branch: <branch>
Issue: <issue-id>
Polecat: <polecat-name>
Merged-At: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Note: Check bd ready for newly unblocked beads."
```

This closes the Mayor notification gap — without this, Mayor never learns a bead
was merged and will not sling the next wave autonomously.
"""

VERIFICATION_PATCH_OLD = "- [x] MERGED mail sent to witness"
VERIFICATION_PATCH_NEW = """- [x] MERGED mail sent to witness
- [x] BEAD_MERGED mail sent to mayor"""

# Anchor: insert Step 2.5 right after the direct merge witness notification block
ANCHOR = '**If merge_strategy = "direct":**\n```bash\ngt mail send <rig>/witness -s "MERGED <polecat-name>"'


def main():
    parser = argparse.ArgumentParser(description="Patch mol-refinery-patrol with BEAD_MERGED notification")
    parser.add_argument("--gt-dir", default="~/gt", help="Gas Town directory (default: ~/gt)")
    args = parser.parse_args()

    formula_path = Path(args.gt_dir).expanduser() / ".beads" / "formulas" / "mol-refinery-patrol.formula.toml"

    if not formula_path.exists():
        print(f"SKIP patch-refinery: formula not found at {formula_path}")
        print("      (Gas Town may not be installed, or formula name changed)")
        sys.exit(0)

    text = formula_path.read_text(encoding="utf-8")

    if GUARD in text:
        print("SKIP patch-refinery: mol-refinery-patrol already has BEAD_MERGED step")
        sys.exit(0)

    # Find insertion point: after the witness MERGED mail block ends (after the closing ```)
    # We insert Step 2.5 before the verification gate section
    anchor_pos = text.find(ANCHOR)
    if anchor_pos == -1:
        print("ERROR patch-refinery: could not find MERGED mail anchor in formula")
        print("      Gas Town may have restructured mol-refinery-patrol. Manual patch required.")
        sys.exit(1)

    # Find the end of the pr merge_strategy block (the second closing ``` after the anchor)
    # Both direct and pr blocks end with ```, then we insert after the last one
    block_start = anchor_pos
    close1 = text.find("```\n", block_start)
    if close1 == -1:
        print("ERROR patch-refinery: could not find end of MERGED mail block")
        sys.exit(1)
    close2 = text.find("```\n", close1 + 4)
    if close2 == -1:
        print("ERROR patch-refinery: could not find end of pr MERGED mail block")
        sys.exit(1)
    insert_at = close2 + 4  # just after the closing ``` of the pr block

    patched = text[:insert_at] + STEP_2_5 + text[insert_at:]

    # Also patch the verification gate if present
    if VERIFICATION_PATCH_OLD in patched and VERIFICATION_PATCH_NEW not in patched:
        patched = patched.replace(VERIFICATION_PATCH_OLD, VERIFICATION_PATCH_NEW, 1)

    formula_path.write_text(patched, encoding="utf-8")
    print(f"OK   patch-refinery: BEAD_MERGED step injected into {formula_path}")


if __name__ == "__main__":
    main()
