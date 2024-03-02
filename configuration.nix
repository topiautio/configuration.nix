# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Make the kernel use the correct driver early
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  # Needed for OBS virtual camera
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;
  
  # may fix driver problems
  hardware.opengl = {
  ## radv: an open-source Vulkan driver from freedesktop
  driSupport = true;
  driSupport32Bit = true;
  ## amdvlk: an open-source Vulkan driver from AMD
  extraPackages = [ pkgs.amdvlk ];
  extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };

  networking.hostName = "kone"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  
  services.xserver = { 
    # Enable the X11 windowing system.
    enable = true;
    # Configure keymap in X11
    layout = "fi";
    xkbVariant = "";
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Enable DWM Window Manager
    windowManager.dwm.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;
  };
  
  # DWM patches
  services.xserver.windowManager.dwm.package = pkgs.dwm.override {
  patches = [
    (pkgs.fetchpatch {
      url = "https://dwm.suckless.org/patches/systray/dwm-systray-6.4.diff";
      hash = "sha256-TXErH76w403T9tSJYu3tAJrQX3Y3lKSulKH0UdQLG/g=";
    })
    (pkgs.fetchpatch {
      url = "https://raw.githubusercontent.com/ashish-yadav11/dwmblocks/master/patches/dwm-systray-dwmblocks-6.4.diff";
      hash = "sha256-n36SJHX03Px6DLnYl4oAps9vqx05NWl2iAXyqaNSfiI=";
    })
  ];
};


  # Configure console keymap
  console.keyMap = "fi";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.topi = {
    isNormalUser = true;
    description = "Topi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim
  wget
  firefox
  brave
  git
  discord
  btop
  cifs-utils
  steam
  neofetch
  htop
  cmus
  mpv
  obs-studio
  easyeffects
  signal-desktop
  protonup-qt
  lutris
  bottles
  gnome3.adwaita-icon-theme
  lm_sensors
  radeontop
  telegram-desktop
  dmenu
  st
  prismlauncher
  jdk
  dwmblocks
  (st.overrideAttrs (oldAttrs: rec {
    patches = [
      (fetchpatch {
        url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff";
        sha256 = "sha256-ZZAbrWyIaYRtw+nqvXKw8eXRWf0beGNJgoupRKsr2lc=";
      })
      #(fetchpatch {
      #  url = "https://raw.githubusercontent.com/fooUser/barRepo/1111111/somepatch.diff";
      #  sha256 = "222222222222222222222222222222222222222222";
      #})
    ];
   }))
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  fileSystems."/mnt/MEDIA1TB" = {
    device = "//192.168.8.203/MEDIA1TB";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
