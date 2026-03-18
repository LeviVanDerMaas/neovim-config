local utils = require "heirline.utils"
local blocks = require "plugins.heirline.components.blocks"

-- Module that initally sets up heirline colors, as well as provides
-- some color-related utility for use by components
local M = {}

function M.setup_colors()
  -- With NONE we fallback to whatever highlights parent components set, or
  -- what the colorscheme itself has set (e.g. hi-StatusLine) Can't use an
  -- __index metatable because heirline only copies values.
  local default_colors = {
    mode_normal = "NONE",
    mode_visual = "NONE",
    mode_select = "NONE",
    mode_insert = "NONE",
    mode_replace = "NONE",
    mode_command = "NONE",
    mode_terminal = "NONE",

    modified_current = utils.get_highlight("DiagnosticError").fg,
    modified_noncurrent = utils.get_highlight("DiagnosticWarn").fg,

    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,

    git_branch = "NONE",

    ruler = "NONE",
    buffer_progress = "NONE"
  }

  local colorscheme =  vim.g.colors_name
  local has_mapping, colorscheme_colors =
    pcall(require, "plugins.heirline.colors.colorscheme_colors." .. colorscheme)
  if has_mapping then
    return vim.tbl_extend("keep", colorscheme_colors, default_colors)
  end
  return default_colors
end

-- Automatically rerun color setup on colorscheme switch
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("plugins.heirline", { clear = false }),
  callback = function ()
    utils.on_colorscheme(M.setup_colors)
  end
})

-- Maps a mode-string (`:h mode()`) to a corresponding color.
-- If a longer mode-string (i.e. a more specific sub-mode) is not in the table,
-- maps to a shorter mode-string which is (i.e. a less specific sub-mode).
M.mode_colors = {
  n = "mode_normal",
  v = "mode_visual",
  V = "mode_visual",
  ["\22"] = "mode_visual",
  s = "mode_select",
  S = "mode_select",
  ["\19"] = "mode_select",
  i = "mode_insert",
  R = "mode_replace",
  c = "mode_command",
  r = "mode_command",
  ["!"] = "mode_command",
  t = "mode_terminal",
}
setmetatable(M.mode_colors, { __index = blocks.mapLargestPrefix })
-- Return color corresponding to the current mode
function M.get_mode_color()
  return M.mode_colors[vim.api.nvim_get_mode().mode]
end

return M
