#!/bin/bash

# 一時ファイルのパスを定義
TMP_IMAGE="/tmp/i3lock_bg.png"

# 1. 画面全体をキャプチャし、一時ファイルに保存
scrot "$TMP_IMAGE"

# 2. ぼかし処理
#    非推奨の警告を完全に無視するため、フルパスの /usr/bin/magick を使用
/usr/bin/magick "$TMP_IMAGE" -blur 0x8 "$TMP_IMAGE"

# 3. i3lockを実行
i3lock -i "$TMP_IMAGE"

# 4. スクリプト終了時に一時ファイルを削除
rm "$TMP_IMAGE"
