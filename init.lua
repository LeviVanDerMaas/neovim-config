vim.loader.enable() -- Enables module caching between sessions. Call ASAP.

-- Set these very early as keymaps expand <leader> upon definition
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- CORE
require "core.options"
require "core.keymaps"
require "core.diagnostics"

-- QUALITY OF LIFE
require "plugins.heirline"
require "plugins.guess-indent"
require "plugins.which-key"
require "plugins.smear-cursor"
require "plugins.nvim-surround"
require "plugins.indent-blankline"
require "plugins.neotree"

-- GIT INTEGRATION
require "plugins.gitsigns"

-- TELESCOPE
require "plugins.telescope"

-- TREESITTER
require "plugins.treesitter"

-- LSP
require "plugins.lsp"
require "plugins.tiny-inline-diagnostic"
require "plugins.blink-cmp"
require "plugins.fidget"

-- COLORSCHEME (prefer loading this late)
require "plugins.catppuccin"
