{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # use the same pkgs set
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system  = system;
      modules = [
        ./nixos/configuration.nix        # your system module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;  # reuse system pkgs
          home-manager.users.topi = import ./home.nix;
        }
      ];
      specialArgs = { inherit pkgs; };
    };
  };
}
