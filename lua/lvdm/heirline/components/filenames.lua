local utils = require "heirline.utils"
local conditions = require "heirline.conditions"

local M = {}

-- Shortest relative path when under current dir, otherwise full path. Contrary
-- to `%f`, this simplifies filenames (e.g. `foo/.././foo/bar` -> `foo/bar`)
M.Relative = {
  provider = function ()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" then return "[No Name]" end
    filename = vim.fn.fnamemodify(filename, ":.")

    if not conditions.width_percent_below(#filename, 0.40) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end
}

M.Tail = {
  provider = function ()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" then return "[No Name]" end
    return vim.fn.fnamemodify(filename, ":t")
   end
}

M.Special = {
  fallthrough = false,
  {
    condition = function() return vim.bo.buftype == "quickfix" end,
    provider = function ()
      local isLocList = vim.fn.getwininfo(vim.fn.win_getid())[1].loclist == 1
      if isLocList then
        return vim.fn.getloclist(0, { title = true }).title
      end
      return vim.fn.getqflist({ title = true }).title
    end
  },
  {
    condition = function() return vim.bo.buftype == "terminal" end,
    provider = function () return vim.b.term_title end
  },
  {
    provider = function ()
      local filename = vim.api.nvim_buf_get_name(0)
      return vim.fn.fnamemodify(filename, ":t")
     end
  }
}

M.Terminal = {
  provider = function ()
    return vim.b.term_title
   end
}

return M
