return function (flavour)
  -- Shamelessly stole this from how catppuccin-nvim's integration looks for the set theme.
  flavour = flavour or require("catppuccin").flavour or vim.g.catppuccin_flavour or "mocha"

  local c = require("catppuccin.palettes").get_palette(flavour)
  return {
    mode_normal = c.blue,
    mode_visual = c.mauve,
    mode_select = c.pink,
    mode_insert = c.green,
    mode_replace = c.maroon,
    mode_command = c.peach,
    mode_terminal = c.sky,

    modified_current = c.red,
    modified_noncurrent = c.yellow,

    git_branch = c.lavender,
    --
    -- ruler = c.lavender,
    -- buffer_progress = c.lavender,
  }
end
