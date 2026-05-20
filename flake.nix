{
  description = "Neovim config flake with a devshell for iteration without rebuilds.";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };

      flakePkgs = import ./nix/packages.nix pkgs;
      inherit (flakePkgs) callFlakePackage;
    in
    {
      packages.${system} = flakePkgs;
      devShells.${system} = callFlakePackage ./nix/devshells.nix {};
      homeManagerModules = {
        levisNeovimConfig = import ./nix/hmModule.nix self;
        default = self.homeManagerModules.levisNeovimConfig;
      };
    };
}
