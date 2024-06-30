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
              extraArgs = [ "-L THZ-BOOT" ];
              mountOptions = [ "noatime" ];
            };
          };
          THZ-NixOS = {
            name = "THZ-NixOS";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "THZ-NixOS";
            };
          };
        };
      };
    };
    lvm_vg = {
      THZ-NixOS = {
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
