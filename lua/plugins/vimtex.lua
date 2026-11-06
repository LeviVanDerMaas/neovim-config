vim.g.vimtex_compiler_latexmk = {
  aux_dir = "aux",
  out_dir = "out",
}
vim.g.vimtex_format_enabled = 1

-- :h vimtex-view-okular. inverse search for okular is setup as explained there
vim.g.vimtex_view_general_viewer = "okular"
vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]

-- We want vimtex to handle highlighting for us instead
require("plugins.treesitter").lang_features.latex = { highlighting = false }

vim.api.nvim_create_autocmd("User", {
  desc = "Warn if Vimtex cannot find the compiler backend executable",
  pattern = "VimtexEventInitPost",
  callback = function()
    local compiler_method = vim.g.vimtex_compiler_method
    if type(compiler_method) == "function" then
      compiler_method = compiler_method()
    end

    if vim.fn.executable(compiler_method) == 0 then
      vim.schedule(function() vim.notify(
        "Vimtex: Compiler executable '" .. compiler_method .. "' cannot be found!",
        vim.log.levels.WARN
      ) end)
    end
  end
})
