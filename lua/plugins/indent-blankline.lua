local hooks = require "ibl.hooks"

local highlight = {
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}
local highlight_defaults = {
  RainbowYellow = { fg = "#E5C07B" },
  RainbowBlue = { fg = "#61AFEF" },
  RainbowOrange = { fg = "#D19A66" },
  RainbowGreen = { fg = "#98C379" },
  RainbowViolet = { fg = "#C678DD" },
  RainbowCyan = { fg = "#56B6C2" }
}

-- Sets up default values for highlight groups that we use to color
-- the highlights. This hook triggers just before highlights are setup,
-- i.e. when the colorscheme is chagnged. By setting default values like
-- these, we can integrate with other theme plugins without messing things
-- up when a colorscheme does not provide these highlights.

-- Set default highlights for the indentation guides.  By doing it this way, it
-- can seemlessly integrate with any colorscheme that provides custom
-- highlights for indent-blankline. (This hook runs via colorscheme).
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  for _, hl in ipairs(highlight) do
    local cur_hl = vim.api.nvim_get_hl(0, { name = hl })
    if vim.tbl_isempty(cur_hl) then
      vim.api.nvim_set_hl(0, hl, highlight_defaults[hl])
    end
  end
end)

-- Integrate multiline highlights with rainbow-delimers.nvim
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
