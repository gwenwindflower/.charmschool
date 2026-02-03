local bookmarks = {
	{ key = "@", path = "~", desc = " User Home" },
	{ key = { "c", "f" }, path = "~/.config", desc = " User Config" },
	{ key = { "c", "m" }, path = "~/.charmschool", desc = " My Dotfiles" },
	{ key = { "c", "s" }, path = "~/.charmschool/agents/claude/skills/agent-skills", desc = " Agent Skills" },
	{ key = "w", path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents", desc = "󰓥 Obsidian" },
	{ key = { "c", "c" }, path = "~/.claude", desc = "󱜙 Claude Code Config" },
	{
		key = { "c", "d" },
		path = "/Users/winnie/Library/Application Support/Claude",
		desc = "󰢹 Claude Desktop Config",
	},

	{ key = { "b" }, path = "/usr/local/", desc = " Brew" },
	{ key = { "l", "b" }, path = "~/.local/bin", desc = " Local bin" },
	{ key = { "l", "s" }, path = "~/.local/share", desc = " Local share" },
	{ key = { "c", "z" }, path = "~/.local/share/chezmoi", desc = "󰠧 Chez Moi" },
	{ key = { "l", "n" }, path = "~/.local/share/nvim", desc = " Neovim Plugins" },
	{ key = { "l", "v" }, path = "~/.local/share/nvim/lazy/LazyVim", desc = "󰒲 LazyVim Repo" },
	{ key = { "m", "i" }, path = "~/.local/share/mise/installs/", desc = "󰭼 Mise Installs" },
	{ key = { "l", "s" }, path = "~/.local/state", desc = " Local state" },
	{ key = "$", path = "~/.cache", desc = " User Cache" },
	{ key = { "r" }, path = "~/.cargo", desc = "  Cargo" },
	{ key = { "r" }, path = "~/.go", desc = " Go Home" },
	{ key = "*", path = "/", desc = " Root" },
	{ key = "#", path = "/tmp", desc = " Temp" },
	{ key = "p", path = "~/dev", desc = " Projects" },
	{ key = { "d", "l" }, path = "~/Downloads", desc = " Downloads" },
	{ key = { "d", "p" }, path = "~/Desktop", desc = " Desktop" },
	{ key = { "d", "c" }, path = "~/Documents", desc = " Documents" },
	{ key = { "v", "i" }, path = "~/Pictures/gallery-dl", desc = "󰈹 Images" },
	{ key = { "v", "m" }, path = "~/Music/_library", desc = " Music" },
	{ key = { "v", "v" }, path = "~/Movies", desc = " Video" },
	{ key = { "a", "p" }, path = "/Applications", desc = " Applications" },
	{ key = { "a", "s" }, path = "~/Library/Application Support", desc = " Application Support" },
}
-- show git status symbols in yazi explorer
require("git"):setup()

-- keep starship up while using yazi
require("starship"):setup()

-- show full border around yazi,
-- works nicely witht the above
require("full-border"):setup({
	type = ui.Border.ROUNDED,
})

-- allows using fish from yazi
-- feels more intuitive because of starship visibility
require("custom-shell"):setup({
	history_path = "default",
	save_history = true,
})
-- TODO: fix missing Yazi Types in LuaLS
-- TODO: play around with formatting these examples of using the status bar api
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Line({
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)

-- hella cute bookmark manager
require("bunny"):setup({
	hops = bookmarks,
	desc_strategy = "path",
	ephemeral = true,
	tabs = true,
	notify = false,
	fuzzy_cmd = "fzf",
})
