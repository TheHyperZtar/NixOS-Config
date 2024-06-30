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
    pkgs = import nixpkgs {
      inherit system;
    };
    lib = nixpkgs.lib;
  in

  {
    nixosConfigurations = {
      THZ-VM = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
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
                        extraArgs = [ "-n THZ-BOOT" ];
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
            fileSystems = lib.mkForce {
              "/" = {
                device = "/dev/disk/by-label/THZ-NixOS";
                fsType = "btrfs";
                options = [ "subvol=/root" "noatime" ];
                };

              "/boot" = {
                device = "/dev/disk/by-label/THZ-BOOT";
                fsType = "vfat";
                options = [ "noatime" ];
              };

              "/home" = {
                device = "/dev/disk/by-label/THZ-NixOS";
                fsType = "btrfs";
                options = [ "subvol=/home" "noatime" ];
              };

              "/nix" = {
                device = "/dev/disk/by-label/THZ-NixOS";
                fsType = "btrfs";
                options = [ "subvol=/nix" "noatime" ];
              };
            };
          }
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
