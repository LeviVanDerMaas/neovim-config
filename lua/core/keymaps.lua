local km = vim.keymap

-- UP-DOWN KEYS TO NON-LINEWISE DIRECTIONALS
-- Mainly useful when 'wrap' is set
km.set("", "<Down>",  "gj")
km.set("", "<Up>",    "gk")
km.set("i", "<Down>", "<Cmd>norm! gj<CR>")
km.set("i", "<Up>",   "<Cmd>norm! gk<CR>")

-- BLACKHOLE REGISTER ACCESS WITH ALT
km.set("v", "<M-p>", '"_p') -- Synonym for v_P
km.set("", "<M-d>", '"_d')
km.set("", "<M-x>", '"_x')
km.set("", "<M-c>", '"_c')
km.set("", "<M-s>", '"_s')

-- OVERRIDE cc TO USE BLACKHOLE IF NO NON-BLANK CHARS ARE AFFECTED
-- Mainly useful to make use of "cc's" autoindent behaviour.
km.set("n", "cc", function()
  local lnum = vim.fn.line(".")
  local lines = vim.fn.getline(lnum, lnum + (vim.v.count1 - 1))
  return vim.fn.match(lines, [[\S]]) == -1 and '"_cc' or 'cc'
end, { expr = true })





-- MULTI-PARAGRAPH INTRA-JOIN, e.g. alternative to `:h J` that is per paragraph
-- "gw" essentially does this if textwidth is at least as wide the widest line, so we exploit that
local function mapRHSwithMaxTextwidth(keys)
  local tw = vim.bo.textwidth
  return table.concat {
    "<Cmd>setl textwidth=0x7fffffff<CR>",
    keys,
    "<Cmd>setl textwidth=", tw, "<CR>"
  }
end
km.set("n", "<M-j>",
  function() return mapRHSwithMaxTextwidth(vim.v.count1 .. "gwap") end,
  { expr = true, desc = "Intra-join paragraphs" }
)
km.set("v", "<M-j>",
  function() return mapRHSwithMaxTextwidth("gw") end,
  { expr = true, desc = "Intra-join paragraphs" }
)


-- SEARCH HIGHLIGHTS
km.set("", "<leader>h",
  function ()
    if vim.v.hlsearch == 0 then
    -- Setting this also sets v:hlsearch to 1.
      vim.o.hlsearch = true
    else
      -- Disable highlights but not "hlsearch" option
      vim.v.hlsearch = 0
    end
  end,
  { silent = true; desc = "Toggle search highlights" }
)

km.set("", "<leader>H",
  function ()
    vim.o.hlsearch = not vim.o.hlsearch
    local hl_str = (vim.o.hlsearch and "Enabled") or "Disabled"
    vim.notify(string.format('%s search highlighting ("hlsearch")', hl_str))
  end,
  { desc = 'Toggle "hlsearch" option' }
)





-- TEXT OBJECT:  All text in buffer
km.set({"v", "o"}, "aa",
  function()
    vim.cmd [[
      exec "normal! \e\e"
      keepjumps normal! gg0vG$
    ]]
  end,
  { silent = true, desc = "[a]ll" }
)
km.set({"v", "o"}, "ia",
  function ()
    vim.cmd [[
      exec "normal! \e\e"
      keepjumps normal! gg0
      call search('\S', 'c')
      keepjumps normal! 0vG$
      call search('\S', 'bc')
    ]]
  end,
  { silent = true, desc = "[a]ll, trim blank lines" }
)





-- OPERATOR: Remove all blank characters at end of line
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
km.set({"n", "x"}, "gl",
  function ()
    vim.o.operatorfunc = "v:lua.TrimOverLastMotion"
    return "g@"
  end,
  { expr = true, silent = true, desc = "Trim" }
)
