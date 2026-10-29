-- Run this file in Neovim to mimic loading the user's vimrc. :h vimrc

local function runVimRcAt(dir)
  local luaRcPath = dir .. "/init.lua"
  if vim.fn.filereadable(luaRcPath) == 1 then
    dofile(luaRcPath)
    return true
  end

  local vimRcPath = dir .. "/init.vim"
  if vim.fn.filereadable(vimRcPath) == 1 then
    vim.cmd.source(vim.fn.fnameescape(vimRcPath))
    return true
  end

  return false
end

local function runVimRc()
  -- RECURSION WARNING: Do NOT check for or run VIMINIT.
  -- This is being called from within a VIMINIT set by the Nix wrapper.

  -- Instead, use this DEBUG_VIMINIT envvar. Mainly useful in devshells
  -- for testing live init file changes, as the VIMINIT holding the Nix wrapper
  -- can still get overrwritten if VIMINIT was already set before the wrapper runs.
  if vim.env.LEVI_VIMINIT then
    vim.cmd(vim.env.LEVI_VIMINIT)
    return
  end

  local appname = (vim.env.NVIM_APPNAME or "nvim")
  -- $XDG_CONFIG_HOME
  local configHome = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config/")
  local configHomeDir = configHome .. appname
  if runVimRcAt(configHomeDir) then
    return
  end
  -- $XDG_CONFIG_DIRS
  for dir in vim.gsplit(vim.env.XDG_CONFIG_DIRS or "/etc/xdg", ":") do
    local configDir = dir .. "/" .. appname
    if runVimRcAt(configDir) then
      return
    end
  end
  -- $EXINIT
  if vim.env.EXINIT then
    vim.cmd(vim.env.EXINIT)
    return
  end
end

runVimRc()
