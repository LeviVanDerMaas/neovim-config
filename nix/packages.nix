{ pkgs, lib, ... }:

let
  plugins = import ./plugins pkgs;
  init = builtins.readFile "${configDir}/init.lua";
  configDir = lib.cleanSourceWith {
    name = "neovim-config";
    src = lib.cleanSource ../.;
    filter = p: t: !(lib.elem (baseNameOf p) [
      ".gitignore"
      ".direnv"
      ".envrc"
      ".nvim.lua"
      "nix"
      "flake.nix"
      "flake.lock"
    ]);
  };

  callFlakePackage = lib.callPackageWith (pkgs // { inherit flakePkgs; });
  mkNvim = callFlakePackage ./mkNvim.nix {};
  flakePkgs = {
    inherit callFlakePackage mkNvim configDir;
    default = flakePkgs.full;
    full = callFlakePackage mkNvim { inherit init configDir plugins; };
    full_noIsolateConfig = flakePkgs.full.override { isolateFromXDGConfig = false; };
    pluginsOnly = callFlakePackage mkNvim { inherit plugins; };
    pluginsOnly_noIsolateConfig = flakePkgs.pluginsOnly.override { isolateFromXDGConfig = false; };
  };
in
flakePkgs
