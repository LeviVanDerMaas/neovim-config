# Manual entry for building a neovim config: https://nixos.org/manual/nixpkgs/stable/#neovim
# NOTE: Try to avoid passing attributes to wrapNeovimUnstable that it does not specify,
# as this has caused weird breakage issues in the past.

{ pkgs, lib }:

{
  baseNeovimPackage ? pkgs.neovim-unwrapped,
  # Given packages will be prefixed to the nvim package's PATH via symlinkJoin.
  extraPackages ? [],
  # Plugin spec like what wrapNeovimUnstable expects, but additionally:
  # - A plugin with an 'extraPackages' attribute has its value appended to
  #   the general 'extraPackages' argument of this function.
  # - A plugin with a 'dependsOn' attribute will append listed plugins
  #   to the general 'plugins' argument of this function (allows nesting).
  plugins ? [],
  init ? null,
  configDir ? null,
  isolateFromXDGConfig ? true
}:
let
  # Make the plugin spec suitable for passing to wrapNeovimUnstable
  normalizePlugins = lib.concatMap (p:
    let
      p' = [ (lib.removeAttrs p [ "dependsOn" "extraPackages" ]) ];
      deps = lib.optionals (p ? dependsOn) (normalizePlugins p.dependsOn);
    in
    p' ++ deps
  );

  # Make a derivation that holds all extra packages specified by the plugin spec.
  pluginExtraPackages = lib.concatMap (p: p.extraPackages or []) plugins;
  extraPackagesDrv = pkgs.symlinkJoin {
    name = "extra-neovim-packages";
    paths = lib.unique (extraPackages ++ pluginExtraPackages);
  };

  nvimWrapperConfig = {
    ${if init == null then null else "luaRcContent"} = init;
    wrapRc = init != null;
    plugins = lib.unique (normalizePlugins plugins);
    vimAlias = true;
    viAlias = true;
    wrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [ extraPackagesDrv ]}"

      "--add-flags"
      "${if configDir == null then "" else "--cmd 'set rtp^=${configDir}'"}"
    ] ++ lib.optionals isolateFromXDGConfig [
      "--set"
      "XDG_CONFIG_HOME"
      (toString ./. + "/FAKE_NONEXISTENT_XDG_CONFIGDIR")

      "--unset"
      "XDG_CONFIG_DIRS"
    ];
  };

  attrsOverrider = prev: {
    postBuild = prev.postBuild + ''
      substituteInPlace $out/share/applications/nvim.desktop \
        --replace-warn 'Name=Neovim wrapper' 'Name=Neovim'
    '';
  };
in
(pkgs.wrapNeovimUnstable baseNeovimPackage nvimWrapperConfig).overrideAttrs attrsOverrider
