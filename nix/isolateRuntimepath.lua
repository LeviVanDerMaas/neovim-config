-- If you are to believe :h 'rtp', it would be suffcient to isolate the default runtimepath
-- by just setting it to $VIMRUNTIME. However, the default value value for runtimepath
-- sets more than just the value for $VIMRUNTIME, such as local <binpath>/../lib/nvim.
-- You can see in upstream src/nvim/runtime.c
-- So instead, manually remove all user dirs from the runtimepath.
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
