local hooks = require "ibl.hooks"

local highlight = {
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowViolet",
  "RainbowCyan",
}
local highlight_defaults = {
  RainbowYellow = { fg = "#E5C07B", default = true },
  RainbowBlue = { fg = "#61AFEF", default = true },
  RainbowOrange = { fg = "#D19A66", default = true },
  RainbowViolet = { fg = "#C678DD", default = true },
  RainbowCyan = { fg = "#56B6C2", default = true }
}

-- Set default highlights for the indentation guides.  By doing it this way, it
-- can seemlessly integrate with any colorscheme that provides custom
-- highlights for indent-blankline. (This hook runs via colorscheme).
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  for _, hl in ipairs(highlight) do
    vim.api.nvim_set_hl(0, hl, highlight_defaults[hl])
  end
end)

-- Integrate multiline highlights with rainbow-delimiters.nvim
-- NOTE: This is actually a rainbow-delimiters.nvim setting
vim.g.rainbow_delimiters = {
  highlight = highlight
}

require("ibl").setup {
  enabled = not vim.startswith(vim.env.TERM, "linux"), -- Default off in TTY
  scope = {
    -- Sets up colored indentation guides
    highlight = highlight
  }
}
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
