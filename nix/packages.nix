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
    ../after # Don't forget about this one!
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
    # Full: Custom neovim package, wrapped with all plugin packages, all custom config and any runtime dependencies.
    full = callFlakePackage mkNvim { inherit init configDir plugins; };
    # PluginsOnly: Custom neovim package, wrapped with all plugin packages and their runtime dependencies.
    pluginsOnly = callFlakePackage mkNvim { inherit plugins; };
    # Bare: Custom neovim package (that is, only package-level settings, like `.withPyhon3` are included).
    bare = callFlakePackage mkNvim {};
  };
in
flakePkgs
