<!-- vim: set tw=80 spell: -->
# Personal Neovim configuration

My personal Neovim configuration. It uses Lua for all the actual configuration
and Nix for managing plugins and their dependencies. However, Nix itself is
*not* required: the Lua configuration is deliberately written as one would on
any other ordinary distro and should work fine in non-Nix environments as long
as the necessary plugins and dependencies are provided.

## Nix Integration
The flake's default package wraps Neovim with the full Lua configuration as well
as any plugins and other dependencies, and isolates `runtimepath` from any user
directories[^1]. With Nix installed, run it using:
```shell
nix run github:LeviVanDerMaas/neovim-config
```
This is also the package to use for installing the configuration to a Nix
environment.

### Packages
Packages for my Neovim configuration are built using `nix/mkNvim.nix`; the
flake's `packages` consist of my Neovim config built with different parameters
(and some utility functions), and are all located in `nix/packages.nix`.

### Home-Manager Module
The flake also exposes a default Home-Manager module that can be used to install
the configuration in a more "traditional" manner. Compared to the flake's
default package, this wraps Neovim only with plugins and their dependencies,
installs the Lua configuration to `$XDG_CONFIG_HOME/nvim` and does not otherwise
isolate neovim from any of the regular XDG dirs. Note that the module must
explicitly be enabled via its `.enable` option, and that it may conflict with
options from Home-Manager's `programs.neovim` module if that module is also
enabled.

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
you can run `nvimd` to start an instance of Neovim that is wrapped with all
plugins and dependencies as specified by the Nix configuration, where
`runtimepath` has been isolated[^1] from any user directories and has been
prefixed with a path to the top level of this repo. As such, any changes to the
Lua configuration are immediately visible when invoking `nvimd` and rebuilding
is required only when changing the plugin installations. This is particularly
useful as you will still have access to your currently installed Neovim
configuration by running `nvim` while modifying this repo.





[^1]: Note that this isolation applies **ONLY** to `runtimepath`, so things like
    state, cache and logging are not isolated from the system. This is actually
    preferable as you generally want to carry these over between changes in your
    Neovim configuration or data files.
