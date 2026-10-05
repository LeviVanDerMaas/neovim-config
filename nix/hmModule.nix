flake:

{ pkgs, lib, config, ... }:
let
  cfg = config.programs.leviNeovimConfig;
in
{
  options.programs.leviNeovimConfig = {
    enable = lib.mkEnableOption ''
      Configures Home-Manager options with defaults to install and manage my full Neovim
      config. Compared to installing the "full" package directly, this provides a slighlty more
      organic set-up. The installed package only wraps Neovim with plugins and their
      dependencies, and instead installs all config files under $XDG_CONFIG_HOME/nvim and does
      not use a special VIMINIT wrapper (so nvim just runs $XDG_CONFIG_HOME/nvim/init.lua on
      start).
    '';
    useHMPkgs = lib.mkEnableOption ''
      Builds the custom Neovim package using Home-Manager's `pkgs` instance instead of the
      `nixpkgs` instance imported by this flake (which is what is used to build the flake's
      `packages` output). This saves an extra Nixpkgs evaluation and ensures the packages used
      align with packages installed by other parts of the importing Home-Manager config.
      However, this means a change in the nixpkgs instance used by Home-Manager can break the
      package or Neovim config; in such cases you can temporarily disable this to get the
      flake's version of the package until the issues are resolved upstream.
    '';
  };

  config =
    let
      packages =
        if cfg.useHMPkgs then 
          import ./packages.nix pkgs
        else 
          flake.packages.${pkgs.stdenv.hostPlatform.system};
    in
    lib.mkIf cfg.enable {
      home.packages = [ packages.pluginsOnly_noIsolateConfig ];
      xdg.configFile.nvim.source = lib.mkDefault packages.configDir;
    };
}
