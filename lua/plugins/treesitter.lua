local M = {
  -- A table of filetypes, where each key-value pair describes what treesitter
  -- features to use for that filetype. If a table is assigned to a filetype,
  -- reads boolean keys `highlighting`, `indentation` and `folding` to configure
  -- usage individually. Otherwise, treated as a bool that enables all features or none.
  -- Except where intenrally set by this module, all features for all languages default to true.
  -- NOTE: these area read during filetype detection and will not apply if set afterward.
  ft_features = {
    markdown = { indentation = false }
  }
}

vim.api.nvim_create_autocmd("FileType", {
  nested = true, -- Must be nested to be able to trigger any OptionSet autocmds
  callback = function (args)
    local lang = vim.treesitter.language.get_lang(args.match) or args.match
    local config = M.ft_features[args.match] or {}
    if vim.treesitter.language.add(lang) then
      -- Enable treesitter-based highlighting
      if config.highlighting ~= false then
        vim.treesitter.start()
      end

      -- Enable treesitter-based indentening
      if config.indentation ~= false then
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      --Enable treesitter-based folding
      if config.folding ~= false then
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
      end
    end
  end
})


return M
