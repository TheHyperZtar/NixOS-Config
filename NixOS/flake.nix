{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

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
      THZ-VM = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          (import ./disko.nix { device = "/dev/vda"; })
          ./hosts/THZ-VM/configuration.nix
        ];
      };
    };

    #home.Configurations.TheHyperZtar = home-manager.lib.homeManagerConfiguration {
      #pkgs = nixpkgs.legacyPackages.${system};
      #modules = [ ./hosts/THZ-PC/home.nix ];
    #};
  };
}
