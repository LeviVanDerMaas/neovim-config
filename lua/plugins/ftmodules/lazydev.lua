-- For use with lua filetypes
require("lazydev").setup {
  library = { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  enabled = function(root_dir)
    return vim.g.lazydev_enabled
  end
}
