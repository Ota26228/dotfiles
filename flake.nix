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

    blupala = {
      url = "github:Ota26228/blupala";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, mangowc, blupala, zen-browser, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    blupala-pkg = blupala.packages.${system}.default;
    zen-browser-pkg = zen-browser.packages.${system}.default;
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
          home-manager.extraSpecialArgs = { inherit inputs; blupala = blupala-pkg; zen-browser = zen-browser-pkg; };
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
