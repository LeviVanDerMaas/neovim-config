local conditions = require "heirline.conditions"
local blocks = require "levi.heirline.components.blocks"

local function inInsertOrReplaceMode()
  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  return mode == "i" or mode == "R"
end

-- Schedule redraw because the statusline redraw when modifying buffer
-- contents tends to be faster than gitsigns updating the dict.
vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  group = vim.api.nvim_create_augroup("levi.heirline", { clear = false }),
  callback = function()
    -- Don't update state while in insert or replace mode because it is annoying
    if not inInsertOrReplaceMode() then
      vim.schedule(function() vim.cmd.redrawstatus() end)
    end
  end
})

-- Uses the GitSigns plugin to show the Git head and status when buffer is in a git repo.
return {
  condition = conditions.is_git_repo,
  init = function (self)
    -- Don't update state while in insert or replace mode because it is annoying
    if inInsertOrReplaceMode() then
      return
    end

    local status = vim.b.gitsigns_status_dict
    self.added = status.added or 0
    self.changed = status.changed or 0
    self.removed = status.removed or 0
    self.has_changes = self.added > 0 or self.changed > 0 or self.removed > 0
    self.min_diff_width = blocks.clamp_width_percent_to_columns(0.05)
  end,

  { provider = " " },
  { provider = function() return vim.b.gitsigns_head end },
  {
    blocks.itemGroup(
      {
        condition = function(self) 
          return self.has_changes and self.min_diff_width > 5
        end,
        { provider = "(" },
        blocks.separate(
          {
            {
              condition = function(self) return self.added > 0 end,
              provider = function(self) return "+" .. self.added end,
            },
            {
              condition = function(self) return self.removed > 0 end,
              provider = function(self) return "-" .. self.removed end,
            },
            {
              condition = function(self) return self.changed > 0 end,
              provider = function(self) return "~" .. self.changed end,
            },
          },
          { separator = { provider = "," } }
        ),
        { provider = ")" },
      },
      { ljustify = true, minwid = function(self) return self.min_diff_width end }
    )
  },

  hl = function(self)
    if conditions.is_active() then
      return { fg = "git_branch" }
    end
    return { fg = "NONE", force = true }
  end
}
