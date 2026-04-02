# Code Quality Enforcement

**Application scope:** `**/*.ts`, `**/*.tsx`, `**/*.js`, `**/*.jsx`, `**/*.rs`, `**/*.py`
**Severity:** blocking

---

## Rules

### Single Responsibility

Every file must have one clear responsibility you can describe in one phrase.
If you need "and" to describe what a file does, split it.

### No Catch-All Files

Do not create `utils.ts`, `helpers.ts`, `service.ts`, `common.ts`, or similar grab-bags.
Each function lives in a purposefully-named module that describes what it does
(e.g., `date-formatter.ts`, `auth-token-validator.ts`).

### No Unguarded Secrets

Do not hardcode API keys, tokens, secrets, or credentials in source files.
Use environment variables or a secrets manager. If a secret must be committed (e.g., for tests),
use a clearly-named placeholder like `TEST_ONLY_NOT_REAL`.

### Test Coverage Required

Every non-trivial function must have at least one test.
Tests live alongside source (`foo.test.ts` next to `foo.ts`) or in a parallel `tests/` directory.
Do not ship code that cannot be verified.

### No Silent Errors

Do not swallow errors without logging or propagating.
`catch (e) {}` with no body is always a bug. If you're intentionally ignoring an error,
add a comment explaining why: `catch (e) { /* expected on first run */ }`.

### Commit Message Format

All commits must follow: `<task-id>: <imperative description>`
Example: `he-yl5h: anchor input to bottom using Constraint::Fill layout`
Do not commit with generic messages like "fix" or "update" or "wip".
