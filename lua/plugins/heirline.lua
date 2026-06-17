local conditions = require "heirline.conditions"

local blocks = require "plugins.heirline.components.blocks"
local Mode = require "plugins.heirline.components.mode"
local BufsModified = require "plugins.heirline.components.bufs_modified"
local Ruler = require "plugins.heirline.components.ruler"
local BufferProgress = require "plugins.heirline.components.buffer_progress"
local Diagnostics = require "plugins.heirline.components.diagnostics"
local GitSigns = require "plugins.heirline.components.gitsigns"
local fileFlags = require "plugins.heirline.components.fileflags"
local fileNames = require "plugins.heirline.components.filenames"


local ModeIndicator = {
  blocks.Space,
  blocks.itemGroup(Mode, { minwid = 8, ljustify = true }),
  blocks.Space,
}

local BufTypeIndicator = blocks.separate({ fileFlags.Buftype, fileFlags.Preview }, { trailing = true } )

local BufferWorkspace = {
  blocks.suffix(Diagnostics, blocks.spaces(4)),
  blocks.suffix(GitSigns, blocks.spaces(2)),
}

local Location = {
  Ruler, blocks.Space, BufferProgress, blocks.Space
}




local BufferInfoNormal = {
  -- Group like this so that modification indicators don't easily shift
  blocks.itemGroup(blocks.separate({ BufsModified, fileFlags.Modifiable }), { minwid = 4 }),
  blocks.Space,
  BufTypeIndicator,

  -- File-specific info
  blocks.truncPos,
  blocks.separate({ fileNames.Relative, fileFlags.Encoding, fileFlags.Format }),
}

local BufferInfoSpecial = {
  blocks.itemGroup(BufsModified, { minwid = 4 }),
  blocks.Space,
  BufTypeIndicator,

  -- File-specific info
  blocks.truncPos,
  fileNames.Special
}





local StatusLineNormal = {
  ModeIndicator,
  BufferInfoNormal,
  blocks.Aligner,
  blocks.Space, -- For when trunctuating
  BufferWorkspace,
  Location
}

local SpecialBufTypes = {
  help = true,
  quickfix = true,
  terminal = true,
  prompt = true
}
local StatusLineSpecial = {
  condition = function () return SpecialBufTypes[vim.bo.buftype] end,
  ModeIndicator,
  BufferInfoSpecial,
  blocks.Aligner,
  blocks.Space, -- For when trunctuating
  Location
}

local ConditionalStatusLine = {
  fallthrough = false,
  StatusLineSpecial,
  StatusLineNormal,
}

require("heirline").setup {
  opts = {},
  statusline =  ConditionalStatusLine,
  colors = require "plugins.heirline.colors",
}

-- NOTE: There is only one heirline instance that is shared by multiple statuslines: all vim statuslines
-- call the same eval function and that eval function does not seperate different statuslines. This means
-- that if you use any buffer-local values in your statusline provider, they will carry over to other
-- buffers until the statusline is updated again (in other words be careful with a component's 'update'
-- property when the provider uses buffer-local values).
-- NOTE: Heirline values are "inherited" downwards, but writing does not go back up to the parent.
-- NOTE: If update is set, a cache will be checked: if that cache is not nil, then the cache is used;
-- otherwise the rest of the component is evaluated.
--   # If update is a function, cache will be set to nil when function returns true
--   # If update is autocmds, these autocmds will set the cache to nil when triggered
--   # If update is nil, no cache checking is done and full component is evaluated.
-- Once done updating all statusline components, all components with update not nil will have cache set.
-- NOTE: Heirline won't trigger a statusline redraw by itself (unless you explictly program a component
-- to do so), e.g. if you're in COMMAND mode component updates won't actually be visible on the statusline
-- until you leave COMMAND mode or explictly call :redrawstatus.
-- Checking the source code of heirline, update works as follows:
-- NOTE: If you get any erros from statusline on leaving use this:
--    :au VimLeavePre * set stl=
