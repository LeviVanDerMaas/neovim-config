{
  description = "Neovim config flake with a devshell for iteration without rebuilds.";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      arch = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${arch};
      lib = nixpkgs.lib;

      flakePkgs = import ./nix/packages.nix pkgs;
      inherit (flakePkgs) callFlakePackage;
    in
    {
      packages.${arch} = flakePkgs;
      devShells.${arch} = callFlakePackage ./nix/devshells.nix {};
      homeManagerModules = {
        levisNeovimConfig = import ./nix/hmModule.nix self;
        default = self.homeManagerModules.levisNeovimConfig;
      };
    };
}
