# Dotfiles Git Commit Rules

## Types with Emoji

As these are my personal dotfiles, we use conventional commits with emojis, which makes it more fun and easy to scan visually. Use this mapping:

- `feat` ✨
- `fix` 🐛
- `chore` 🧰
- `docs` 📚
- `refactor` ♻️
- `style` 🎨
- `test` 🧪
- `build` 🛠️
- `ci` 🚧
- `perf` ⚡
- `revert` 📼

## Scopes

Use specific tool scopes for existing tools, with the exception of Starship, which should be labelled 'prompt'.

**Examples**:

- `feat(nvim): ✨ added bufferline plugin`
- `chore(fzf): 🧰 changed default preview style`
- `chore(git): 🧰 updated delta git pager theme`
- `fix(prompt): 🐛 removed deprecated config` (Starship bug fix)
