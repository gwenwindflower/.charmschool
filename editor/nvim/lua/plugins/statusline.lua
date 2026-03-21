return {
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      -- The LazyVim Copilot and Sidekick Extras both add a  icon
      -- to lualine, which bugs me, so this triple backflip is to
      -- check if Sidekick is active and added an icon,
      -- in which case we hide Copilot's icon
      local section = opts.sections and opts.sections.lualine_x
      if type(section) ~= "table" then
        return
      end

      local function sidekick_active()
        local ok, sk = pcall(require, "sidekick.status")
        if not ok or type(sk.get) ~= "function" then
          return false
        end
        local ok_get, status = pcall(sk.get)
        return ok_get and status ~= nil
      end

      local function is_copilot_extra_component(component)
        if type(component) ~= "table" or type(component.cond) ~= "function" then
          return false
        end

        local i = 1
        while true do
          local upname, upvalue = debug.getupvalue(component.cond, i)
          if not upname then
            break
          end
          if upname == "status" and type(upvalue) == "function" then
            local src = (debug.getinfo(upvalue, "S").source or "")
            if src:match("extras[/\\]ai[/\\]copilot%.lua") then
              return true
            end
          end
          i = i + 1
        end

        return false
      end

      for _, component in ipairs(section) do
        if is_copilot_extra_component(component) then
          local old_cond = component.cond
          component.cond = function(...)
            if sidekick_active() then
              return false
            end
            return old_cond(...)
          end
        end
      end
    end,
  },
}
