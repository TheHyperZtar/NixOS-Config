{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    inputs.disko.url = "github:nix-community/disko";
    inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, disko, ... }@inputs:

  let
    system = "x86_64-linux";
  in

  {
    nixosConfigurations = {
      THZ-PC = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/THZ-PC/configuration.nix
          disko.nixosModules.disko
        ];
      };
    };
  };

  home.Configurations.TheHyperZtar = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    modules = [ ./hosts/THZ-PC/home.nix ];
  };
}
