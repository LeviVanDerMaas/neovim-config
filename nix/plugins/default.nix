{ pkgs, ... }: with pkgs; with pkgs.vimPlugins; [

  # QUALITY OF LIFE
  catppuccin-nvim # Theme; integrates with many plugins
  heirline-nvim # Statusline utility API for generating format strings.
  guess-indent-nvim # Heurstically set local expandtab, tabstop, softtabstop, shiftfwidth
  which-key-nvim # Shows popups with available key bindings on short pause
  nvim-surround # Operator-based insertion and manipulation of pairs like (), "", etc.
  rainbow-delimiters-nvim # Adds rainbow coloring to pair-based delimiters.
  indent-blankline-nvim # Adds indentation guides, integrates with rainbow-delimiters
  {
    plugin = neo-tree-nvim; # Extensive filetree plugin for vim
    dependsOn = [
      nui-nvim # Required dep
      plenary-nvim # Required dep
      nvim-web-devicons # Optional for file icons
      # Has some other optional plugins to integrate with
    ];
  }

  # GIT INTEGRATION
  vim-fugitive # Git interface for Vim (repo-level)
  gitsigns-nvim # Deep buffer-level integration for Git

  # TELESCOPE
  {
    plugin = telescope-nvim;
    dependsOn = [
      plenary-nvim # Required dep
      telescope-fzf-native-nvim # Recommended for better sorting performance
      nvim-web-devicons # (Optional) nerd font icons
    ];
    extraPackages = [
      ripgrep # Recommended, and required for grep pickers
      # fd is optional dep, but seems to be only used when rg is not available.
    ];
  }

  # TREESITTER
  (import ./treesitter.nix nvim-treesitter)

  # LSP
  {
    plugin = nvim-lspconfig; # (Semi-)official LSP configurations for nvim. Does not provide lsps itself.
    dependsOn = [
      lazydev-nvim # Configure LuaLS for editing neovim config
    ];
    extraPackages = [
      # LSPS
      lua-language-server
      clang-tools # This has the clangd lsp
      nixd
    ];
  }
  blink-cmp # Comprehensive, batteries-included, neovim completion engine
  tiny-inline-diagnostic-nvim # Very neat inline diagnostics plugin
  fidget-nvim # Adds corner-window with LSP (and optionally for other) notifications
]
