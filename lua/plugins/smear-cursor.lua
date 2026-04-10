require("smear_cursor").setup {
  stiffness = 1,
  trailing_stifness = 0.99,
  distance_stop_animating = 0.5,
  never_draw_over_target = true,

  -- Both of these must be set, otherwise neither won't take effect properly. Also,
  -- a diagonal smear is still triggered if only one of these gets exceded.
  min_vertical_distance_smear = 10,
  min_horizontal_distance_smear = 10,


  smear_horizontally = false,
  scroll_buffer_space = false,
  -- This is true by default and for some reason supersedes more granualar settings, so
  -- if this is true it'll often cause unexpected behaviour.
  smear_between_neighbor_lines = false,



  smear_to_cmd = false,
  smear_between_buffers = true, -- Also controls window smear, including floating.
}

