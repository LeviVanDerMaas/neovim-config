local UNFOLD_ALL = 0x7FFFFFFF
local defaultFoldLevelForMethod = {
  marker = 0,
  manual = 0,
  diff = 0,
  indent = 3,
  expr = UNFOLD_ALL,
  syntax = UNFOLD_ALL,
}
local function setFoldOptionsForMethod(wo, method)
  method = method or wo.foldmethod
  wo.foldlevel = defaultFoldLevelForMethod[method]
  wo.foldtext = (method == "expr" or method == "syntax") and "" or "foldtext()"
end

-- Set window-local defaults (which any new windows by default copy from the previous window)
setFoldOptionsForMethod(vim.o)

local augroup = vim.api.nvim_create_augroup("core.folds", { clear = false })
vim.api.nvim_create_autocmd("OptionSet", {
  -- NOTE: OptionSet will not catch options set during certain autocmd events
  -- unless that autocmd allows nesting
  desc = "When 'foldmethod' is changed, locally set other fold options depending on the method",
  group = augroup,
  pattern = "foldmethod",
  callback = function()
    local old_method = vim.v.option_oldlocal
    local new_method = vim.v.option_new
    if old_method ~= "" and new_method ~= old_method then
      setFoldOptionsForMethod(vim.wo[0][0])
    end
  end
})
-- OptionSet does not trigger during startup, so if the foldmethod was changed during
-- startup (e.g. autocmd or modeline) this ensures fold options are still initialized properly
-- NOTE: Currently, this does not run on buffers not in a window. This is because currently,
--       there is no way to set buffer-local window-local options if that buffer is not in a window.
-- Issue tracker: https://github.com/vim/vim/issues/11724
-- Explanation on why this limitation: https://github.com/vim/vim/issues/21089
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "For each buffer in a window, initialize its local fold options based on its local 'foldmethod' after setup",
  group = augroup,
  callback = function()
    -- Only iterating over current active windows is necessary, because buffer-local window options
    -- cannot be set unless that buffer is actually displayed in the window.
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      setFoldOptionsForMethod(vim.wo[win][0])
    end
  end
})

-- Rework the foldlevel binds to ensure folds always stay open when editing fully (level-wise)
-- unfolded buffers. Otherwise, if you do the built-in zR, then add text to the buffer that
-- creates/changes folds to have a higher fold level than what zR previously found, those folds
-- will close. This is mainly relevant when using one of the foldmethods expr, syntax or indent.
-- Makes sure folds always stay open when editing fully (level-wise) unfolded buffers.
-- NOTE: zr, zR, zm, and zM also set the buffer-local 'foldlevel'.
vim.keymap.set({"n", "v"}, "zR", function() vim.wo[0][0].foldlevel = UNFOLD_ALL end)
vim.keymap.set({"n", "v"}, "zm", function()
  if vim.wo[0][0].foldlevel == UNFOLD_ALL then
    -- zR first sets 'foldlevel' to the actual deepest level of nested folds.
    vim.cmd [[ normal! zRzm ]]
  else
    vim.cmd [[ normal! zm ]]
  end
end)
