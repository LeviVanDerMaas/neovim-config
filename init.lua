vim.loader.enable() -- Enables module caching between sessions, including (ft)plugin/

require "core.saferequire" {
  -- CORE
  "core.options",
  "core.keymaps",
  "core.diagnostics",

  -- QUALITY OF LIFE
  "plugins.heirline",
  "plugins.guess-indent",
  "plugins.which-key",
  "plugins.nvim-surround",
  "plugins.indent-blankline",
  "plugins.neotree",

  -- GIT INTEGRATION
  "plugins.gitsigns",

  -- TELESCOPE
  "plugins.telescope",

  -- TREESITTER
  "plugins.treesitter",

  -- LSP
  "plugins.lsp",
  "plugins.tiny-inline-diagnostic",
  "plugins.blink-cmp",
  "plugins.fidget",

  -- COLORSCHEME (prefer loading this late)
  "plugins.catppuccin"
}
