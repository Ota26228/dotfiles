# Arch → NixOS パッケージ移行チェックリスト

生リスト: `arch-explicit.txt`(278) / `arch-aur.txt`(85)

**方針**: 1:1移植しない。`base`/カーネル/ライブラリ/ビルド依存はNixOSが面倒を見るか、開発依存は
**プロジェクトごとの devShell (nix-shell)** で用意する。ここでは「実際に使うアプリ・CLI」だけを移す。
attr名は `nix search nixpkgs <名前>` で要確認（⚠️印は要確認 or flake必要）。

凡例: `[x]` 済 / `[ ]` 追加候補 / 配置先 = configuration.nix(=sys) / home.nix(=home) / devShell / drop

---

## 1. すでに設定済み（desktop core / home.nix・configuration.nix）

- [x] mango(mangowm-git), waybar, rofi, tofi, foot, mako, swaylock, swaybg
- [x] btop, htop, brightnessctl, grim, slurp, wl-clipboard
- [x] neovim, yazi, mpd, rmpc, mpd-mpris, impala, wiremix, s-tui, walker, wlogout
- [x] fcitx5-mozc, noto-fonts(cjk/emoji), pipewire, bluetooth, NetworkManager, greetd+tuigreet, zram

---

## 2. システムに追加推奨（configuration.nix / サービスや programs.* で）

NixOSでは「パッケージを入れる」より専用オプションで有効化する方が正しいもの:

- [x] docker / docker-compose → `virtualisation.docker.enable = true;`
- [x] qemu-full / libvirt / virt-manager / virt-viewer → `virtualisation.libvirtd.enable` + `programs.virt-manager.enable`
- [x] tailscale → `services.tailscale.enable = true;`
- [x] flatpak → `services.flatpak.enable = true;`
- [x] steam → `programs.steam.enable = true;`（lib32 系はこれが面倒を見る）
- [ ] gnome-keyring → `services.gnome.gnome-keyring.enable` + pam連携
- [x] blueman → `services.blueman.enable = true;`（bluez本体はもう有効）
- [x] obs-studio → `programs.obs-studio.enable`（仮想カメラ等が楽）
- [ ] snapd → ⚠️ NixOSでは基本不要。代替を検討（多くは nixpkgs/flatpak で足りる）
- [ ] geoclue → `services.geoclue2.enable`（必要なら）

追加フォント（configuration.nix `fonts.packages`）:
- [x ] nerd-fonts（firacode/hack/jetbrains-mono/iosevka/symbols）, ttf系
  → nixpkgsは `nerd-fonts.fira-code` `nerd-fonts.jetbrains-mono` `nerd-fonts.iosevka` 等の細分化attr
- [ x] dejavu_fonts, open-sans, roboto, font-awesome, noto-fonts-extra

---

## 3. home.packages 追加候補（CLIツール）

- [x] bat fd fzf ripgrep jq zoxide fastfetch tree-sitter
- [x] gh(github-cli) pandoc ueberzugpp
- [x] p7zip(7zip) unzip unar(unarchiver) android-tools
- [x] nmap testdisk smartmontools usbutils evtest sshfs
- [x] pass isync msmtp neomutt mpc playerctl cliphist
- [x] qmk dart-sass(sassc) ddgr
- [ x] rustup → ⚠️ Rust学習用に維持。ただしプロジェクトは devShell 推奨（[[project-screeps-rust]]はwasm-pack等が要るので devShell 化が吉）

## 4. home.packages 追加候補（GUIアプリ）

- [ ] brave(brave-bin→`brave`) chromium zen-browser(⚠️ flake: `zen-browser`)
- [x] vesktop slack(slack) spotify zoom(zoom-us)  ※どれも unfree → `allowUnfree`
- [x] vlc mpv obs-studio rhythmbox kid3
- [x] libreoffice-still(+ja) or wps-office(`wpsoffice`⚠️unfree)
- [x] typora(⚠️unfree) xournalpp zathura(+pdf-mupdf) mupdf pdfjs
- [ ] wezterm  (foot は設定済み。端末2枚持ちなら)
- [ ] bruno burpsuite zaproxy(`zap`) nmap  ※セキュリティ系
- [ ] retroarch rpi-imager steam
- [x ] wf-recorder simplescreenrecorder wl-color-picker virt-manager
- [ ] realvnc-vnc-viewer(⚠️ nixpkgs未収録かも) parsec(`parsec-bin`) winboat(⚠️要確認) xampp(⚠️→ services/nginx等で代替) zoom

## 5. devShell に回す（グローバルに入れない開発依存）

- cmake binaryen glfw avr-libc botan2 cpptoml openssl-1.1 ucl sdx tclkit
- jdk-openjdk jre-jetbrains npm python-*(numpy/scipy/pyqt6/virtualenv/pip/pipx 等)
- texlive-*(basic/latex/langjapanese) tectonic  ← TeXは専用 devShell が定番
- → 各プロジェクトに `shell.nix` / `flake.nix` の devShell を作る

## 6. drop（Arch時代の残骸・別環境・NixOSで不要）

- パッケージ管理: nix paru paru-debug pacman-contrib reflector snapd（NixOS本体が管理）
- ブート/カーネル/MC: base base-devel linux linux-firmware linux-headers intel-ucode（configuration.nixが管理）
- 旧コンポジタ実験: hyprland + hypr*(idle/lock/paper/picker/lang/utils/graphics) xdg-desktop-portal-hyprland
  i3-wm i3blocks i3status i3-auto-layout i3lock-color autotiling python-i3ipc
  somebar-git wideriver lswt wlrctl wbg kanshi dmenu slock swayidle wdisplays
- 旧AGS/astal(AIサイドバー): aylurs-gtk-shell-git libastal-* noctalia-shell noctalia-qs
  appmenu-glib-translator-git python-pywal python-adblock
- 旧ディスプレイマネージャ: lightdm(+gtk-greeter) ly sddm sddm-*theme* greetd-gtkgreet
- X11: xorg-xinit xorg-xrandr xorg-xdpyinfo xf86-video-* arandr xdotool xclip scrot feh
  flameshot xss-lock vmware-keymaps wlroots0.18/0.19(mangoが持つ) scenefx0.4
- 他環境GPU: vulkan-nouveau vulkan-radeon（Intel機なので不要）
- debug版: *-debug 全部

---

## 使い方
1. 上の `[ ]` を見て、自分が今後使うものに `[x]`
2. 配置先(sys/home/devShell)に従って各 .nix に追記
3. `nix search nixpkgs <名前>` で正確なattr名を確認（⚠️印は特に）
4. unfreeアプリを使うなら configuration.nix に `nixpkgs.config.allowUnfree = true;`
