self: { pkgs, lib, config, ... }:

let
  cfg = config.programs.levisNeovimConfig;
in
{
  options.programs.levisNeovimConfig = {
    enable = lib.mkEnableOption ''
      Configures Home-Manager options with defaults to install and manage my full Neovim config.
      Compared to installing the "full" package direclty, this provides a slighlty more organic
      set-up as it instead installs all config files under $XDG_CONFIG_HOME/nvim and does not
      use a special VIMINIT wrapper (so nvim just runs $XDG_CONFIG_HOME/nvim/init.lua on start).
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.pluginsOnly_noIsolateConfig
    ];
    xdg.configFile.nvim.source = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.configDir;
  };
}
