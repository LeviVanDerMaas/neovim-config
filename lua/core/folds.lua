local unfold_all = 0x7FFFFFFF
local defaultFoldLevelForMethod = {
  marker = 0,
  manual = 0,
  diff = 0,
  indent = 3,
  expr = unfold_all,
  syntax = unfold_all,
}

-- Default the foldlevel to maximum instead of minimum:
-- If something goes wrong I still prefer all folds be open by default.
vim.wo.foldlevel = unfold_all

local augroup = vim.api.nvim_create_augroup("core.folds", { clear = false })
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "The first time a buffer is displayed, set its `foldlevel` based on its `foldmethod`.",
  -- Why use BufWinEnter instead of OptionSet for this? Because OptionSet is bugged and won't
  -- trigger during filetype detection (e.g. whens et during FileType event), which is one of
  -- the main moments where a value like this would be set dynamically: https://github.com/neovim/neovim/issues/33781
  group = augroup,
  callback = function()
    if vim.b.been_displayed then
      return
    end
    vim.b.been_displayed = true
    -- Yes this will override foldlevel once if that was set via the modeline. Don't care.
    vim.wo[0][0].foldlevel = defaultFoldLevelForMethod[vim.wo[0][0].foldmethod]
  end
})
