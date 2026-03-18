require("blink.cmp").setup {
  sources = {
    -- Default sources to enable, can be a function for dynamics.
    default = {
      -- Builtin completion sources.
      "lazydev", "lsp", "snippets", "buffer", "path",
    },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100 -- Makes lazydev completions higher prio
      }
    }
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
    sorts = {
      -- Currently there is no prefix matching but it is being worked on
      "exact", -- This is only for "foo" matching "foo", not "foo" matching "foobar"
      "score",
      "sort_text"
    }
  },

  keymap = {
    preset = "default",

    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
  },

  cmdline = {
    keymap = { preset = 'inherit' },
    completion = {
      menu = {
        -- Only do auto_show for normal commands
        auto_show = function() return vim.fn.getcmdtype() == ':' end,
      },
    }
  }
}
