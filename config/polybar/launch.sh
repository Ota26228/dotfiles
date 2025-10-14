#:/usr/bin/env bash

# Polybarの起動を確実にするため、少し待機
sleep 1

# 既に起動しているPolybarプロセスをすべて強制終了
killall -q polybar

# Polybarが終了するまで待機
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# ここで設定ファイルから定義されたバー名 (例: example, main) を指定して起動します
# polybarが終了しないようにバックグラウンドで起動
polybar -q top &
polybar -q bottom &
