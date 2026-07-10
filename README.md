Inside `dotfiles` folder run:

```bash
ln -s "$(pwd)/bash-scripts/" ~/
```

Cursor skills (`create-pr-global`, `smart-commit-grouping`, `smart-commit-grouping-lite`) live under `.cursor/skills/`. Symlink each folder into `~/.cursor/skills/`:

```bash
for skill in create-pr-global smart-commit-grouping smart-commit-grouping-lite; do
  ln -sfn "$(pwd)/.cursor/skills/$skill" "$HOME/.cursor/skills/$skill"
done
```
