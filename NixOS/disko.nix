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
          Boot = {
            name = "THZ-BOOT";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-L THZ-BOOT" ];
              mountOptions = [ "noatime" ];
            };
          };
          Root = {
            name = "THZ-NixOS";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "root_vg";
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f -L THZ-NixOS" ];

              subvolumes = {
                "/@" = {
                  mountpoint = "/";
                };

                "/@home" = {
                  mountOptions = ["subvol=@home" "noatime"];
                  mountpoint = "/home";
                };

                "/@nix" = {
                  mountOptions = ["subvol=@nix" "noatime"];
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
