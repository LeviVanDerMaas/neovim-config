-- Enable inter-session caching of all lua modules loaded after this point.
-- This includes any other auto-loaded files on the runtimepath, such as
-- `plugin` and `ftplugin` (since init.lua runs before those)
vim.loader.enable()

-- Set these very early as keymaps expand <leader> upon definition
vim.g.mapleader = " "
vim.g.maplocalleader = " "
