# The nixpkgs instance within which neovim is built
# All plugins and other dependencies come from this instance.
self: pkgs:

let
  lib = pkgs.lib;

  plugins = import ./plugins pkgs;
  init = builtins.readFile ../init.lua;

  callFlakePackage = lib.callPackageWith (pkgs // { inherit flakePkgs; });
  mkNvim = callFlakePackage ./mkNvim.nix;
  configDir = callFlakePackage ./mkConfigDir.nix { configRoot = self.outPath; };
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
