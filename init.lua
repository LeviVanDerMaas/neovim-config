vim.loader.enable() -- Enable inter-session caching of all `require`s, including plugin/ and ftplugin/

-- In init.lua only run config which does not depend on external plugins or programs
require "levi.init.options"
require "levi.init.keymaps"
require "levi.init.diagnostics"
