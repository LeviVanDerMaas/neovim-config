-- Open help buffer windows vertically to the right, if there is no more
-- than one window prior and there is enough horizontal screenspace.
-- Must fire every BufWinEnter rather than only when the buffer is first opened,
-- becuase :help will reuse older buffers but reapply its default layout settings.
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("ftplugin.help", { clear = false }),
  buffer = 0,
  callback = function()
    if vim.o.columns >= 200 then
      local win_count = 0
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- Filter out floating and artefact windows (like completion win)
        if vim.api.nvim_win_get_config(w).relative == "" then
          win_count = win_count + 1
        end
      end
      if win_count < 3 then
        vim.cmd.wincmd "L"
      end
    end
  end
})
