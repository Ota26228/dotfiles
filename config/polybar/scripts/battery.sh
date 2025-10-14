#!/usr/bin/env sh
BATTERY_PATH="/org/freedesktop/UPower/devices/battery_BAT1"

# UPowerコマンドで残量とステータスを取得
# ↓↓↓ awkの後に 'tr -d '\n' | tr -d ' ' ' を追加して、改行とスペースを除去 ↓↓↓
CAPACITY=$(upower -i "$BATTERY_PATH" | grep 'percentage' | awk '{print $2}' | tr -d '%' | tr -d '\n' | tr -d ' ')
STATE=$(upower -i "$BATTERY_PATH" | grep 'state' | awk '{print $2}' | tr -d '\n' | tr -d ' ')

ICON=""
# ステータスと残量に基づきアイコンを選択 (Nerd Fonts)
if [ "$STATE" = "charging" ]; then
  ICON="" # ← チートシートから新しい稲妻をペースト
elif [ "$STATE" = "fully-charged" ]; then
  ICON="" # ← チートシートから新しい満充電をペースト
else
  # 放電中/残量に基づくアイコン
  if [ "$CAPACITY" -ge 90 ]; then
    ICON="" # 90-100%
  elif [ "$CAPACITY" -ge 70 ]; then
    ICON="" # 70-89%
  elif [ "$CAPACITY" -ge 40 ]; then
    ICON="" # 40-69%
  elif [ "$CAPACITY" -ge 15 ]; then
    ICON="" # 15-39%
  else
    ICON="" # 0-14% (低残量)
  fi
fi

# 最終的な出力: アイコン + 残量(%)
echo "$ICON $CAPACITY%"
