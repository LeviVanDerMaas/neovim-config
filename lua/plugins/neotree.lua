local function nt_exec(args)
  require("neo-tree.command").execute(args)
end

vim.keymap.set("n", "<Leader>t", function() nt_exec {} end)
vim.keymap.set("n", "<Leader><M-t>", function() nt_exec { toggle = true } end)
vim.keymap.set("n", "<Leader>T", function() nt_exec { reveal = true } end)

require("neo-tree").setup {
  follow_current_file = true;
  close_if_last_window = true,
  popup_border_style = "rounded",
  -- These apply to all source types: use "soure_name" instead of "window" for type-specific settings
  window = {
    position = "right",
    insert_as = "sibling",
    mappings = {
      ---@diagnostic disable-next-line: assign-type-mismatch
      ["<Leader>t"] = { function() nt_exec { toggle = true } end, desc = "Close the window" },
      ["Z"] = "expand_all_nodes",
      ["."] = "toggle_hidden"
    }
  },
  buffers = {
    terminals_first = true
  },

  default_component_configs = {
    git_status = {
      symbols = {
        -- Change type
        added     = "",
        deleted   = "",
        modified  = "",
        renamed   = "",
        -- Status type
        untracked = "?",
        ignored   = "/",
        unstaged  = "!",
        staged    = "+",
        conflict  = "",
      },
    },
  },

  clipboard = {
    sync = "universal"
  },

  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "document_symbols",
  },

  source_selector = {
    winbar = false,
    statusline = false,
    truncation_character = "…",
    sources = {
      { source = "filesystem" },
      { source = "buffers" },
      { source = "git_status" },
      -- { source = "document_symbols" },
    },
  },
}
