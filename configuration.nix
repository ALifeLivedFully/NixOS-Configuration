# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  # unstableTarball =
  #   fetchTarball
  #     https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  
  # stableTarball =
  #   fetchTarball
  #     https://github.com/NixOS/nixpkgs/archive/nixos-24.05.tar.gz;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # # Add Unstable channel declaritively
  # nixpkgs.config = {
  #   packageOverrides = pkgs: {
  #     unstable = import unstableTarball {
  #       config = config.nixpkgs.config;
  #     };
  #     # stable = import stableTarball {
  #     #   config = config.nixpkgs.config;
  #     # };
  #   };
  # };

  # Enable NixOS experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Workaround for https://github.com/NixOS/nix/issues/9574
  nix.settings.nix-path = config.nix.nixPath;

  # custom hardware configuration
  boot.initrd.kernelModules = [ "8821cu" ]; # 8821cu = WIFI Dongle
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8821cu ]; # config...rtl8821cu = WIFI Dongle

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kod = {
    isNormalUser = true;
    description = "Dani";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Add packages here
      vscodium
      anki-bin
      scrcpy
      session-desktop
      ollama                            # See Configuration.nix
      godot_4
      obsidian                          # Unfree, is there an open alternative?
      git                               # See Configuration.nix
      rustup
      firefox           
      thunderbird
      keepassxc
      prismlauncher                     # Open source minecraft launcher for modded/vanilla
      kodi
      vlc
      qbittorrent
      veracrypt                         # Unfree, is there an open alternative?
      libreoffice
      libresprite
      gimp
      briar-desktop
      blender
      audacity
    ];
  };

  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "veracrypt"
    "obsidian"
  ];

  # Some packages are marked as insecure and will refuse to evaluate unless you add them here to acknowledge the potential security risk. CAUTION!
  nixpkgs.config.permittedInsecurePackages = [
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  home-manager                          # Home manager config file is located here: /home/kod/.config/home-manager/home.nix
  ];

  # Automatic system upgrades (it wasnt working for me without removing the line setting flake)
  # To see the status of the timer run: systemctl status nixos-upgrade.timer
  # The upgrade log can be printed with this command: systemctl status nixos-upgrade.service
  
  system.autoUpgrade = {
    enable = true;
    # flake = inputs.self.outPath; # for flake based systems
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" 
    ];
    dates = "09:00";
    randomizedDelaySec = "45min";
  };

  # DOAS Configuration (Delete Section to restore Sudo)
  security.doas.enable = true;    # Enable Doas
  security.sudo.enable = false;   # Disable Sudo
  security.doas.extraRules = [{
  users = [ "kod" ];
  # keepEnv = true;
  persist = true;  
  }];

  

  services = {
    # Ollama Configuration
    # ollama = {
    #   enable = true;        # On Linux Ollama is running on as a systemd service. To stop it run: systemctl stop ollama.service
    #   acceleration = null;  # Acceleration options: null, "cuda", or "rocm"
    # };

    # # On Linux syncthing is running on as a systemd service. To stop it run: systemctl stop syncthing-init.service
    # syncthing = {
    #   enable = true;
    #   user = "NixOS";
    #   overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    #   overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    #   guiAddress = "https://127.0.0.1:8384";
    #   settings = {
    #     gui = {
    #       user = "alifelivedfully";
    #       password = "Password";
    #     };
    #     devices = {
    #       # "device" = { id = "DEVICE-ID-GOES-HERE"; };
    #       "S24" = { id = "DZEDZUS-3IVZQUU-BK6YR5M-7L4ILWN-MUK3VOH-6IC7PWW-5HK3YST-PKL5PQ3"; };
    #     };
    #     folders = {
    #       "Documents" = {         # Name of folder in Syncthing, also the folder ID
    #         path = "/home/kod/Documents";    # Which folder to add to Syncthing
    #         devices = [ "S24" ];      # Which devices to share the folder with
    #       };
    #       # "Example" = {
    #       #   path = "/home/myusername/Example";
    #       #   devices = [ "device1" ];
    #       #   ignorePerms = false;  # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
    #       # };
    #     };
    #   };
    # };
  };

  # # SyncThing Configuration
  # services.syncthing = {
  #   enable = true;
  #   guiAddress = "https://127.0.0.1:8384"; # Default address: "127.0.0.1:8384"
  #   key = null;
  #   cert = null;
  #   extraFlags = [
  #     # Flags here within quotes
  #   ];
  #   settings = {
  #     gui = {
  #       theme = "black";
  #       user = "Username";
  #       password = "Password";
  #     };
  #     options = {
  #       urAccepted = -1;
  #       # localAnnounceEnabled = false;
  #     };
  #     # Folders section:
  #     folders = {
  #       "/home/kod/Documents" = {
  #         id = "Documents";
  #         devices = [ "S24" ];
  #       };
  #     };
  #     # Devices section:
  #     devices = {
  #       S24 = {
  #         addresses = [
  #           "dynamic"
  #         ];
  #         id = "DZEDZUS-3IVZQUU-BK6YR5M-7L4ILWN-MUK3VOH-6IC7PWW-5HK3YST-PKL5PQ3";
  #       };
  #     };
  #   };
  # };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
