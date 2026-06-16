local colors = require "levi.heirline.colors"
return {
  provider = "%4l,%-4c",
  hl = function () return { fg = "ruler", bold = true } end
}
