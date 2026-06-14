local utils = require "heirline.utils"

-- Supports file icons but requires nvim-web-devicons for it to work
return {
  condition = function() return vim.bo.filetype ~= "" end,
  {
    init = function(self)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
      local extension = vim.fn.fnamemodify(filename,  ":e")
      self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
      return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end
  },
  {
    provider = function() return vim.bo.filetype end,
    hl = { bold = true },
  }
}

