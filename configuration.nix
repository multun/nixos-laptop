# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # memtest86 is unfree :(
  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/553cb8ac-0b2f-4d7c-aa46-4582ac0deacf";
      preLVM = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ pkgs.linuxPackages_latest.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };

  networking.hostName = "thinkingbus";
  networking.wireless.enable = true;


  # fix loading of terminus / other bitmap fonts
  fonts.fontconfig.useEmbeddedBitmaps = true;

  hardware.acpilight.enable = true;

  # weird intel stuff
#  nixpkgs.config.packageOverrides = pkgs: {
#    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
#  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.enableDebugInfo = true;
  environment.systemPackages = (with pkgs; [
    git
    openssh
    procps-ng
    nix-prefetch-scripts
    emacs
    curl
    which
    nano
    socat
    tmux
    mosh
    tcpdump
    mtr
    font-awesome
    v4l-utils
  ]);

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };


  time.timeZone = "Europe/Paris";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  programs.adb.enable = true;

  programs.dconf.enable = true;

  # virtualisation.docker.enable = true;

  # enable ssh-agent
  programs.ssh.startAgent = true;
  programs.ssh.agentTimeout = "1h";

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable i3 Desktop Environment.
  services.xserver = {
    wacom.enable = true;
    enable = true;
    layout = "fr";
    xkbOptions = "oss";
    libinput.enable = true;
    libinput.disableWhileTyping = true;
    desktopManager.xterm.enable = false;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };

  services.xserver.displayManager.defaultSession = "none+i3";

  xdg.portal.enable = false;

  hardware.sane.enable = true;
  services.udev = {
    extraRules = ''
      # Canon CanoScan Lide 120
      ATTRS{idVendor}=="04a9", ATTRS{idProduct}=="190e", ENV{libsane_matched}="yes"
      # Rule for the Ergodox EZ
      SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.multun = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" "nix-config" "wireshark" "scanner" "adbusers" "plugdev" "docker" ];
    group = "users";
    createHome = true;
    home = "/home/multun";
    uid = 1000;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?

}
