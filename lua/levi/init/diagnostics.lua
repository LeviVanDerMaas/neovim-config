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
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { dim = true })





local augroup = vim.api.nvim_create_augroup("core.diagnostics", { clear = false })

-- Get quickfix title and  winid. winid will be 0 if not open
-- local function tgetQfIds()
--   local ids = vim.fn.getqflist({ id = 0, winid = true })
--   return ids.id, ids.winid
-- end
--
-- -- Get loclist id and winid. winid will 0 if not open
-- -- `win` should be the window for which to check the corresponding loclist
-- local function tgetLocListIds(win)
--   local ids = vim.fn.getloclist(win, { id = 0, winid = true }).winid
--   return ids.id, ids.winid
-- end

-- Return whether the Diagnostics Quickfix list is open and its winid.
local function diagnosticsQfListOpen()
  -- qfl winid will be 0 if window is closed, title is most recent even when closed
  local qfl = vim.fn.getqflist({ winid = true, title = true })
  return qfl.winid ~= 0 and qfl.title == "Diagnostics", qfl.winid
end

-- Return whether a Diagnostics Loclist is open and its winid.
-- `win` should be the window for which to check the corresponding loclist
local function diagnosticsLocListOpen(win)
  -- lfl winid will be 0 if window is closed, title is most recent even when closed
  local lcl = vim.fn.getloclist(win, { winid = true, title = true })
  return lcl.winid ~= 0 and lcl.title == "Diagnostics", lcl.winid
end

-- Auto-update the "Diagnostics" quickfix list while the quickfix window is open
vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
  group = augroup,
  callback = function()
    if diagnosticsQfListOpen() then
      vim.diagnostic.setqflist({ title = "Diagnostics", open = false })
    end
  end
})
-- Auto-update open "Diagnostics" loclists for all windows holding a buffer that fired
-- "DiagnosticChangeD". when the window corresponding to the loclist. 
-- Note that splitting a window with an open loclists copies the loclist to the
-- new window, then the "ownership" of the loclist-window transfers to the new
-- window resulting from the split.
vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
  group = augroup,
  callback = function(ev)
    local winsWithBuf = vim.fn.win_findbuf(ev.buf)
    for _, winid in ipairs(winsWithBuf) do
      if diagnosticsLocListOpen(winid) then
        vim.diagnostic.setloclist({ winnr = winid, title = "Diagnostics", open = false })
      end
    end
  end
})

-- Diagnostic quickfix window binds
local function toggleLocListDiagnostics()
  local open, lclwinid = diagnosticsLocListOpen(vim.fn.win_getid())
  if open then
    vim.api.nvim_win_close(lclwinid, false)
  elseif #vim.diagnostic.get(vim.api.nvim_get_current_buf()) > 0 then
    vim.diagnostic.setloclist({ title = "Diagnostics", open = true })
  else
    vim.notify("0 diagnostics for this buffer.")
  end
end
local function toggleLQfListDiagnostics()
  local open, qfwinid = diagnosticsQfListOpen()
  if open then
    vim.api.nvim_win_close(qfwinid, false)
  elseif #vim.diagnostic.get() > 0 then
    vim.diagnostic.setqflist({ title = "Diagnostics", open = true })
  else
    vim.notify("0 diagnostics for this workspace.")
  end
end
vim.keymap.set("n", "<C-q>", toggleLocListDiagnostics, { desc = "Open buffer diagnostic [q]uickfix window" })
vim.keymap.set("n", "<M-q>", toggleLQfListDiagnostics, { desc = "Open workspace diagnostic [q]uickfix window" })
