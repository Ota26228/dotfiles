{ config, pkgs, lib, inputs, blupala, zen-browser, ... }:

let
  dotfiles = "/home/ota2525/dotfiles";
  # リポジトリの実ファイルへ生symlinkを張る（編集即反映：今までと同じ感覚）
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # ── home-manager 基本 ───────────────────────────────────────
  home.username = "ota2525";
  home.homeDirectory = "/home/ota2525";
  home.stateVersion = "26.05";

  # ── mango（home-manager モジュール / flake で import 済み）───
  wayland.windowManager.mango.enable = true;
  # 設定本体は既存 config.conf をそのまま使う（下の xdg.configFile）

  # ── ユーザーアプリ ──────────────────────────────────────────
  home.packages = with pkgs; [
    # bar / launcher / term / notify
    waybar rofi tofi kitty mako swaylock swaybg waypaper
    # utils
    btop htop brightnessctl grim slurp wl-clipboard
    # editor / files
    neovim yazi
    # music
    mpd rmpc mpd-mpris
    # TUIs（AUR由来 → nixpkgs）
    impala wiremix s-tui
    # launcher（walker-bin → walker）
    walker
    # polkit agent（mango autostart で使う場合）
    kdePackages.polkit-kde-agent-1
    # その他デスクトップ
    xdg-utils wlogout thunar

    # ── 自作ツール ──
    blupala

    # ── Claude Code ──
    claude-code

    # ── 授業用 ──
    nodejs_22

    # ── neovim プラグインビルド用 ──
    gcc gnumake cmake

    # ── LSP サーバー（mason の代わりに nixpkgs から）──
    vscode-langservers-extracted  # eslint-lsp
    typescript-language-server
    pyright                       # Python LSP
    prettier
    # rust-analyzer は rustup が内包するため不要

    # ── CLI ツール ──
    starship
    bat fd fzf ripgrep jq zoxide fastfetch tree-sitter
    gh pandoc ueberzugpp
    p7zip unzip unar android-tools
    nmap testdisk smartmontools usbutils evtest sshfs
    pass isync msmtp neomutt mpc playerctl cliphist
    qmk dart-sass ddgr
    rustup            # Rust学習用に維持（プロジェクトは devShell 推奨）
    # 言語/DB（常用分。重いライブラリは各プロジェクトの devShell へ）
    python3           # 対話インタプリタ（標準ライブラリの sqlite3 モジュール込み）
    uv                # 高速な Python パッケージ/venv 管理（pip/pipx/virtualenv 代替）
    sqlite            # sqlite3 CLI（DB直接操作用）

    # ── GUI アプリ ──
    zen-browser
    firefox
    imv
    vesktop slack spotify zoom-us
    vlc mpv obs-studio rhythmbox kid3
    libreoffice       # office は libreoffice のみ
    typora xournalpp mupdf
    wf-recorder simplescreenrecorder wl-color-picker
    # winboat は不要（導入しない）
    # blupala は導入しない（決定済み）
  ];

  # zathura（PDFビューア）は home-manager モジュールで（mupdfプラグイン込み）
  programs.zathura.enable = true;

  # direnv + nix-direnv（cd で devShell 自動有効化 + nixキャッシュ高速化）
  # ※ fish統合は raw config.fish 側で `direnv hook fish | source` 済み
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

services.udiskie = {
  enable = true;
  automount = true;
  notify = true;
  tray = "never";  # トレイアイコンを出さない。出したいなら "auto"
};

  # ── 既存 dotfiles をそのまま配置（編集即反映）──────────────
  xdg.configFile = {
    "mango/config.conf".source  = link "mango/config.conf";
    "waybar/config".source      = link "waybar/config.jsonc";
    "waybar/style.css".source   = link "waybar/style.css";
    "wlogout/layout".source     = link "wlogout/layout";
    "wlogout/style.css".source  = link "wlogout/style.css";
    "fish/config.fish".source   = link "fish/config.fish";
    "kitty".source              = link "kitty";
    "mako".source               = link "mako";
    "rofi/config.rasi".source   = link "rofi/config.rasi";
    "starship.toml".source      = link "starship.toml";
    "btop/btop.conf".source     = link "btop.conf";
    "btop/themes".source        = link "btop/themes";   # phoenix-night.theme 同梱
    "nvim".source               = link "nvim";
    "yazi/yazi.toml".source     = link "yazi/yazi.toml";
  };

  # ── 壁紙（~/Wallpapers → repo/wallpapers。厳選分を配置）──────
  # config.conf の swaybg が ~/Wallpapers/wallpaper.jpg を参照
  home.file."Wallpapers".source = link "wallpapers";

  # ── サービス（install.sh の systemctl --user を翻訳）────────
  services.mpd = {
    enable = true;
    musicDirectory = "/home/ota2525/Music";   # 必要なら設定
  };
  services.mpd-mpris.enable = true;

  # ── polkit認証エージェント（mango から systemctl で起動）─────
  # Archの /usr/lib/... 直叩きは NixOS で壊れるため systemd ユーザーサービス化。
  # config.conf の `exec-once=systemctl --user start polkit-kde-agent.service` が起動する。
  systemd.user.services.polkit-kde-agent = {
    Unit.Description = "polkit-kde-authentication-agent-1";
    Service = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
