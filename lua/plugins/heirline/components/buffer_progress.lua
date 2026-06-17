local blocks = require "plugins.heirline.components.blocks"


return blocks.itemGroup({
  provider = "%P/%LL",
  hl = { fg = "buffer_progress" },
}, { minwid = 9 })
