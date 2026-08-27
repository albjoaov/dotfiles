---
name: create-pr-global
description: >-
  Create or update a GitHub PR from the remote diff. Use when asked to create,
  open, or update a pull request description.
---

# Create PR

Analyze the **GitHub PR diff only**, fill `$HOME/.cursor/skills/create-pr-global/pull_request_template.md`, and update the PR immediately.

## 1. Fetch diff

| Input | Command |
|-------|---------|
| PR URL or number | `gh pr diff <N>` |
| Branch name or none (current branch) | `bash $HOME/.cursor/skills/create-pr-global/show-pr-diff-on-create.sh [BRANCH]` |

- Always run scripts with `bash` (not as bare executables).
- Read `PR_METADATA_NUMBER=` and `PR_METADATA_URL=` from script stdout before the diff.
- **Never** pipe diff output through `head`, `tail`, `grep`, or similar.

**Branch not pushed:** if the script errors with `is not pushed to remote`, ask whether to run `git push -u origin <branch>`, then retry.

## 2. Write title and body

- Base content **only** on the diff. Do not read changed files from disk, and do not use `git diff`, `git log`, or `git status` for PR analysis.
- Keep text short and objective.
- Title: conventional commit (`feat:`, `fix:`, `chore:`, ...). If the branch name contains a ticket like `PROJ-123`, use `feat(PROJ-123): summary`.
- Body: fulfill every section of the template in markdown.

## 3. Update PR (no confirmation)

```bash
bash $HOME/.cursor/skills/create-pr-global/update-pr.sh <PR_NUMBER> "<title>" <<'EOF'
<body>
EOF
```

- Use `PR_METADATA_NUMBER` when the fetch script ran; otherwise the input PR number.
- **Never** use `gh pr edit` (breaks on repos with GitHub Projects classic).
- **Never** use `gh pr create` to update an existing PR.
- Execute immediately. Do not ask for approval.

## Response

One or two sentences plus the PR link (`PR_METADATA_URL` when available). Do not paste the full body.
