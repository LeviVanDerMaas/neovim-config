self:

{ pkgs, lib, config, ... }:
let
  cfg = config.programs.leviNeovimConfig;
in
{
  options.programs.leviNeovimConfig = {
    enable = lib.mkEnableOption ''
      Configures Home-Manager options to install and manage my full Neovim config. Compared to
      installing this flake's `full` package directly, this provides a a natural setup. The
      installed neovim package is a minimal wrapper that only manages package-level settings;
      all user-level config files are installed under $XDG_CONFIG_HOME/nvim, and a "pack" with
      all plugins is made available under $XDG_DATA_HOME/nvim/site.
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
      inherit (flakePackages) bare full configDir;
      flakePackages =
        if cfg.useHMPkgs then
          import ./packages.nix { inherit self pkgs; }
        else
          self.packages.${pkgs.stdenv.hostPlatform.system};
    in
    lib.mkIf cfg.enable {
      # Install a neovim instance with all package level options that this flake
      # sets, but not wrapped with any other customization, plugins or packages.
      home.packages = [ bare ];
        
      # Now populate .config/nvim with this flake's generated configDir and take
      # the init.lua file from the full package. Similarly, take the plugin pack
      # from the full neovim package and populate .local/share/nvim/site/pack with it.
      xdg.configFile.nvim.source = configDir.override {
        withInitLua = pkgs.writeText "nvim-init.lua" full.luaRcContent;
      };
      xdg.dataFile."nvim/site/pack".source = "${pkgs.neovimUtils.packDir full.packpathDirs}/pack";
    };
}
