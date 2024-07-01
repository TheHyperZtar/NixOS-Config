{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      #./../../disko.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    grub.enable = true;
    grub.device = "nodev";
    grub.efiSupport = true;
    grub.efiInstallAsRemovable = true;
    efi.efiSysMountPoint = "/boot";
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

