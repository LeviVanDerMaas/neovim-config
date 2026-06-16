local conditions = require "heirline.conditions"
local blocks = require "levi.heirline.components.blocks"
local colors = require "levi.heirline.colors"

-- Maps values returned by `vim.fn.mode()` to a name. More specific modes
-- (longer strings) fallback to more generic ones (prefix that is defined).
-- `:help mode()` for more info.
local mode_names = {
  -- Base modes (single-char).
  n = "NORMAL",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
  i = "INSERT",
  R = "REPLACE",
  c = "COMMAND",
  r = "PROMPT",
  ["!"] = "SHELL",
  t = "TERMINAL",

  -- Operator pending
  no = "OPENDING",

  -- Ex mode
  cv = "EX",

  -- Virtual replacement mode
  Rv = "R-VIRT",

  -- i_CTRL-O (i.e.temporary NORMAL mode)
  niI = "I-NORMAL",
  niR = "R-NORMAL",
  niV = "R-NORMAL",
  nt = "T-NORMAL",

  -- v_CTRL-O (i.e. temporary VISUAL mode)
  vs = "V-SELECT",
  Vs = "V-SELECT",
  ["\22s"] = "V-SELECT",

  -- Completion modes
  ic = "I-COMPL",
  ix = "I-XCOMPL",
  Rc = "R-COMPL",
  Rx = "R-XCOMPL",
  Rvc = "R-COMPL",
  Rvx = "R-XCOMPL",
}
setmetatable(mode_names, { __index = blocks.mapLargestPrefix })

return {
  update = {
    "ModeChanged",
    -- Explicitly schedule redraw because O-PENDING does not trigger redraw by itself
    -- Also some plugins may cause textlock for other modes (e.g. which-key for Visual-L/B).
    callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
  },

  condition = conditions.is_active,
  init = function(self)
    self.mode = vim.api.nvim_get_mode().mode
  end,
  provider = function(self)
    return mode_names[self.mode]
  end,
  hl = function (self)
    return { fg = colors.mode_colors[self.mode], bold = true }
  end
}
