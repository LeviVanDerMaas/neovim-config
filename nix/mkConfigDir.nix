{ pkgs, lib, configRoot, withInitLua ? null }:
let
  # Directories searched for user-level config according to nvim 0.12.5 `:h
  # startup` and `:h `'runtimepath'` . Note that this does not include init.lua
  # or init.vim
  runtimePaths = lib.concatMapStringsSep " " lib.escapeShellArg [
    "after"
    "filetype.lua"
    "autoload"
    "colors"
    "compiler"
    "doc"
    "ftplugin"
    "indent"
    "keymap"
    "lang"
    "lsp"
    "lua"
    "menu.vim"
    "pack"
    "parser"
    "plugin"
    "queries"
    "rplugin"
    "spell"
    "syntax"
    "tutor"
  ];
in
# Use toString ./. to avoid Nix from recopying the flake as an ordinary dir under a different path.
pkgs.runCommandLocal "nvim-config-dir" {} ''
  mkdir -p "$out"
  configRoot=${configRoot}
  for runtimePath in ${runtimePaths}; do
    p="$configRoot"/"$runtimePath"
    if [[ -e "$p" ]]; then
      cp -r "$p" "$out"/"$runtimePath"
    fi
  done
  ${lib.optionalString (withInitLua != null) ''cp -r "${withInitLua}" "$out"/init.lua''}
''
