local conditions = require "heirline.conditions"
local blocks = require "levi.heirline.components.blocks"
local severity = vim.diagnostic.severity

return {
  update = {
    "DiagnosticChanged", "WinEnter", "InsertLeave",
    -- Schedule redraw because diagnostic updates are usally slower than
    -- vim redrawing the statusline whenever the buffer contents are changed
    callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end)
  },
  condition = conditions.has_diagnostics,
  static = {
    error_count = 0,
    warn_count = 0,
    info_count = 0,
    hint_count = 0,
  },
  init = function(self)
    local diag_conf = vim.diagnostic.config() --[[@as table]]

    -- Don't update state while in insert mode when this is disabled for diagnostics.
    -- We do update in Replace mode to stay consistent with update_in_insert behaviour
    if not diag_conf.update_in_insert and vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
      return
    end

    local diag_counts = vim.diagnostic.count(0)
    self.error_count = diag_counts[severity.ERROR] or 0
    self.warn_count = diag_counts[severity.WARN] or 0
    self.info_count = diag_counts[severity.INFO] or 0
    self.hint_count = diag_counts[severity.HINT] or 0

    local diag_tsigns = diag_conf["signs"]["text"]
    self.error_icon = diag_tsigns[severity.ERROR]
    self.warn_icon = diag_tsigns[severity.WARN]
    self.info_icon = diag_tsigns[severity.INFO]
    self.hint_icon = diag_tsigns[severity.HINT]
  end,

  blocks.separate({
    {
      condition = function(self) return self.error_count > 0 end,
      provider = function(self)
        return self.error_icon .. " " .. self.error_count
      end,
      hl = { fg = "diag_error" }
    },
    {
      condition = function(self) return self.warn_count > 0 end,
      provider = function(self)
        return self.warn_icon .. " " .. self.warn_count
      end,
      hl = { fg = "diag_warn" }
    },
    {
      condition = function(self) return self.info_count > 0 end,
      provider = function(self)
        return self.info_icon .. " " .. self.info_count
      end,
      hl = { fg = "diag_info" }
    },
    {
      condition = function(self) return self.hint_count > 0 end,
      provider = function(self)
        return self.hint_icon .. " " .. self.hint_count
      end,
      hl = { fg = "diag_hint" }
    }
  }),
  hl = function(self)
    if conditions.is_not_active() then
      return { fg = "NONE", force = true }
    end
  end
}
