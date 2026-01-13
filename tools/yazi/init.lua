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
	hops = {
		{ key = "/", path = "/", desc = " Root" },
		{ key = "t", path = "/tmp", desc = " Temp" },
		{ key = "!", path = "~/.cache", desc = " User Cache" },
		{ key = "v", path = "~/Movies", desc = " Video" },
		{ key = "i", path = "~/Pictures/gallery-dl", desc = "󰈹 Images" },
		{ key = "n", path = "~/writing", desc = " Writing" },
		{ key = "h", path = "~", desc = " Home" },
		{ key = "m", path = "~/Music/_library", desc = " Music" },
		{ key = { "d", "p" }, path = "~/Desktop", desc = " Desktop" },
		{ key = { "d", "l" }, path = "~/Downloads", desc = " Downloads" },
		{ key = { "d", "c" }, path = "~/Documents", desc = " Documents" },
		{ key = "p", path = "~/dev", desc = " Projects" },
		{ key = "c", path = "~/.config", desc = " Config" },
		{ key = { "l", "s" }, path = "~/.local/share", desc = " Local share" },
		{ key = { "l", "n" }, path = "~/.local/share/nvim", desc = " Neovim Plugins" },
		{ key = { "l", "v" }, path = "~/.local/share/nvim/lazy/LazyVim", desc = "󰒲 LazyVim Repo" },
		{ key = { "l", "b" }, path = "~/.local/bin", desc = " Local bin" },
		{ key = { "a", "p" }, path = "/Applications", desc = " Applications" },
		{ key = { "a", "s" }, path = "~/Library/Application Support", desc = " Application Support" },
		{ key = { "b" }, path = "/usr/local/", desc = " Brew" },
		{ key = { "r" }, path = "~/.cargo", desc = "  Cargo" },
	},
	desc_strategy = "path",
	ephemeral = true,
	tabs = true,
	notify = false,
	fuzzy_cmd = "fzf",
})
