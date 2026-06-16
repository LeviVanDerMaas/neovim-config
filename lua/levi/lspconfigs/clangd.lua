vim.lsp.config("clangd", {
  on_attach = function ()
    -- "Dim out" inactive preprocessor branches while preserving their syntax
    -- highlighting. Default settings would grey them out like comments instead.
    -- This is because, for Neovim, Clangd uses the "comment" LSP
    -- token to signal such inactive branches (and does not use it otherwise).
    -- https://clangd.llvm.org/features#kinds
    vim.api.nvim_set_hl(0, "@lsp.type.comment.cpp", { dim = true })
  end
})
