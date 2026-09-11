---
name: smart-commit-grouping-lite
description: Group git changes into logical commits with conventional messages. Lightweight alternative to smart-commit-grouping. Use when the user wants simple commit grouping without the full workflow.
---

# Smart Commit Grouping (Lite)

Group pending changes into cohesive commits. Always end by writing `commit_groups_<scope>.py` at the repo root.

## Scope

- **Default:** all changed files (staged + unstaged).
- **Staged-only:** when the user says "only staged" / "staged files only", use only `git diff --cached --name-only`. Save that list; never add other paths.

## Message format

```
<type>(<scope>): <short description>
```

- **scope:** ticket from branch (e.g. `PROJ-123` from `feat/PROJ-123`), else full branch name.
- **type:** `feat` | `fix` | `docs` | `chore` | `test` | `refactor` | `ci` (pick primary intent).
- Imperative mood, under 72 chars.

## Workflow

1. **Context** (parallel): `git status --short`, `git branch --show-current`, `git log --oneline -5`, `git diff --stat` (+ `--cached` if needed).
2. **Read diffs** for files in scope to understand cohesion.
3. **Group** by:
   - same feature/fix together
   - separate docs / tests / config when unrelated
   - commit dependencies first (shared module before consumers)
   - same package/domain together; split unrelated modules
4. **Propose** a table and ask confirmation before executing:

| # | Type | Files | Message |
|---|------|-------|---------|
| 1 | feat | a.py, b.py | feat(SCOPE): ... |

5. **Script:** write `commit_groups_<scope>.py` (see [scripts/commit_groups_template.py](scripts/commit_groups_template.py)), `chmod +x`, dry-run without `--exec`.
6. **Execute** only if the user confirms: `python3 commit_groups_<scope>.py --exec`.

## Rules

- Never commit secrets (`.env`, credentials) without explicit OK.
- Never commit files the user excluded.
- Renames stay with their content updates in one commit.
- Staged-only: leave unstaged changes untouched.

## Example

Branch `feat/PROJ-123`, files `docs/overview.md`, `docs/architecture.md`, `mkdocs.yml`, `src/lib/writer.py`:

| # | Type | Files | Message |
|---|------|-------|---------|
| 1 | docs | docs/*, mkdocs.yml | docs(PROJ-123): add architecture doc and update overview |
| 2 | chore | src/lib/writer.py | chore(PROJ-123): deprecate legacy writer path |
