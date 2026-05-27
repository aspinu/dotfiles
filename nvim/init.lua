-- require("vim._core.ui2").enable({})

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.treesitter")
require("config.lsp")
require("plugins.snacks")
require("plugins.blink")
require("plugins.colorscheme")

vim.cmd.colorscheme("ayu-dark")
