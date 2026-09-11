---
name: smart-commit-grouping
description: Analyze staged and unstaged git changes, group files into logical cohesive commits, and generate conventional commit messages. Use when the user asks to commit changes, group commits, or organize git history. Honors explicit requests to analyze only staged files.
---

# Smart Commit Grouping

## Overview

Analyze pending git changes (modified, created, deleted, renamed), group them into logical cohesive commits, and execute them with conventional commit messages.

### Staged-only mode

When the user **explicitly** asks to analyze or group **only staged** files (or equivalent wording), use **staged-only mode**:

- Trigger examples: "only staged", "just staged", "staged files only", "ignore unstaged", "commit grouping for what's staged", "analyze staged only".
- **Universe of files:** Only paths that appear in `git diff --cached --name-only` at the start of the workflow. Do not include unstaged-only paths in grouping, proposals, or commits.
- **Gathering context:** Still run `git status --short` for visibility, but **diff stats and classification apply only** to `git diff --cached` (and the staged file list). Do not use `git diff` (unstaged) for grouping decisions.
- **Before Step 2:** Save the staged path list (e.g. output of `git diff --cached --name-only`); after `git reset HEAD`, only ever `git add` paths from that saved list unless the user widens scope.
- **Unstaged changes:** Leave them untouched; never stage or commit them as part of this run.

If the user does **not** ask for staged-only, analyze and group **all** changed files (staged and unstaged) as today.

## Commit Message Format

```
<type>(<scope>): <short description>
```

| Field | Source | Example |
|-------|--------|---------|
| `type` | Inferred from change nature (see table below) | `docs` |
| `scope` | Extracted from current branch name. Use the ticket/issue ID when present (e.g. `PROJ-123` from `feat/PROJ-123`), otherwise use the full branch name. | `PROJ-123` |
| `short description` | Summarizes the group's purpose | `reorganize doc navigation` |

### Commit Types

| Type | When to Use |
|------|-------------|
| `feat` | New user-facing feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only (markdown, notebooks, docstrings, images) |
| `chore` | Maintenance, config, dependency updates, deprecations |
| `test` | Adding or updating tests |
| `refactor` | Code restructuring without behavior change |
| `ci` | CI/CD pipeline, GitHub Actions, build system |

When a commit contains mixed types (e.g. code + docs for the same feature), prefer the **primary intent** of the change.

## Workflow

### Step 1: Gather Context

Run these commands in parallel:

1. `git status --short` to see all changed files
2. `git branch --show-current` to extract scope
3. `git log --oneline -5` to see recent commit style
4. **Default mode:** `git diff --stat` (unstaged) and `git diff --cached --stat` (staged) for change summaries.
5. **Staged-only mode:** Run `git diff --cached --name-only` and `git diff --cached --stat` only; skip unstaged `git diff` for grouping. Store the name-only list as the exclusive file set for later steps.

### Step 2: Unstage Everything

Run `git reset HEAD` so all changes are unstaged and you have full control over grouping.

In **staged-only mode**, this still applies so you can rebuild commits from subsets; only paths from the saved staged list may be added and committed in Steps 3–5.

### Step 3: Classify and Group

Analyze each file in scope and assign it to a logical group. In **staged-only mode**, scope is **only** the paths saved in Step 1 (ignore every other change in the working tree). Grouping criteria (in priority order):

1. **Feature cohesion** -- files that implement the same feature or fix belong together
2. **Layer separation** -- separate code changes from doc changes from test changes
3. **Dependency order** -- if group B depends on group A's changes, commit A first

**Heuristics for grouping:**

| File pattern | Likely type | Group with |
|---|---|---|
| `docs/**`, `*.md`, `*.ipynb` (study/tutorial) | `docs` | Other docs for the same topic |
| `src/**`, `lib/**` | `feat`, `fix`, `refactor` | See sub-grouping rules below |
| `tests/**`, `*_test.py`, `test_*.py` | `test` | Tests for the same module |
| `Makefile`, `BUILD`, `pyproject.toml`, `*.yml` (CI) | `ci` or `chore` | Build/config files |
| Config/deprecation changes in source | `chore` | Related config changes |

