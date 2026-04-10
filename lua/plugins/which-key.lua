require("which-key").setup {
  triggers = {
    -- Visual mode is also baked in but tends to breaks some (or with)
    -- other plugins, plus we seldom use it in this mode anyway
    { "<auto>", mode = "no" },
  },
}
