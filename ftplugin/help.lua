-- Open help buffer windows vertically to the right, if there is no more
-- than one window prior and there is enough horizontal screenspace.
local function winToRightIfSpace()
  if vim.o.columns >= 200 then
    local count = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      -- Filter out floating and artefact windows (like completion win)
      if vim.api.nvim_win_get_config(w).relative == "" then
        count = count + 1
      end
    end
    -- Check for < 3 because the help window will already be included in the count
    if count < 3 then
      vim.cmd.wincmd "L"
    end
  end
end

winToRightIfSpace()
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("ftplugin.help", { clear = false }),
  buffer = vim.api.nvim_get_current_buf(),
  callback = winToRightIfSpace
})
