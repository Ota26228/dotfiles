# otto インストール手順（Arch → NixOS）

クリーンインストール。`nvme0n1` を全消去して NixOS をflakeから構築する。

## 0. 事前確認（インストール前）
- [ ] 大物データ退避済み: scholl→GitHub / VirtualMachines→sdb / 鍵類・mozc辞書
- [ ] `~/.ssh`, `~/.gnupg`, mozcユーザー辞書(`~/.config/mozc`) を外部退避
- [ ] **VM入りの sdb は物理的に抜く**（diskoの誤爆防止。触るのは nvme0n1 のみ）
- [ ] NixOS USB（sda）から起動

## 1. ライブ環境の準備
```sh
# キーボード等はそのまま。root作業を楽にする
sudo -i

# ネット接続
#   有線: 自動(dhcpcd)
#   無線: 下のどれか
nmtui                     # あれば一番楽
# もしくは
wpa_passphrase SSID 'パスフレーズ' > /tmp/wpa.conf && wpa_supplicant -B -i wlan0 -c /tmp/wpa.conf
ping -c2 github.com       # 疎通確認
```

## 2. flake(dotfiles) を取得
```sh
nix-shell -p git
git clone https://github.com/Ota26228/dotfiles /tmp/dotfiles
cd /tmp/dotfiles
```

## 3. ディスク構築（disko: LUKS + btrfs）
```sh
# nvme0n1 を全消去して disko.nix の通りに作成（LUKSパスフレーズを設定）
nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount --flake /tmp/dotfiles#otto
# → /mnt 以下にマウントされる
```

## 4. 実機の hardware-configuration.nix を生成して差し替え
```sh
# filesystems は disko が提供するので --no-filesystems
nixos-generate-config --no-filesystems --root /mnt
# 生成された本物でスタブを上書き
cp /mnt/etc/nixos/hardware-configuration.nix \
   /tmp/dotfiles/hosts/otto/hardware-configuration.nix
git -C /tmp/dotfiles add -A    # flakeはtrackedファイルしか見ない
```

## 5. インストール
```sh
nixos-install --flake /tmp/dotfiles#otto
#   → 最後に root パスワードを設定

# ~/dotfiles を新システムへ配置（home.nixの mkOutOfStoreSymlink が参照するため必須）
mkdir -p /mnt/home/ota2525
cp -r /tmp/dotfiles /mnt/home/ota2525/dotfiles

# ユーザーパスワードと所有権
nixos-enter --root /mnt -c 'passwd ota2525'
nixos-enter --root /mnt -c 'chown -R ota2525:users /home/ota2525/dotfiles'
```

## 6. 再起動
```sh
reboot           # USB(sda)を抜く。LUKSパスフレーズ → tuigreet でログイン
```

## 7. インストール後（NixOS側）
- [ ] `~/.ssh` を復元 → `chmod 700 ~/.ssh; chmod 600 ~/.ssh/id_*`
- [ ] mozcユーザー辞書を `~/.config/mozc/` へ復元
- [ ] VM復元: sdb挿入 → `sudo mount /dev/sdb4 /mnt/ssd`
      → イメージを `~/VirtualMachines` へ戻す
      → `sudo virsh define /mnt/ssd/libvirt-config/qemu/<name>.xml` で再登録
- [ ] scholl復元: `git clone git@github.com:Ota26228/scholl ~/scholl`
      → 各プロジェクトで `npm install` / `cargo build` でビルド産物を再生成
- [ ] 動作確認: 日本語入力(fcitx5-mozc) / mango / waybar / 音(pipewire) / 壁紙

## 設定変更の反映（日常運用）
```sh
sudo nixos-rebuild switch --flake ~/dotfiles#otto
```
