require("lazydev").setup {
  library = { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  enabled = function(root_dir)
    return vim.g.lazydev_enabled
      -- Server may need to be restarted if it already exists prior to entering .nvim.lua,
      -- then again restarted after deleting that buffer to clear environment
      or (vim.fn.expand("%:t") == ".nvim.lua" and vim.g.lazydev_enabled ~= false)
  end
}
