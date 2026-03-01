# LazyVim + tmux Integration Suggestions

Suggestions for making the Neovim statusline (lualine) visually harmonize with the primary-tmux inspired tmux status bar.

## 1. Matching Lualine Config

The primary-tmux repo includes a lualine config that mirrors the tmux aesthetic: transparent backgrounds, thin `│` separators, bold Catppuccin accent colors, and no rounded/powerline glyphs.

To adopt this, create `editor/nvim/lua/plugins/lualine.lua` based on the repo's `lualine.lua`. Key design choices:

- **No section separators** — clean, flat look that matches the tmux bar
- **Thin pipe `│` separators** between logical groups (same as tmux status)
- **Color-coded sections**: red for mode/location, green for git, blue for file info, yellow for encoding/buffers
- **Single-letter mode indicator** — minimal, doesn't fight the tmux session name for attention
- **Diagnostics with dynamic colors** — green when 0 issues, warning color when issues exist

Since you already have `transparent_background = true` in Catppuccin, the lualine `bg = "NONE"` will blend seamlessly.

## 2. vim-tmux-navigator (Already Set Up)

Your config already has `christoomey/vim-tmux-navigator` in both tmux and Neovim (`ux.lua:68-83`). The new tmux config keeps this plugin and adds prefix+hjkl as a fallback. No changes needed.

## 3. Pane Border Color Harmony

The new tmux config uses `@thm_mauve` (#ca9ee6) for active pane borders. Consider matching Neovim's `WinSeparator` highlight:

```lua
-- In colors.lua custom_highlights:
WinSeparator = { fg = colors.surface1 },
```

This keeps inactive splits subtle and lets the tmux active border provide the "where am I" signal.

## 4. Status Position Alignment

Both tmux status (top) and lualine (bottom, LazyVim default) create a clean frame around the editor. If you want to move lualine to the top to stack with tmux, that's possible but **not recommended** — the spatial separation (tmux info top, editor info bottom) reduces visual clutter.

## 5. tmux-cpu Plugin Note

The original repo uses `thewtex/tmux-mem-cpu-load` for memory stats with a custom awk pipeline. The new config uses `tmux-plugins/tmux-cpu` instead (which you already have installed) since it provides both `#{cpu_percentage}` and `#{ram_percentage}` without the external binary dependency. The trade-off is slightly less granular memory reporting, but cleaner dependencies.

## 6. Font Requirement

The icon-based window tabs require a Nerd Font. Kitty with a patched font (which your setup likely already has for LazyVim icons) will render these correctly. If any icons appear as boxes, verify your font includes the Nerd Font glyphs with:

```bash
kitty +list-fonts --psnames | rg -i "nerd"
```
