local km = vim.keymap

-- BLACKHOLE REGISTER ACCESS WITH ALT
km.set("v", "<M-p>", '"_p') -- Synonym for v_P
km.set("", "<M-d>", '"_d')
km.set("", "<M-x>", '"_x')
km.set("", "<M-c>", '"_c')
km.set("", "<M-s>", '"_s')





-- MULTI-PARAGRAPH INTRA-JOIN, e.g. alternative to `:h J` that is per paragraph
-- "gw" essentially does this if textwidth is at least as wide the widest line, so we exploit that
local function feedKeysWithMaxTW(keys)
  local tw = vim.bo.textwidth
  vim.bo.textwidth = 0x7fffffff
  vim.fn.feedkeys(keys, "nx")
  vim.bo.textwidth = tw
end
km.set("n", "<M-j>", function() feedKeysWithMaxTW(vim.v.count1 .. "gwap") end)
km.set("v", "<M-j>", function() feedKeysWithMaxTW("gw") end)





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





-- TEXT OBJECTS:
km.set({"v", "o"}, "aa",
  function()
    vim.cmd [[
      exec "normal! \e\e"
      normal! gg0vG$
    ]]
  end,
  { silent = true, desc = "[a]ll" }
)

km.set({"v", "o"}, "ia",
  function ()
    vim.cmd [[
      exec "normal! \e\e"
      normal! gg0
      call search('\S', 'c')
      normal! 0vG$
      call search('\S', 'bc')
    ]]
  end,
  { silent = true, desc = "[a]ll, trim blank lines" }
)