**Source file sub-grouping (never group all `src/**` together by default):**

Files under `src/**`, `lib/**`, and similar source roots must be further divided into sub-groups based on functional cohesion. Use the following signals — in priority order — to decide which files belong in the same commit:

1. **Domain / module boundary** — files that live in the same package, directory, or named module (e.g. `src/payments/`, `src/auth/`) and touch the same domain concept belong together. Files from different domains go into separate commits even if they share a commit type.

2. **Vertical slice** — files that implement a single end-to-end slice of behavior belong together regardless of layer (e.g. `src/orders/model.py` + `src/orders/service.py` + `src/orders/repository.py` when all three change together to introduce a new order state).

3. **Cross-cutting concern isolation** — changes that span multiple modules but address the same cross-cutting concern (logging format, error handling strategy, a shared utility extraction) form their own commit, separate from feature changes in individual modules.

4. **Refactor vs. behavior change** — within the same module, separate pure structural refactors (`refactor`) from changes that alter observable behavior (`feat` or `fix`). Do not mix them in one commit unless the refactor is inseparable from the fix.

5. **Dependency direction** — if module A is modified to expose a new interface that module B is modified to consume, commit A before B; keep them as two commits.

**Practical sub-grouping examples:**

| Scenario | Result |
|---|---|
| `src/payments/gateway.py`, `src/payments/invoice.py` (same domain) | One `feat` or `fix` commit for the payments module |
| `src/payments/gateway.py`, `src/notifications/email.py` (different domains, related feature) | Two commits, one per domain |
| `src/orders/service.py` (new logic) + `src/orders/service.py` has unrelated dead-code removal | Split: one `feat` commit for the new logic, one `refactor` commit for the cleanup — unless the dead code is directly replaced by the new logic |
| `src/utils/logger.py`, `src/payments/gateway.py`, `src/auth/login.py` (all adopt new log format) | One `refactor` commit scoped to "logging" covering all three |
| New endpoint: `src/api/routes.py` + `src/api/handler.py` + `src/domain/entity.py` | One `feat` commit — vertical slice of a single capability |



### Step 4: Propose Plan

Before committing, present the grouping plan as a table:

```
| # | Type | Files | Message |
|---|------|-------|---------|
| 1 | docs | file1.md, file2.md | docs(<scope>): description |
| 2 | feat | module.py, helper.py | feat(<scope>): description |
```

Ask the user to confirm or adjust before proceeding.

### Step 5: Execute Commits

For each group, in order:

```bash
git add <files...>
git commit -m "<type>(<scope>): <message>"
```

### Step 6: Verify

Run `git log --oneline -N` (where N = number of commits created) and `git status`. In **default mode**, confirm the intended changes are committed and the tree matches expectations. In **staged-only mode**, expect unstaged files to remain; confirm only the staged snapshot was committed and nothing outside that set was added.

### Step 7: Produce the commit script

**This step is the required final product of the skill.** Instead of (or in addition to) executing commits directly, always generate an executable Python script named `commit_groups_<scope>.py` in the repository root of the application being worked on (e.g. `apps/my-service/commit_groups_PROJ-456.py`).

The script must:

- Define a `COMMITS` list of dicts, each with `"message"` and `"files"` keys, in the planned commit order.
- When run **without arguments**: print the full plan — all commit messages and their file lists — and exit without touching git.
- When run **with `--exec`**: prompt for confirmation (`[y/N]`), then run `git reset HEAD`, stage each group with `git add`, commit it, and print a final `git log --oneline -N` summary.
- Resolve the repository root via `git rev-parse --show-toplevel` so it works from any directory.
- Exit with code `1` and print the error on any `git` failure.

