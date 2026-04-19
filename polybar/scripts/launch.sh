#!/usr/bin/env bash
~/.config/polybar/scripts/cava_writer.sh &
killall -q polybar
polybar &
