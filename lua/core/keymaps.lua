-- vim: set foldmethod=marker:
local km = vim.keymap

-- Set these very early as keymaps expand <leader> upon definition
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--{{{ MAP: <Up> and <Down> to gk and gj
-- Mainly useful when 'wrap' is set
km.set({"", "i"}, "<Down>", "<Cmd>norm! gj<CR>")
km.set({"", "i"}, "<Up>",   "<Cmd>norm! gk<CR>")
--}}}

--{{{ MAP: <Home> and <End> to _ and g_, <Shift> for original behaviour.
km.set({"", "i"}, "<Home>", "<Cmd>norm! _<CR>")
km.set({"", "i"}, "<End>",  "<Cmd>norm! g_<CR>")
km.set({"", "i"}, "<S-Home>", "<Home>")
km.set({"", "i"}, "<S-End>", "<End>")
--}}}

--{{{ MAP: ALT+operator as shortcut to blackhole register
km.set("v", "<M-p>", '"_p') -- Synonym for v_P
km.set("", "<M-d>", '"_d')
km.set("", "<M-x>", '"_x')
km.set("", "<M-c>", '"_c')
km.set("", "<M-s>", '"_s')
-- Also allows ALT to be held for both presses of a double operator for blackhole
km.set("", "<M-d><M-d>", '"_dd')
km.set("", "<M-x><M-x>", '"_xx')
km.set("", "<M-c><M-c>", '"_cc')
km.set("", "<M-s><M-s>", '"_ss')
--}}}

--{{{ MAP: make cc use blackhole if no non-blank chars are affected
-- Mainly useful to make use of "cc's" autoindent behaviour.
km.set("n", "cc", function()
  local lnum = vim.fn.line(".")
  local lines = vim.fn.getline(lnum, lnum + (vim.v.count1 - 1))
  return vim.fn.match(lines, [[\S]]) == -1 and '"_cc' or 'cc'
end, { expr = true })
--}}}

--{{{ MAP: ALT+j mimics J but keeps individual paragraphs separated
-- "gw" essentially does this if textwidth is at least as wide as the widest line
local function mapRHSwithMaxTextwidth(keys)
  local tw = vim.bo.textwidth
  return table.concat {
    "<Cmd>setl textwidth=0x7fffffff<CR>",
    keys,
    "<Cmd>setl textwidth=", tw, "<CR>"
  }
end

km.set("n", "<M-j>", function()
  return mapRHSwithMaxTextwidth(vim.v.count1 .. "gwap")
end, { expr = true, desc = "Intra-join paragraphs" })

km.set("v", "<M-j>", function()
  return mapRHSwithMaxTextwidth("gw")
end, { expr = true, desc = "Intra-join paragraphs" })
--}}}

--{{{ MAP: <leader>+h/H for search highlight shortcuts.
km.set("", "<leader>h", function ()
  if vim.v.hlsearch == 0 then
  -- Setting this also sets v:hlsearch to 1.
    vim.o.hlsearch = true
  else
    -- Disable highlights but not "hlsearch" option
    vim.v.hlsearch = 0
  end
end, { silent = true; desc = "Toggle search highlights" })

km.set("", "<leader>H", function ()
  vim.o.hlsearch = not vim.o.hlsearch
  local hl_str = (vim.o.hlsearch and "Enabled") or "Disabled"
  vim.notify(string.format('%s search highlighting ("hlsearch")', hl_str))
end, { desc = 'Toggle "hlsearch" option' })
--}}}

--{{{ TEXT OBJECT: all text in buffer (inner trims blank lines but preserves indent)
km.set({"v", "o"}, "aa", function()
  vim.cmd [[
    exec "normal! \e\e"
    keepjumps normal! gg0vG$
  ]]
end, { silent = true, desc = "[a]ll" })

km.set({"v", "o"}, "ia", function ()
  vim.cmd [[
    exec "normal! \e\e"
    keepjumps normal! gg0
    call search('\S', 'c')
    keepjumps normal! 0vG$
    call search('\S', 'bc')
  ]]
end, { silent = true, desc = "[a]ll, trim blank lines" })
--}}}

--{{{ OPERATOR: gl to trim all blank characters at end of line
function TrimOverLastMotion()
  local curcol = vim.fn.virtcol(".", true)[1]
  local motion_start = vim.api.nvim_buf_get_mark(0, "[")[1]
  local motion_end = vim.api.nvim_buf_get_mark(0, "]")[1]
  -- Handles edge case of same line motions on empty line
  if motion_start > motion_end then
    vim.api.nvim_buf_set_mark(0, "]", motion_start, 0, {})
  end

  -- This does the actual trimming on the motion's area.
  -- Prefer using \+ over * atom here. Eventhough the effect of the substituion
  -- is the same, with \+  this only matches on lines where there actually are
  -- blank characters at the end, whereas with * this matches all lines. As a
  -- result, the latter will cause the buffer's modified flag to be set and
  -- this command to be added to the undo stack even if no actual changes are
  -- made; the former does not have this issue.
  vim.cmd [[silent keeppatterns '[,']s/\s\+$//ge]]

  -- Move to the line where the motion started and according to 'startofline'
  -- set the cursor's column. This mimics the behaviour of other operators,
  -- whereas the substitution would move you only to the first non-blank of
  -- the last line where the substitution pattern matched.
  -- NOTE: In visual line-wise mode this behaves inconsistently depending on what end
  -- the cursor is in visual mode, but this *is* consistent with several other operators.
  vim.api.nvim_win_set_cursor(0, { motion_start, 0 })
  vim.cmd ("norm! " .. (vim.o.startofline and "^" or (curcol .. "|")))
end

km.set({"n", "x"}, "gl", function ()
  vim.o.operatorfunc = "v:lua.TrimOverLastMotion"
  return "g@"
end, { expr = true, silent = true, desc = "Trim" })
--}}}
