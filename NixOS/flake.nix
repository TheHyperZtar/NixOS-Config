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

  outputs = { self, nixpkgs, home-manager, disko, ... }:

  let
    system = "x86_64-linux";
  in

  {
    nixosConfigurations = {
      THZ-VM = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/THZ-VM/configuration.nix
          disko.nixosModules.disko
          {
            disko.devices = {
              disk.main = {
                device = "/dev/disk/by-id/some-disk-id";
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    THZ-BOOT = {
                      name = "THZ-BOOT";
                      size = "1G";
                      type = "EF00";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                        extraArgs = [ "-n THZBOOT2" ];
                        mountOptions = [ "noatime" ];
                      };
                    };
                    THZ-NixOS = {
                      name = "THZ-NixOS";
                      size = "100%";
                      content = {
                        type = "btrfs";
                        extraArgs = [ "-f -L THZ-NixOS" ];
                        subvolumes = {
                          "/root" = {
                            mountOptions = [ "noatime" ];
                            mountpoint = "/";
                          };

                          "/home" = {
                            mountOptions = [ "noatime" ];
                            mountpoint = "/home";
                          };

                          "/nix" = {
                            mountOptions = [ "noatime" ];
                            mountpoint = "/nix";
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          }
        ];
      };
    };

    #home.Configurations.TheHyperZtar = home-manager.lib.homeManagerConfiguration {
      #pkgs = nixpkgs.legacyPackages.${system};
      #modules = [ ./hosts/THZ-PC/home.nix ];
    #};
  };
}
