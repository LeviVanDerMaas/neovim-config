<!-- vim: set tw=80 spell: -->
# Personal Neovim configuration

My personal Neovim configuration. It uses Lua for all the actual configuration
and Nix for managing plugins and their dependencies. However, Nix itself is
*not* required: the Lua configuration is deliberately written as one would on
any other ordinary distro and should work fine in non-Nix environments as long
as the necessary plugins and dependencies are provided.

## Nix Integration
The flake's default package wraps Neovim with the full Lua configuration as well
as any plugins and other dependencies, and isolates it from the default XDG
directories by instead reading from and writing to XDG subdirectories named
`levi_nvim`[^1].
With Nix installed, run it using:
```shell
nix run github:LeviVanDerMaas/neovim-config
```
This is also the package to use for installing the configuration to a Nix
environment.

### Packages
Packages for my Neovim configuration are built using `nix/mkNvim.nix`; the
flake's `packages` consist of my Neovim config built with different parameters
(and some utility functions), and are all located in `nix/packages.nix`.

### Home-Manager Module The flake also exposes a default Home-Manager module
that can be used to install the configuration in a more "traditional" manner.
Compared to the flake's default package, this wraps Neovim only with plugins and
their dependencies, installs the Lua configuration to `$XDG_CONFIG_HOME/nvim`
and does not otherwise isolate neovim from any of the regular XDG dirs. Note
that the module must explicitly be enabled via its `.enable` option, and that
it may conflict with options from Home-Manager's `programs.neovim` module if
that module is also enabled.

### Plugin management
Plugins (and any of their dependencies) are specified in
`nix/plugins/default.nix`. The spec is a slightly extended version of what
nixpkg's `pkgs.wrapNeovimUnstable` expects, and is parsed by `nix/mkNvim.nix`.

### Devshell
The flake also provides a devshell to rapidly test any changes to the Lua
configuration without rebuilding (i.e. as it works in non-Nix environments).
After entering the devshell with:
```shell
nix develop github:LeviVanDerMaas/neovim-config
```
you can run `nvimd` to start an instance of Neovim that is packaged with all
plugins and dependencies as specified by the Nix configuration and isolated[^1]
from any of the default XDG dirs, where `runtimepath` has been prefixed with a
path to the top level of this repo. If auto-detection of the repo's top-level
fails, you can specify the path to use in the environment variable
`NVIM_DEV_CONFIG`.

This is particularly useful as you will still have access to your currently
installed Neovim configuration by running `nvim` while modifying this repo.



[^1]: Note that this does not make it actually stateless. Unfortunately, that is
    very hard to accomplish in any manner where it is still able to interact
    with regular XDG locations, which is useful for things like plugins that
    access your git config.
