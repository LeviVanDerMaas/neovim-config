# The nixpkgs instance within which neovim is built
# All plugins and other dependencies come from this instance.
pkgs:

let
  lib = pkgs.lib;

  plugins = import ./plugins pkgs;
  init = builtins.readFile "${configDir}/init.lua";

  # All files and directories searched for user-level config according to nvim 0.12.5 `:h startup`
  configLocations = [
     # Files searched for user-level config according to nvim 0.12.5 `:h startup`.
    ../init.lua
    ../init.vim

     # Directories searched for user-level config according to nvim 0.12.5 `:h startup` and `:h `'runtimepath'` .
    ../filetype.lua
    ../autoload
    ../colors
    ../compiler
    ../doc
    ../ftplugin
    ../indent
    ../keymap
    ../lang
    ../lsp
    ../lua
    ../menu.vim
    ../pack
    ../parser
    ../plugin
    ../queries
    ../rplugin
    ../spell
    ../syntax
    ../tutor
  ];

  configDir = lib.fileset.toSource {
    root = ./..;
    fileset = lib.fileset.unions (map lib.fileset.maybeMissing configLocations);
  };

  callFlakePackage = lib.callPackageWith (pkgs // { inherit flakePkgs; });
  mkNvim = callFlakePackage ./mkNvim.nix;
  flakePkgs = {
    inherit callFlakePackage mkNvim configDir;
    default = flakePkgs.full;
    full = callFlakePackage mkNvim { inherit init configDir plugins; };
    full_noIsolateConfig = flakePkgs.full.override { isolateFromXDG = false; };
    pluginsOnly = callFlakePackage mkNvim { inherit plugins; };
    pluginsOnly_noIsolateConfig = flakePkgs.pluginsOnly.override { isolateFromXDG = false; };
  };
in
flakePkgs
