{ config, pkgs, lib, inputs, ... }:
{
  # ── ブート（UEFI + systemd-boot）─────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # LUKSのアンロック設定は disko.nix から自動生成される（ここには書かない）

  # ── ホスト名 / 時刻 / ロケール ───────────────────────────────
  networking.hostName = "otto";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";
  console.keyMap = "us";

  # ── ネットワーク（現環境と同じ NetworkManager）──────────────
  networking.networkmanager.enable = true;

  # ── CPU マイクロコード（Intel）──────────────────────────────
  hardware.cpu.intel.updateMicrocode = true;

  # ── オーディオ（pipewire）───────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # ── Bluetooth ───────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ── 日本語入力（fcitx5-mozc）────────────────────────────────
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc ];
    fcitx5.waylandFrontend = true;
  };

  # ── コンポジタ mango（flake の NixOS モジュール）─────────────
  programs.mango.enable = true;

  # ── ログイン（greetd + tuigreet → mango 起動）───────────────
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --greeting \"ようこそ otto\" --cmd mango";
      user = "greeter";
    };
  };

  # ── polkit / xdg-portal ─────────────────────────────────────
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ── フォント（日本語 + Nerd Fonts + 汎用）───────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    dejavu_fonts
    open-sans
    roboto
    roboto-mono
    font-awesome
    # Nerd Fonts（細分化attr。必要なものだけ）
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
  ];

  # ── シェル（fish）───────────────────────────────────────────
  programs.fish.enable = true;

  # ── ユーザー ────────────────────────────────────────────────
  users.users.ota2525 = {
    isNormalUser = true;
    description = "ota2525";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "libvirtd" ];
    shell = pkgs.fish;
    # 初回インストール時に passwd で設定。後で hashedPassword 等に変更可
  };

  # ── swap（現環境と同じ zram）────────────────────────────────
  zramSwap.enable = true;

  # ── Nix 設定（flakes 常用）──────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # unfree アプリ（slack/spotify/zoom/typora/steam 等）を許可
  nixpkgs.config.allowUnfree = true;

  # ── 仮想化 / サービス
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.tailscale.enable = true;
  services.flatpak.enable = true;
  services.blueman.enable = true;

  # ── SSH ─────────────────────────────────────────────────────
  # クライアント + ssh-agent（git@github 等で使う）。
  # 秘密鍵 ~/.ssh はユーザーデータなのでバックアップから復元すること。
  programs.ssh.startAgent = true;
  # otto へ外部から SSH ログインしたい場合は ↓ を true に
  services.openssh.enable = false;

  programs.steam.enable = true;   # lib32/driver 周りも面倒を見てくれる

  # ── システム最小パッケージ（ユーザーアプリは home.nix）──────
  environment.systemPackages = with pkgs; [ git vim wget ];

  # 一度決めたら変えない（このマシンの初期NixOSバージョン）
  system.stateVersion = "26.05";
}
