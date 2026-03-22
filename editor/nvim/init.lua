-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("markdown-utils").setup()
require("provisions").setup()
require("provisions").load_secrets()
