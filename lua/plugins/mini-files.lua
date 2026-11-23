local MF = require "mini.files"

MF.setup {
  windows = {
    width_focus = 30,
    width_no_focus = 15,
    width_preview = 80
  },

  mappings = {
    go_in = "l",
    go_in_plus = "<CR>",
    go_out = "h",
    go_out_plus = ""
  },
}

local augroup = vim.api.nvim_create_augroup("plugins.mini-files", { clear = false })

-- MAP: SHIFT-HJKL to ordinary hjkl
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf = args.data.buf_id
    vim.keymap.set("n", "H", "h", { buffer = buf })
    vim.keymap.set("n", "J", "j", { buffer = buf })
    vim.keymap.set("n", "K", "k", { buffer = buf })
    vim.keymap.set("n", "L", "l", { buffer = buf })
  end
})

-- TOGGLE OPEN/CLOSE
vim.keymap.set("n", "<Leader>e", function()
  if not MF.close() then
    local path = vim.api.nvim_buf_get_name(0)
    if vim.b.buftype ~= "" or vim.fn.filereadable(path) == 0 then
      path = vim.fn.getcwd()
    end
    MF.open(path)
    MF.reveal_cwd()
  end
end, { desc = "[E]xplore directory" })

-- OPEN AT CWD
vim.keymap.set("n", "<Leader>E", function()
  if not MF.close() then
    MF.open(vim.fn.getcwd(0), false)
  end
end, { desc = "[E]xplore cwd" })

-- TOGGLE SHOW HIDDEN FILES
local show_dotfiles = false
local filter_none = function() return true end
local filter_dots = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end
local function toggle_dotfiles()
  show_dotfiles = not show_dotfiles
  MiniFiles.refresh({ content = { filter = show_dotfiles and filter_dots or filter_none } })
end
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = args.data.buf_id })
  end
})