Minimal structure:

```python
#!/usr/bin/env python3
"""
Commit grouping plan for <branch>
Generated by smart-commit-grouping

Usage:
  python3 commit_groups_<scope>.py          # dry-run: print the plan
  python3 commit_groups_<scope>.py --exec   # execute the commits
"""

import subprocess
import sys

# fmt: off
COMMITS = [
    {
        "message": "<type>(<scope>): <description>",
        "files": [
            "path/to/file_a.kt",
            "path/to/file_b.kt",
        ],
    },
    # ...
]
# fmt: on


def git(cmd: str, cwd: str) -> str:
    result = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"\nERROR running: {cmd}")
        print(result.stderr)
        sys.exit(1)
    return result.stdout.strip()


def get_repo_root() -> str:
    result = subprocess.run(
        "git rev-parse --show-toplevel", shell=True, capture_output=True, text=True
    )
    if result.returncode != 0:
        print("ERROR: not inside a git repository")
        sys.exit(1)
    return result.stdout.strip()


def print_plan() -> None:
    total_files = sum(len(c["files"]) for c in COMMITS)
    print()
    print("=" * 72)
    print("PROPOSED COMMIT GROUPS")
    print("=" * 72)
    for i, commit in enumerate(COMMITS, 1):
        print(f"\n  [{i}] {commit['message']}")
        for f in commit["files"]:
            print(f"       {f}")
    print()
    print(f"  {len(COMMITS)} commits  |  {total_files} files")
    print("=" * 72)


def execute_commits(repo_root: str) -> None:
    print("\nResetting staged changes...")
    git("git reset HEAD", repo_root)

    for i, commit in enumerate(COMMITS, 1):
        msg = commit["message"]
        files = " ".join(f'"{f}"' for f in commit["files"])
        print(f"\n[{i}/{len(COMMITS)}] {msg}")
        git(f"git add -- {files}", repo_root)
        git(f'git commit -m "{msg}"', repo_root)
        print("    committed.")

    print()
    print("=" * 72)
    print(git(f"git log --oneline -{len(COMMITS)}", repo_root))
    print("=" * 72)


if __name__ == "__main__":
    repo_root = get_repo_root()
    print_plan()

    if "--exec" in sys.argv:
        answer = input("\nExecute these commits? [y/N] ").strip().lower()
        if answer == "y":
            execute_commits(repo_root)
        else:
            print("Aborted.")
    else:
        print("\nRun with --exec to execute the commits.")
```

After writing the script, make it executable (`chmod +x`) and do a dry-run to confirm the plan renders correctly before presenting it to the user.

## Rules

- **Staged-only requests:** Restrict analysis, grouping, `git add`, and commits to the staged snapshot from Step 1; do not fold in unstaged files.
- **Never** commit files the user explicitly excluded.
- **Never** commit files that look like secrets (`.env`, `credentials.json`, etc.) without explicit confirmation.
- Keep commit messages under 72 characters.
- Use imperative mood in descriptions ("add", "fix", "update", not "added", "fixed", "updated").
- When renaming files that also have content changes, keep rename + content update in the same commit.
- If cross-references between files were updated as part of a rename, include those in the same commit as the rename.

## Example

Given branch `feat/PROJ-123` with these changes:

```
M  docs/overview.md
A  docs/architecture.md
M  src/lib/writer.py
A  studies/notebook.ipynb
M  mkdocs.yml
```

Proposed grouping:

| # | Type | Files | Message |
|---|------|-------|---------|
| 1 | `docs` | `docs/overview.md`, `docs/architecture.md`, `mkdocs.yml` | `docs(PROJ-123): add architecture doc and update overview` |
| 2 | `chore` | `src/lib/writer.py` | `chore(PROJ-123): deprecate legacy writer path` |
| 3 | `docs` | `studies/notebook.ipynb` | `docs(PROJ-123): add study notebook for writer migration` |
