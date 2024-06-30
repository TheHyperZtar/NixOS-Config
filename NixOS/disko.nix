{
  device ? throw ,
  ...
}: {
  disko.devices = {
    disk.main = {
      inherit device;
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
}
