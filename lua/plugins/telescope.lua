require("telescope").setup {}

-- Load the native fzf sorter, assumig it is installed
require("telescope").load_extension "fzf"


local km = vim.keymap
local tsb = require "telescope.builtin"

-- File pickers
km.set("n", "<Leader><Leader>", tsb.find_files, { desc = "Search files" })
km.set("n", "<Leader>f", tsb.find_files, { desc = "[F]in[d] files" })
km.set("n", "<Leader>gf", tsb.git_files, { desc = "[F]ind [g]it files" })
km.set("n", "<Leader>rg", tsb.live_grep, { desc = "Find by [r]ip[g]rep" })
km.set({"n", "v"}, "<Leader>rs", tsb.grep_string, { desc = "[R]ipgrep [s]tring/[s]election" })

-- Vim pickers
km.set("n", "<Leader>sr", tsb.resume, { desc = "[S]earch [r]esume" })
km.set("n", "<Leader>b", tsb.buffers, { desc = "List open [b]uffers" })
km.set("n", "<Leader>'", tsb.marks, { desc = "List [M]a[r]ks" })
km.set("n", '<Leader>"', tsb.registers, { desc = "List registers" })
km.set("n", "<Leader>jl", tsb.jumplist, { desc = "Show [J]ump[l]ist" })
km.set("n", "<Leader>/", tsb.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })
km.set("n", "<Leader>sh", tsb.search_history, { desc = "List [s]earch [h]istory" })
km.set("c", "<C-h>", tsb.command_history, { desc = "List [c]ommand [h]istory" })
km.set("c", "<M-h>", tsb.commands, { desc = "List [c]ommand [h]istory" })

-- Quickfix pickers
km.set("n", "<Leader>q", function() tsb.diagnostics { bufnr = 0 } end, { desc = "Open buffer diagnostic [q]uickfix list" })
km.set("n", "<Leader>Q", function() tsb.diagnostics { sort_by = "severity" } end, { desc = "Open workspace diagnostic [q]uickfix list" })
km.set("n", "<Leader>l", tsb.loclist, { desc = "Show [l]ocal list" })
km.set("n", "<Leader><C-q>", tsb.quickfix, { desc = "Show [q]uickfix list" })
km.set("n", "<Leader><M-q>", tsb.quickfixhistory, { desc = "Show [q]uickfix list history" })

-- Git pickers
km.set("n", "<Leader>gc", tsb.git_commits, { desc = "List [g]it [c]ommits" })
km.set("n", "<Leader>gb", tsb.git_bcommits, { desc = "List [g]it [b]uffer commits" })
km.set("v", "<Leader>gb", tsb.git_bcommits_range, { desc = "List range's git commits" })
km.set("n", "<Leader>gB", tsb.git_branches, { desc = "List [g]it [b]ranches" })
km.set("n", "<Leader>gs", tsb.git_status, { desc = "List [g]it [s]tatus" })
km.set("n", "<Leader>gS", tsb.git_stash, { desc = "List [g]it [s]tash" })
