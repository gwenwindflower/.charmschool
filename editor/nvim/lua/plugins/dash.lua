local art = require("dashboard-art")

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = art.metalcore_heart,
          keys = function()
            -- Setup for dyanmic remote git platform shortcut (b to browse repo on GitHub/GitLab/Bitbucket)
            local git_helpers = require("git-dashboard-helpers")
            local platform_icons = git_helpers.git_platform_icons
            local platform_names = git_helpers.git_platform_names
            local platform = git_helpers.detect_git_platform(Snacks.git.get_root())
            local open_repo_key = {}
            open_repo_key.icon = platform_icons[platform.name] or " "
            local desc = "Local only"
            if platform.name and platform.repo_url then
              desc = "Open on " .. platform_names[platform.name]
            end
            open_repo_key.desc = desc
            open_repo_key.key = "b"
            open_repo_key.action = ":lua Snacks.gitbrowse()"
            local should_enable = true
            if platform.platform_name == nil and platform.repo_url == nil then
              should_enable = false
            end
            open_repo_key.enabled = should_enable
            return {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              {
                icon = " ",
                key = "c",
                desc = "Dotfiles",
                action = ":lua Snacks.dashboard.pick('files', {cwd = '~/.charmschool'})",
              },
              { icon = " ", key = "s", desc = "Restore Session", section = "session" },
              { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
              {
                icon = " ",
                key = "x",
                desc = "Lazy Extras",
                action = ":Lazy",
                enabled = package.loaded.lazy ~= nil,
              },
              open_repo_key,
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            }
          end,
        },
        sections = {
          { section = "header" },
          {
            section = "keys",
            gap = 1,
            padding = 1,
          },
          function()
            local in_git = Snacks.git.get_root() ~= nil
            local cmds = {
              {
                icon = "",
                title = "Status",
                cmd = "gstat",
                padding = 1,
                height = 2,
              },
            }
            return vim.tbl_map(function(cmd)
              return vim.tbl_extend("force", {
                section = "terminal",
                enabled = in_git,
                ttl = 0,
                indent = 3,
              }, cmd)
            end, cmds)
          end,
        },
      },
    },
  },
}
