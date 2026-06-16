-- No need to call setup when using defaults. However, all treesitter features
-- are disabled by default and must be manually enabled for each buffer. We
-- just use a generic autocmd to make this work for all buffers. To check
-- if a parser is actually available on the rtp, you can use
-- vim.treesitter.language.add.
vim.api.nvim_create_autocmd("FileType", {
  callback = function (args)
    local lang = vim.treesitter.language.get_lang(args.match) or args.match
    if vim.treesitter.language.add(lang) then
      -- Enable treesitter-based highlighting
      vim.treesitter.start()

      -- Enable treesitter-based indentening
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

      --Enable treesitter-based folding
      -- vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      -- vim.wo[0][0].foldmethod = 'expr'
    end
  end
})

