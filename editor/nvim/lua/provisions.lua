local M = {}

M.config = {
  base_dir = vim.env.OP_ENV_DIR or "~/.config/op/environments",
  default_profile = "nvim",
  default_event = "VimEnter",
  notify = true,
  create_user_command = true,
}

local function _notify(msg, level)
  if not M.config.notify then
    return
  end
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO)
  end)
end

local Log = {}

function Log.error(msg)
  _notify(" Provisions: " .. msg, vim.log.levels.ERROR)
end

function Log.warn(msg)
  _notify(" Provisions: " .. msg, vim.log.levels.WARN)
end

function Log.loading()
  _notify("󰌾 Provisions: loading secrets with op inject...", vim.log.levels.INFO)
end

function Log.inject_failed(msg)
  _notify("󱙱 Provisions: op inject failed: " .. msg, vim.log.levels.INFO)
end

function Log.loaded(count)
  _notify(("󱎜  Provisions: loaded %d secret vars"):format(count), vim.log.levels.INFO)
end

local function _trim(s)
  return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function _is_valid_profile(profile)
  -- strict single token
  return type(profile) == "string" and profile ~= "" and profile:match("^[A-Za-z0-9_-]+$") ~= nil
end

local function _profile_to_file(profile)
  if not _is_valid_profile(profile) then
    return nil, "invalid profile (allowed: A-Z, a-z, 0-9, _, -)"
  end

  local base = _trim(M.config.base_dir)
  if base == "" then
    return nil, "base_dir is empty"
  end

  return vim.fn.expand(base .. "/" .. profile .. ".env"), nil
end

local function _parse_dotenv(content)
  local out = {}

  for _, raw in ipairs(vim.split(content or "", "\n", { plain = true })) do
    local line = _trim(raw)

    if line ~= "" and not line:match("^#") then
      line = line:gsub("^export%s+", "")
      local key, val = line:match("^([%w_]+)%s*=%s*(.+)$")
      if key and val then
        val = _trim(val)
        val = val:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        out[key] = val
      end
    end
  end

  return out
end

function M.load_profile(profile)
  local p = profile or M.config.default_profile
  local file, err = _profile_to_file(p)
  if err or type(file) ~= "string" or file == "" then
    Log.error(err or "invalid resolved file path")
    return
  end

  if vim.fn.executable("op") == 0 then
    Log.error("`op` CLI not found in PATH")
    return
  end

  if vim.fn.filereadable(file) == 0 then
    Log.warn("secrets file not found: " .. file)
    return
  end

  Log.loading()

  vim.system({ "op", "inject", "-i", file }, { text = true }, function(obj)
    if obj.code ~= 0 then
      local err_msg = (obj.stderr and obj.stderr ~= "") and obj.stderr or ("exit " .. tostring(obj.code))
      Log.inject_failed(err_msg)
      return
    end

    local parsed = _parse_dotenv(obj.stdout or "")
    local loaded = 0

    for key, val in pairs(parsed) do
      loaded = loaded + 1
      vim.schedule(function()
        vim.env[key] = val
      end)
    end

    Log.loaded(loaded)
  end)
end

-- event defaults to VimEnter; profile defaults to config.default_profile
function M.load_secrets(event, profile)
  local ev = event or M.config.default_event
  local p = profile or M.config.default_profile

  if type(ev) ~= "string" or ev == "" then
    Log.error("invalid event name")
    return
  end

  if ev == "VimEnter" and vim.v.vim_did_enter == 1 then
    M.load_profile(p)
    return
  end

  vim.api.nvim_create_autocmd(ev, {
    once = true,
    callback = function()
      M.load_profile(p)
    end,
  })
end

function M.create_commands()
  vim.api.nvim_create_user_command("Provision", function(opts)
    if #opts.fargs ~= 1 then
      Log.error("usage: :Provision <profile>")
      return
    end

    local profile = opts.fargs[1]
    if not _is_valid_profile(profile) then
      Log.error("invalid profile (allowed: A-Z, a-z, 0-9, _, -)")
      return
    end

    M.load_profile(profile)
  end, {
    nargs = 1,
    desc = "Load 1Password env profile from <base_dir>/<profile>.env",
  })
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  if M.config.create_user_command then
    M.create_commands()
  end
end

return M
