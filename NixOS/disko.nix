{ config, lib, pkgs, ... }:

{
  disko.devices.disk = {
    vda = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          vda1 = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1GiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-L THZ-BOOT" ];
              mountOptions = [ "noatime" ];
            };
          };
          vda2 = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f -L THZ-NixOS" ]; # Override existing partition
              subvolumes = {
                "/rootfs" = { mountpoint = "/"; };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  swap = {
                    swapfile.size = "8G";
                  };
                };
              };
              mountpoint = "/partition-root";
              mountOptions = [ "noatime" ];
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
      options = [ "noatime" ];
    };
    "/home" = {
      device = "/dev/disk/by-label/THZ-NixOS/home";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/THZ-BOOT";
      fsType = "vfat";
      options = [ "noatime" ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/THZ-NixOS/nix";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" ];
    };
    "/swap" = {
      device = "/dev/disk/by-label/THZ-NixOS/swap";
      fsType = "btrfs";
      options = [ "noatime" ];
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8192; # 8GB
    }
  ];
}

