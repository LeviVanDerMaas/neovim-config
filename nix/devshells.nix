{ pkgs, lib, flakePkgs }:

{
  default = pkgs.mkShell {
    name = "nvim-config-dev";
    shellHook =
    # bash
    ''
      export NVIM_DEV_CONFIG=$(git rev-parse --show-toplevel)

      echo -en "\e[3;34m\
      Setting exported variable NVIM_DEV_CONFIG to directory's git repo
      root. Run 'nvimd' to invoke nvim with VIMINIT set to, by default, run
      \$NVIM_DEV_CONFIG/init.lua and with 'runtimepath' prefixed with
      NVIM_DEV_CONFIG. This enables rapidly testing the config in
      NVIM_DEV_CONFIG without having to rebuild the nix package.
      
      NVIM_DEV_CONFIG=$NVIM_DEV_CONFIG
      \e[m"
    '';

    packages = with pkgs; [
      (writeShellScriptBin "nvimd" ''
        if [[ -v NVIM_DEV_CONFIG && -f $NVIM_DEV_CONFIG/init.lua ]]; then
          # If NVIM_DEV_CONFIG is null then so will VIMINIT be, which vim considers as unset
          export VIMINIT="''${VIMINIT-lua dofile('$NVIM_DEV_CONFIG/init.lua')}"
        fi

        ${lib.getExe flakePkgs.pluginsOnly} --cmd "set rtp^=$NVIM_DEV_CONFIG" "$@"
      '')
    ];
  };
}
