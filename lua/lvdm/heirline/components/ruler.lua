local colors = require "lvdm.heirline.colors"
return {
  provider = "%4l,%-4c",
  hl = function () return { fg = "ruler", bold = true } end
}
