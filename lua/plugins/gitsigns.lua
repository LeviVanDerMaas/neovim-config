-- Gitsigins already does this check by itself but will print
-- error messages that you can't disable when it fails.
if vim.fn.executable('git') == 0 then
  return
end

require("gitsigns").setup {
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" }  ,
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signs_staged = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  max_file_length = 40000 -- Plugin disables if linecount exceeds this
}
