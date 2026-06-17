local conditions = require "heirline.conditions"

local function count_bufs_modified()
  local count = 0
  for _, b in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value("modified", { buf = b }) then
      count = count + 1
    end
  end
  return count
end

--TODO: Currently we use the method where we recount all modified buffers on each update,
-- which is more than performant enough when we update only on the events specified below,
-- (takes like 0.02 secs on 7000 bufs, 0.001 secs on 100 bufs): it also recovers fromd desyncingheirline/buf
-- due to any weird edge cases we may not have covered, by design.
-- However it could be even more performant, which is the commented out impelementation below:
-- this just increments and decrements a counter meaning it is O(1) instead of O(n), though
-- if we miss an edge case it'll be constantly desynced. I implemented this first but then
-- found there is currently a bug with BufModifiedSet (listed below) so we use the O(n) method
-- for now; the O(1) method *seems* to work fine from my initial testing outside that bug, but
-- you never know if you missend an initial edge case
-- local num_modified_cache = 0
-- vim.api.nvim_create_autocmd("BufModifiedSet", {
--   group = augroup,
--   callback = function (event)
--     -- BufModifiedSet only triggers on an implicit *change* of the option,
--     -- not an assignment, so we can deduce whether num modified grew or shrunk
--     local botarget = vim.bo[event.buf]
--     num_modified_cache = num_modified_cache + (botarget.modified and 1 or -1)
--   end
-- })
-- vim.api.nvim_create_autocmd("OptionSet", {
--   pattern = "modified",
--   group = augroup,
--   callback = function (event)
--     local botarget = vim.bo[vim.api.nvim_get_current_buf()]
--     if vim.v.option_old ~= vim.v.option_new then
--       num_modified_cache = num_modified_cache + (vim.v.option_new and 1 or -1)
--     end
--   end
-- })
-- vim.api.nvim_create_autocmd("BufUnload", {
--   group = augroup,
--   callback = function (event)
--     local botarget = vim.bo[event.buf]
--     if botarget.modified then
--       num_modified_cache = num_modified_cache - 1
--     end
--   end
-- })
local num_modified_cache = 0
local augroup = vim.api.nvim_create_augroup("plugins.heirline", { clear = false })
vim.api.nvim_create_autocmd("BufModifiedSet", {
  group = augroup,
  callback = function ()
    num_modified_cache = count_bufs_modified()
  end
})
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "modified",
  group = augroup,
  callback = function ()
    num_modified_cache = count_bufs_modified()
  end
})
vim.api.nvim_create_autocmd("BufUnload", {
  group = augroup,
  callback = function (event)
    -- BufUnload runs right *before* the buffer is unloaded, so
    -- it is still counted if it was modified and we must subtract it
    num_modified_cache = count_bufs_modified()
    if vim.bo[event.buf].modified then
      num_modified_cache = num_modified_cache - 1
    end
  end
})

local BufsModifiedCurrentWindow =  {
  condition = function ()
    return conditions.is_active() and num_modified_cache > 0
  end,
  provider = function ()
    return table.concat {
      "[",
      (num_modified_cache > 1 or not vim.bo.modified) and num_modified_cache or "",
      vim.bo.modified and "+" or "",
      "]"
    }
  end,
  hl = function ()
    return { fg = vim.bo.modified and "modified_current" or "modified_noncurrent" }
  end
}

local BufsModifiedNonCurrentWindow =  {
  condition = function() return conditions.is_not_active() and vim.bo.modified end,
  provider = "[+]"
}

return {
  fallthrough = false,
  BufsModifiedCurrentWindow,
  BufsModifiedNonCurrentWindow
}

-- There's quite a few things that can happen that might affect the number of modified buffers.
-- I believe all the below events should cover it, but in the future it might be as simple as just
-- looking at the BufModifiedSet flag depending on how one of the below issues is addressed.
-- Buffer addition (i.e. cases where the number of modified buffers could only increment):
-- 1, BufAdd
--    The 'modified' option is set to false by default and as far as I can tell there is no way to
--    add a buffer where this value is set differently from the start, so we don't consider it.
--
-- Buffer changes:
-- 1. BufModifiedSet
--    The buffer's modified option is implictly changed when making a new change to a previosuly
--    unmodified buffer, and when writing or unloading in *some* cases. Unloading the buffer will
--    set the modified option to false but will not trigger BufModifiedSet.
-- 2. OptionSet 'modified'
--    The modified option is explictly changed. Note that this does not trigger BufModifiedSet.
-- Other observation:
--    In general the behaviour is a bit inconsistent between these events, but it seems that
--    BufModifiedSet triggers in scenarios where OptionSet won't, and vice versa.
--    I have raised an issue: https://github.com/neovim/neovim/issues/37317
--
-- Buffer deletion (i.e. cases where the number of modified buffers could only decrement),
-- note that all these events fire right before they actually do the deletion part:
-- 1. BufUnload (:bunload)
--    Deallocates memory for buffer/file content and loses any unsaved changes, setting modified to false.
--    However, other buffer-local options, variables and keympas are retained, and buffer metadata is retained.
--    Buffer stays ont the bufferlist.
-- 2. BufDelete (:bdelete)
--    Performs BufUnload if not already done, then also clears buffer-local options, variables and keymaps.
--    Removes buffer from bufferlist, however buffer metadata (like filename and id) is still retained.
-- 3. BufWipeOut (b:wipeout)
--    Performs BufWipeout and/or BufDelete if not already done, then completely clears the buffer from vim.
-- Other observation:
--    Setting the modified option on an unloaded buffer will work, but when the buffer gets loaded again it is reset.
--    This will interestingly also trigger the BufModifiedSet event.
-- Note that although there is a bunch that you may want to take account when it comes to buffer deletion, essentially
-- as long as we monitor BufUnload events we should be good when it comes to tracking modified state, as this will
-- trigger the earliest out of all events, an unloaded buffer cannot physically have unsaved changes, and a freshly
-- loaded buffer will always be in a non-modified state initially.
--  
-- NOTE: If you ever seem to get more buffers counted as modified then you'd expect, it
-- is likely because some plugin is creating an unlisted modified buffer, or
-- you have an open terminal buffer (currently this is bugged though and does not
-- show up as a modified buffer https://github.com/neovim/neovim/issues/37308).
-- However we should still consider the modified flags of unlisted buffers, because so does
-- nvim with commands like :q.
--
-- NOTE: Currently the BufModifiedSet event is bugged and doesn't trigger for
-- non-current buffers until the buffer is redrawn (e.g. when not the current
-- buffer it won't fire till switching back).
-- https://github.com/neovim/neovim/issues/32817
-- A fix is in the works. The only semi-common case in which this would be noticable
-- is when using :wa while the current buffer is unmodified but another is, as that
-- means the counter won't update till switching to that buffer.
--
-- NOTE: Currently the modified flag in terminal-buffers is bugged. They are supposed
-- to be set to true by default, but they are not. Despite this, some parts of neovim,
-- like vim.fn.getbufinfo, still treat them as such: https://github.com/neovim/neovim/issues/37308
