# dotfiles

Personal shell config and shared agent skills for Cursor and Claude Code.

## First time setup

Clone and enter the repo:

```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
```

### 1. Shell config

Symlink the files you use (adjust paths if your clone lives elsewhere):

```bash
ln -sfn "$(pwd)/.zshrc" "${HOME}/.zshrc"
ln -sfn "$(pwd)/.zprofile" "${HOME}/.zprofile"
ln -sfn "$(pwd)/.gitconfig" "${HOME}/.gitconfig"
ln -sfn "$(pwd)/.p10k.zsh" "${HOME}/.p10k.zsh"
```

Reload the shell:

```bash
exec zsh
```

### 2. Bash scripts

Makes helper scripts available as `~/git-sandbox`, `~/link-agent-skills`, etc.:

```bash
ln -s "$(pwd)/bash-scripts/" "${HOME}/"
```

### 3. Agent skills (Cursor + Claude)

Skills live in `.cursor/skills/` inside this repo. The install script symlinks each skill into both global directories:

- `~/.cursor/skills/` (Cursor)
- `~/.claude/skills/` (Claude Code)

Run once after clone (and again whenever you add a new skill to dotfiles):

```bash
bash bash-scripts/link-agent-skills
```

If you already linked `bash-scripts/` to `~/`, you can also run:

```bash
link-agent-skills
```

Current skills:

- `create-pr-global`
- `smart-commit-grouping`
- `smart-commit-grouping-lite`

### 4. Verify

```bash
ls -la ~/.cursor/skills/create-pr-global
ls -la ~/.claude/skills/create-pr-global
```

Both should point to your dotfiles clone. Restart Cursor or Claude Code if a session was already open.

## Updating skills

Edit files under `.cursor/skills/` in this repo, commit, push, then on other machines:

```bash
cd ~/projects/dotfiles
git pull
link-agent-skills
```

No re-link is needed if symlinks already point at dotfiles; `git pull` is enough. Re-run `link-agent-skills` only when adding a new skill folder.
