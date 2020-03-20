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
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/sda2";
      preLVM = true;
    };
  };

  # power management stuff
  boot.extraModprobeConfig = "options snd_hda_intel power_save=1";
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };

  # fix loading of terminus / other bitmap fonts
  fonts.fontconfig.useEmbeddedBitmaps = true;

  hardware.acpilight.enable = true;

  # networking stuff
  networking.hostName = "thinkingbus";
  networking.wireless.enable = true;

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
  ]);

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  programs.dconf.enable = true;

  virtualisation.docker.enable = true;

  # enable ssh-agent
  programs.ssh.startAgent = true;
  programs.ssh.agentTimeout = "1h";

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;

  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable i3 Desktop Environment.
  services.xserver = {
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
    '';
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.multun = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" "nix-config" "docker" "wireshark" "scanner" ];
    group = "users";
    createHome = true;
    home = "/home/multun";
    uid = 1000;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
