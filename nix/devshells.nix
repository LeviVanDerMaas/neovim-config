{ pkgs, lib, flakePkgs }:

{
  default = pkgs.mkShell {
    name = "nvim-config-dev";
    shellHook =
    # bash
    ''
      export NVIM_DEV_CONFIG=$(git rev-parse --show-toplevel)

      echo -en "\e[3;34m\
      Setting exported variable NVIM_DEV_CONFIG to directory's git repo root.
      Run 'nvimd' to invoke nvim with \$NVIM_DEV_CONFIG/init.lua as the vimrc
      file and with 'runtimepath' prefixed with \$NVIM_DEV_CONFIG. This enables
      rapidly testing the config in NVIM_DEV_CONFIG without having to rebuild
      the nix package.

      \$NVIM_DEV_CONFIG=''${NVIM_DEV_CONFIG:-\e[1;31m<FAILED TO DETECT>\e[m}
      \e[m"
    '';

    packages = with pkgs; [
      (writeShellScriptBin "nvimd" ''
        # vim.env treats both empty and unset env vars as nil.
        if [[ -v NVIM_DEV_CONFIG && -f $NVIM_DEV_CONFIG/init.lua ]]; then
          export LEVI_VIMINIT="''${LEVI_VIMINIT-lua dofile('$NVIM_DEV_CONFIG/init.lua')}"
        fi

        ${lib.getExe flakePkgs.pluginsOnly} \
          --cmd "set rtp^=$NVIM_DEV_CONFIG,$NVIM_DEV_CONFIG/after" "$@"
      '')
    ];
  };
}
