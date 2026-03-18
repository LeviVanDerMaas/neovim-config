local hooks = require "ibl.hooks"

local highlight = {
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}
-- We do this seperately instead of using a loop to ensure ordering.
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
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  for _, hl in ipairs(highlight) do
    local cur_hl = vim.api.nvim_get_hl(0, { name = hl })
    if vim.tbl_isempty(cur_hl) then
      vim.api.nvim_set_hl(0, hl, highlight_defaults[hl])
    end
  end
end)

-- Integrate multiline highlights with rainbow-delimers.nvim
vim.g.rainbow_delimiters = {
  highlight = highlight
}

require("ibl").setup {
  scope = {
    -- Sets up colored indentation guides
    highlight = highlight
  }
}
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
