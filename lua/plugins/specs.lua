local textoff_cache = 0
local function textoff_shrink_resizer(width, ccol, cnt)
  if width - cnt <= 0 then
    return nil
  end

  if cnt == 0 then
    textoff_cache = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
  end

  local len = width - cnt
  -- if len % 2 == 0 then len = len + 1 end
  local base = math.floor(ccol - (len / 2) + 1)
  local trim = textoff_cache - base
  if trim > 0 then
    len = len - trim
    base = textoff_cache
  end

  return {len, base}
end

vim.keymap.set("n", "<Leader>c", function()
  require("specs").show_specs { blend = 60, width = 22, inc_ms = 5 }
end, { desc = "Show [c]ursor"})
vim.keymap.set("n", "<Leader>C", require("specs").toggle, { desc = "Toggle Specs"})

require("specs").setup {
  min_jump = 30,
  popup = {
    delay_ms = 0,
    width = 11, -- Can affect duration if the resizer bases calculations on inital width
    inc_ms = 10, -- Effectively controls speed; time between each change in the effect
    blend = 20,
    winhl = "IncSearch",
    resizer = textoff_shrink_resizer,
    fader = require("specs").empty_fader
  },

  ignore_buftypes = {
    nofile = true,
    prompt = true,
    terminal = true,
  },
  ignore_filetypes = {}
}
