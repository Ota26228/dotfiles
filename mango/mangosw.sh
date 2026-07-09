#!/usr/bin/env bash

MAGICK="/nix/store/vwalk1kcnb5mr5c5c8100a96r9kgq4g2-imagemagick-7.1.2-23/bin/magick"
THUMB_DIR="/tmp/mangosw"
THEME="$HOME/dotfiles/mango/mangosw.rasi"
ENTRIES_FILE="$THUMB_DIR/entries"
IDS_FILE="$THUMB_DIR/ids"

mkdir -p "$THUMB_DIR"
> "$ENTRIES_FILE"
> "$IDS_FILE"

CLIENTS=$(mmsg get all-clients)

# サムネイル生成 + エントリ・IDファイル作成
echo "$CLIENTS" | jq -r '.clients[] | "\(.id)\t\(.appid)\t\(.title)\t\(.x)\t\(.y)\t\(.width)\t\(.height)"' | \
while IFS=$'\t' read -r id appid title x y w h; do
    thumb="$THUMB_DIR/${id}.png"
    label="${appid}: ${title}"

    grim -g "${x},${y} ${w}x${h}" - 2>/dev/null | \
        "$MAGICK" - -resize 240x135^ -gravity center -extent 240x135 "$thumb" 2>/dev/null

    if [[ -f "$thumb" ]]; then
        printf '%s\0icon\x1f%s\n' "$label" "$thumb" >> "$ENTRIES_FILE"
    else
        printf '%s\n' "$label" >> "$ENTRIES_FILE"
    fi
    echo "$id" >> "$IDS_FILE"
done

# フォーカス中のウィンドウの次を初期選択
FOCUSED_ID=$(echo "$CLIENTS" | jq -r '.clients[] | select(.is_focused == true) | .id')
COUNT=$(echo "$CLIENTS" | jq '.clients | length')
SELECTED_ROW=0
if [[ -n "$FOCUSED_ID" && "$COUNT" -gt 1 ]]; then
    IDX=$(echo "$CLIENTS" | jq -r '[.clients[].id] | index('"$FOCUSED_ID"')')
    SELECTED_ROW=$(( (IDX + 1) % COUNT ))
fi

# rofi 表示 (-format i でインデックスを取得)
SELECTED_IDX=$(rofi \
    -dmenu \
    -show-icons \
    -i \
    -p "" \
    -theme "$THEME" \
    -selected-row "$SELECTED_ROW" \
    -format 'i' \
    -no-custom \
    < "$ENTRIES_FILE")

echo "SELECTED_IDX='$SELECTED_IDX'" >> /tmp/mangosw.log
echo "IDS_FILE:" >> /tmp/mangosw.log
cat "$IDS_FILE" >> /tmp/mangosw.log

if [[ -n "$SELECTED_IDX" ]]; then
    SELECTED_ID=$(sed -n "$((SELECTED_IDX + 1))p" "$IDS_FILE")
    echo "SELECTED_ID='$SELECTED_ID'" >> /tmp/mangosw.log
    [[ -n "$SELECTED_ID" ]] && mmsg dispatch "focusid,$SELECTED_ID" >> /tmp/mangosw.log 2>&1
fi

rm -rf "$THUMB_DIR"
