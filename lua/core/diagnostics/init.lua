local SEV = vim.diagnostic.severity

local hl_map = {
  [SEV.ERROR] = 'DiagnosticSignError',
  [SEV.WARN] = 'DiagnosticSignWarn',
  [SEV.INFO] = 'DiagnosticSignInfo',
  [SEV.HINT] = 'DiagnosticSignHint'
}
local icon_map = {
  [SEV.ERROR] = "",
  [SEV.WARN] = "",
  [SEV.INFO] = "",
  [SEV.HINT] = "󰌶"
}

vim.diagnostic.config({
  signs = {
    text = icon_map
  },
  severity_sort = true,

  status = {
    format = function(counts)
      local signs_config = vim.diagnostic.config().signs
      local signs = type(signs_config) == 'table' and signs_config.text or icon_map
      return vim.iter(pairs(counts))
        :map(function(severity, count)
          return ('%%#%s#%s %s'):format(hl_map[severity], signs[severity], count)
        end)
        :join(' ')
    end
  }
})

vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { dim = true })





require "core.diagnostics.quickfix"
