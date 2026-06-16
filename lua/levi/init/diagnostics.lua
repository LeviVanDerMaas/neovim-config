vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌶"
    }
  },
  severity_sort = true
})

-- Will be 0 if not open
local function getQfWinId()
  return vim.fn.getqflist({ winid = true }).winid
end

-- `winid` should be the window for which to check the corresponding loclist
-- Will be 0 if not open
local function getLocListWinId(win)
  return vim.fn.getloclist(win, { winid = true }).winid
end

local augroup = vim.api.nvim_create_augroup("core.diagnostics", { clear = false })

-- Auto-update the "Diagnostics" quickfixlist while the quickfix window is open
vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
  group = augroup,
  callback = function()
    if getQfWinId() ~= 0 then
      vim.diagnostic.setqflist({ title = "Diagnostics", open = false })
    end
  end
})
-- Auto-update "Diagnostics" loclists when the window corresponding to the loclist
-- holds a buffer that fires "DiagnosticChanged". Note that splitting a window with
-- an open loclists copies the loclist to the new window, then the "ownership" of
-- the loclist-window transfers to the new window resulting from the split.
vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
  group = augroup,
  callback = function(ev)
    local winsWithBuf = vim.fn.win_findbuf(ev.buf)
    for _, winid in ipairs(winsWithBuf) do
      if getLocListWinId() ~= 0 then
        vim.diagnostic.setloclist({ winnr = winid, title = "Diagnostics", open = false })
      end
    end
  end
})


local function toggleLocListDiagnostics()
  local loclistId = getLocListWinId(vim.fn.win_getid())
  if loclistId ~= 0 then
    vim.api.nvim_win_close(loclistId, false)
  elseif #vim.diagnostic.get(vim.api.nvim_get_current_buf()) > 0 then
    vim.diagnostic.setloclist({ title = "Diagnostics", open = true })
  else
    vim.notify("0 diagnostics for this buffer.")
  end
end
local function toggleLQfListDiagnostics()
  local qfId = getQfWinId()
  if qfId ~= 0 then
    vim.api.nvim_win_close(qfId, false)
  elseif #vim.diagnostic.get() > 0 then
    vim.diagnostic.setqflist({ title = "Diagnostics", open = true })
  else
    vim.notify("0 diagnostics for this workspace.")
  end
end
vim.diagnostic.count()
vim.keymap.set("n", "<C-q>", toggleLocListDiagnostics, { desc = "Open buffer diagnostic [q]uickfix window" })
vim.keymap.set("n", "<M-q>", toggleLQfListDiagnostics, { desc = "Open workspace diagnostic [q]uickfix window" })
