return {
  "nvimdev/dashboard-nvim",
  lazy = true,
  event = "VimEnter",
  opts = function(_, opts)
    local icons = {
      "󰥨 ",
      "󰎔 ",
      " ",
      "󰈞 ",
      " ",
      " ",
      " ",
      "󰒲 ",
      " ",
    }
    local logo = [[
██╗    ██╗██╗███╗   ██╗██╗   ██╗██╗███╗   ███╗
██║    ██║██║████╗  ██║██║   ██║██║████╗ ████║
██║ █╗ ██║██║██╔██╗ ██║██║   ██║██║██╔████╔██║
██║███╗██║██║██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
╚███╔███╔╝██║██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]]
    logo = string.rep("\n", 8) .. logo .. "\n\n"
    opts.config.header = vim.split(logo, "\n")
    for index, value in pairs(opts.config.center) do
      value.icon = icons[index]
    end
  end,
}
