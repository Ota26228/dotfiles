#!/usr/bin/env sh

# 再生中のプレイヤーがいるか確認
STATUS=$(playerctl metadata --format '{{ status }}' 2>/dev/null | head -n 1)

if [ "$STATUS" = "Playing" ]; then
    ICON="" # 一時停止アイコン (クリックで一時停止)
elif [ "$STATUS" = "Paused" ]; then
    ICON="" # 再生アイコン (クリックで再生)
else
    # プレイヤーがアクティブでない場合は空を返すか、アイコンを非表示にする
    echo ""
    exit 0
fi

ARTIST=$(playerctl metadata artist)
TITLE=$(playerctl metadata title)

# 最終出力: [アイコン] [曲名 - アーティスト名]
echo " $ICON $TITLE       
