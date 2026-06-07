#!/bin/sh
# Screen recording toggle for mango (wf-recorder + slurp)
# 1st press: select a region and start recording
# 2nd press: stop and save to ~/Videos/<timestamp>.mp4

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT wf-recorder
    notify-send Recording "Stopped & saved" -i media-record
else
    mkdir -p ~/Videos
    region=$(slurp) || exit 0   # cancelled selection -> do nothing
    notify-send Recording "Started" -i media-record
    wf-recorder -g "$region" -f ~/Videos/"$(date +%Y%m%d_%H%M%S)".mp4
fi
