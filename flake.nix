{
  description = "ota2525 NixOS config (host: otto)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, mangowc, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.otto = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        ./hosts/otto/disko.nix
        ./hosts/otto/hardware-configuration.nix
        ./hosts/otto/configuration.nix

        mangowc.nixosModules.mango

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [ mangowc.hmModules.mango ];
          home-manager.users.ota2525 = import ./home/home.nix;
        }
      ];
    };

    # ── 開発環境（nix develop ~/dotfiles#rust）──────────────────
    devShells.${system} = {
      rust = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          clippy
          rustfmt
          rust-analyzer
          pkg-config          # 多くのcrateのビルドで必要
        ];
        RUST_BACKTRACE = "1";
        # rust-analyzer が標準ライブラリのソースを見つけられるように
        RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        shellHook = ''
          echo "🦀 rust devShell — $(rustc --version)"
        '';
      };

      default = self.devShells.${system}.rust;
    };
  };
}
