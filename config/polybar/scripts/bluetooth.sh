#!/usr/bin/env sh

# Bluetoothの状態 (Powered) を確認
BLUETOOTH_POWERED=$(bluetoothctl show | grep 'Powered:' | awk '{print $2}')

if [ "$BLUETOOTH_POWERED" = "yes" ]; then
  # 接続されているデバイスの数を取得
  CONNECTED_DEVICES=$(bluetoothctl devices Connected | wc -l)

  if [ "$CONNECTED_DEVICES" -gt 0 ]; then
    # 接続済みデバイスがある場合
    echo "  " # 接続済みアイコン
  else
    # 接続済みデバイスがないが、電源はオンの場合
    echo "  " # 有効アイコン
  fi
else
  # Bluetoothの電源がオフの場合 (何も表示しないか、異なるアイコンを表示)
  # 接続できていない状態なので、Polybarモジュール自体を非表示にすることも可能
  exit 0 # スクリプトを終了し、Polybarに何も表示させない
fi
