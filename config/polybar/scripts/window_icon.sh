#!/bin/bash

# Get window class
window_class=$(xdotool getactivewindow getwindowclassname 2>/dev/null)

# Map window class to icon
case "$window_class" in
    *alacritty*|*Alacritty*|*terminal*|*Terminal*)
        icon=" "
        color="#9ece6a"  # green
        ;;
    *firefox*|*Firefox*)
        icon=" "
        color="#ff9e64"  # orange
        ;;
    *chrome*|*Chrome*|*chromium*|*Chromium*)
        icon=" "
        color="#7aa2f7"  # blue
        ;;
    *code*|*Code*|*VSCode*)
        icon=" "
        color="#7aa2f7"  # blue
        ;;
    *vim*|*Vim*|*nvim*|*Neovim*)
        icon=" "
        color="#9ece6a"  # green
        ;;
    *discord*|*Discord*)
        icon="ﭮ "
        color="#7dcfff"  # cyan
        ;;
    *spotify*|*Spotify*)
        icon=" "
        color="#9ece6a"  # green
        ;;
    *thunar*|*Thunar*|*nautilus*|*Nautilus*|*dolphin*|*Dolphin*)
        icon=" "
        color="#e0af68"  # yellow
        ;;
    *gimp*|*Gimp*)
        icon=" "
        color="#bb9af7"  # purple
        ;;
    *)
        icon=" "
        color="#C0CAF5"  # default foreground
        ;;
esac

# Get window title (truncated)
title=$(xdotool getactivewindow getwindowname 2>/dev/null | cut -c1-30)

# Output with color
echo "%{F$color}$icon%{F-} $title"
