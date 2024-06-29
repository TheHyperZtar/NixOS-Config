{
  disko.devices = {
    disk = {
      THZ-Disk = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            Boot = {
              priority = 1;
              name = "Boot";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            Linux = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountOptions = [ "noatime" ];
                    mountpoint = "/";
                  };
                  "@home" = {
                    mountOptions = [ "noatime" ];
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountOptions = [ "noatime" ];
                    mountpoint = "/nix";
                  };
                  "@swap" = {
                    mountOptions = [ "nofail" ];
                    mountpoint = "/.swap";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
