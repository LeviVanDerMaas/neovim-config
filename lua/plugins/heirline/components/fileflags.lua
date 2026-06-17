-- A table of different file flags
local M = {}

M.Modifiable = {
  condition = function()
    return not vim.bo.modifiable or vim.bo.readonly
  end,
  provider = function()
    -- The no-modifiable flag is  "stronger" than the RO flag
    if not vim.bo.modifiable then
      return "[-]"
    end
    return "[RO]"
  end
}

M.Preview = {
  condition = function()
    return vim.wo.previewwindow
  end,
  provider = "[Preview]"
}


local buftypeStrings = {
  acwrite = "[BufWriteCmds]",
  help = "[Help]",
  nofile = "[NoFile]",
  nowrite = "[NoWrite]",
  terminal = "[Terminal]",
  prompt = "[Prompt]",
  quickfix = "%q",
}

M.Buftype = {
  condition = function()
    return vim.bo.buftype ~= ""
  end,
  provider = function()
    return buftypeStrings[vim.bo.buftype]
  end
}

M.Encoding = {
  condition = function(self)
    self.enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
    return self.enc ~= "utf-8"
  end,
  provider = function(self)
    return "[" .. self.enc:upper() .. "]"
  end
}

M.Format = {
  condition = function(self)
    self.fmt = vim.bo.fileformat
    return self.fmt ~= "unix"
  end,
  provider = function(self)
    return "[" .. self.fmt:upper() .. "]"
  end
}

return M
