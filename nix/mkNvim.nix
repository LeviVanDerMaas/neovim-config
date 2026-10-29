# Manual entry for building a neovim config: https://nixos.org/manual/nixpkgs/stable/#neovim
# Manual entry for (neo)vim plugins: https://nixos.org/manual/nixpkgs/stable/#vim
# PLUGIN RUNTIMEDEPS: If a plugin package has an attribute 'runtimeDeps' on it, wrapNeovimUnstable
#   will by default add any package in here to the wrapper's PATH. Although
#   extensively used in pkgs/applications/editors/vim/plugins/overrides.nix,
#   very little documentation on it actually exists; `wrapNeovimUnstable` just
#   silently processes it.
{
  pkgs,
  lib,

  baseNeovimPackage ? pkgs.neovim-unwrapped,
  # Given packages will be prefixed to the nvim package's PATH via symlinkJoin,
  # alongside all package specified by on any plugin *package's* 'runtimeDeps' attribute.
  extraPackages ? [],
  # Plugin spec like what wrapNeovimUnstable expects, but additionally:
  # - A plugin with an 'extraPackages' attribute has its value appended to
  #   the general 'extraPackages' argument of this function. Note that this
  #   is alongside the 'runtimeDeps' attribute on individual plugin packages.
  # - A plugin with a 'extraDeps' attribute will append listed plugins
  #   to *this* general 'plugins' argument of this function (allows nesting).
  #   Note that most nix-packaged vim-plugins already specify it if they depend
  #   on other plugins (which wrapNeovimUnstable will install), but this is useful
  #   for optional plugin deps.
  plugins ? [],
  init ? null,
  configDir ? null,
  isolateRuntimepath ? false,
  nvim_appname ? null,
}:
let
  # Make the plugin spec suitable for passing to wrapNeovimUnstable
  normalizePlugins = lib.concatMap (p:
    let
      p' = [ (lib.removeAttrs p [ "extraDeps" "extraPackages" ]) ];
      deps = lib.optionals (p ? extraDeps) (normalizePlugins p.extraDeps);
    in
    p' ++ deps
  );

  # Make a derivation that holds all extra packages specified by the plugin spec.
  pluginExtraPackages = lib.concatMap (p: p.extraPackages or [] ++ p.runtimeDeps or []) plugins;
  extraPackagesDrv = pkgs.symlinkJoin {
    name = "extra-neovim-packages";
    paths = lib.unique (extraPackages ++ pluginExtraPackages);
  };

  # Note that this would not work for cmds that do not play nice with the excmd | seperator
  cmdFlagCmds =
    let
      cmd = builtins.concatStringsSep " | " (
        lib.optional (configDir != null) "set rtp^=${configDir}" ++
        lib.optional isolateRuntimepath "source test.lua"
      );
    in
    if cmd != "" then "--cmd '${cmd}'" else "";

  # To be passed to wrapNeovimUnstable. Deliberatly rebuilt here because
  # YOU SHOULD NOT PASS ATTRIBUTES THAT ARE NOT SPECIFIED IN THE MANUAL OR YOU GET OBSCURE BUGS.
  nvimWrapperConfig = {
    # Disable this because we manage it ourselves via the extraPackagesDrv variable.
    autowrapRuntimeDeps = false;

    vimAlias = true;
    viAlias = true;

    luaRcContent = if init != null then init else  "dofile('${./mimicVimRc.lua}')";
    plugins = lib.unique (normalizePlugins plugins); # wrapNeovimUnstable adds a pack with these plugins to rtp.
    wrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [ extraPackagesDrv ]}"

      "--add-flags"
      "${cmdFlagCmds}"
    ] ++ lib.optionals (nvim_appname != null) [
      "--set"
      "NVIM_APPNAME"
      "${nvim_appname}"
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
