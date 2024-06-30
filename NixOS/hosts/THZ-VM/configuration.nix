{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./../../disko.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    grub.enable = true;
    grub.device = "nodev";
    grub.efiSupport = true;
    grub.efiInstallAsRemovable = true;
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  networking.hostName = "THZ-VM";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Mazatlan";

  i18n.defaultLocale = "es_MX.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.xserver = {
    enable = true;
    xkb.layout = "latam";
    xkb.options = "eurosign:e,caps:escape";
  };

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  services.libinput.enable = true;

  users.users.TheHyperZtar = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/TheHyperZtar";
    initialPassword = "1234";
  };

  environment.systemPackages = with pkgs; [
    btop
    firefox
    kitty
    git
    nano
    neofetch
    wget
  ];

  services.displayManager.sddm.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics.enable = true;

  system.stateVersion = "24.05";

}

