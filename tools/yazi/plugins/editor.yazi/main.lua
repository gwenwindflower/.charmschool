--- editor.yazi — open $EDITOR from Yazi with proper terminal blocking.
--
-- Modes (passed as first arg):
--   "edit"     — open hovered item in $EDITOR (dirs as projects, files directly)
--   "git-root" — open $EDITOR at the git repo root of the current directory

-- Returns hovered URL and current cwd (both as strings).
-- Url objects can't cross the sync/async boundary, so we stringify here.
local get_context = ya.sync(function()
	local selected = #cx.active.selected
	if selected > 0 then
		return nil, nil, "selected"
	end

	local cwd = tostring(cx.active.current.cwd)
	local hovered = cx.active.current.hovered

	if not hovered then
		return nil, cwd, "empty"
	end

	return tostring(hovered.url), cwd, nil
end)

local function notify_warn(msg)
	ya.notify({ title = "editor", content = msg, level = "warn", timeout = 3 })
end

local function notify_error(msg)
	ya.notify({ title = "editor", content = msg, level = "error", timeout = 3 })
end

local function open_editor(path)
	local cmd = string.format("$EDITOR %s", ya.quote(path))
	ya.emit("shell", { cmd, block = true })
end

local function edit()
	local url, _, reason = get_context()

	if reason == "selected" then
		return notify_warn("Deselect files first (use `u` to clear selection)")
	end
	if reason == "empty" then
		return notify_warn("No hovered item")
	end

	open_editor(url)
end

local function git_root()
	local _, cwd, reason = get_context()

	if reason == "selected" then
		return notify_warn("Deselect files first (use `u` to clear selection)")
	end

	local output = Command("git"):arg("rev-parse"):arg("--show-toplevel"):cwd(cwd):output()

	if not output or not output.status.success then
		return notify_error("Not in a git repository")
	end

	local root = output.stdout:gsub("%s+$", "")
	if root == "" then
		return notify_error("Not in a git repository")
	end

	open_editor(root)
end

return {
	entry = function(_, job)
		local mode = job.args[1]
		if mode == "edit" then
			edit()
		elseif mode == "git-root" then
			git_root()
		else
			notify_error("Unknown editor mode: " .. tostring(mode))
		end
	end,
}
