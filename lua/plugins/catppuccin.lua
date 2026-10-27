-- Theme has a lot of config settings, check 'em on gh:
-- https://github.com/catppuccin/nvim If you want to change something about ui
-- colors, chances are you can do it more easily and consistenly with this
-- setup function instead. Also has plenty of integrations for other plugins
require("catppuccin").setup {
  flavour = "auto",
  background = {
    light = "latte",
    dark = "mocha",
  },
  float = {
    transparent = true,
  },

  integrations = {
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true
    }
  }
}
-- Catppuccin requires 'termguicolors' (and forces it), breaking this
-- colorscheme in terminals that don't support it (e.g. Linux TTY). Neovim
-- heuristically figures out if terminal supports 'termguicolors' and sets the
-- option by default; but only after user config runs. Deferring the
-- colorscheme to VimEnter lets us set it based on terminal support.
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true, -- Plugins that refresh on colorscheme can't detect without this.
  once = true,
  callback = function()
    if vim.o.termguicolors then
      vim.cmd.colorscheme "catppuccin"
    end
  end
})
