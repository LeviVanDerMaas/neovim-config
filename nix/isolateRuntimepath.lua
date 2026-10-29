local stdpath = vim.fn.stdpath
local function siteDir(dir)
  return dir .. "/site"
end
local function afterDir(dir)
  return dir .. "/after"
end

local rtp_user_dirs = {
  { stdpath("config") },
  stdpath("config_dirs"),
  { siteDir(stdpath("data")) },
  vim.tbl_map(siteDir, stdpath("data_dirs")),
}

for _, dirs in ipairs(rtp_user_dirs) do
  vim.opt.runtimepath:remove(dirs)
  vim.opt.runtimepath:remove(vim.tbl_map(afterDir, dirs))
end
