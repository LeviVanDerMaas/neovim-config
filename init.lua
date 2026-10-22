vim.loader.enable() -- Enables module caching between sessions, including (ft)plugin/

require "core.saferequire" {
  -- CORE
  "core.options",
  "core.keymaps",
  "core.diagnostics",
  "core.folds",

  -- TREESITTER
  "plugins.treesitter",

  -- LSP
  "plugins.lsp",
  "plugins.tiny-inline-diagnostic",
  "plugins.blink-cmp",
  "plugins.fidget",

  -- QUALITY OF LIFE
  "plugins.heirline",
  "plugins.guess-indent",
  "plugins.specs",
  "plugins.which-key",
  "plugins.nvim-surround",
  "plugins.indent-blankline",
  "plugins.neotree",

  -- TELESCOPE
  "plugins.telescope",

  -- GIT INTEGRATION
  "plugins.gitsigns",

  -- COLORSCHEME (prefer loading this late)
  "plugins.catppuccin"
}
