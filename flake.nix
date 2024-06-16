{
  description = "My NixOS Configuration as a flake";
  # To rebuild do: doas nixos-rebuild switch --flake ~/.dotfiles/#ThinkPad

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05"; # Stable
  };

  outputs = { self, nixpkgs, ... }: 
  
  let 
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };

  in 
  {
    nixosConfigurations = {
      ThinkPad = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
