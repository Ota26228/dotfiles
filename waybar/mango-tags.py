#!/usr/bin/env python3
"""Waybar custom module: Mango tag display via mmsg IPC."""
import json
import subprocess
import sys

try:
    result = subprocess.run(
        ["mmsg", "get", "all-monitors"],
        capture_output=True, text=True, timeout=2
    )
    data = json.loads(result.stdout)
except Exception:
    print(json.dumps({"text": ""}))
    sys.exit(0)

monitors = data.get("monitors", [])
if not monitors:
    print(json.dumps({"text": ""}))
    sys.exit(0)

monitor = next((m for m in monitors if m.get("active")), monitors[0])
tags = monitor.get("tags", [])

parts = []
for tag in tags:
    idx = tag["index"]
    is_active    = tag["is_active"]
    is_urgent    = tag["is_urgent"]
    client_count = tag["client_count"]

    if is_urgent:
        parts.append(f'<span foreground="#ffb4ab"><b>{idx}</b></span>')
    elif is_active:
        parts.append(f'<span foreground="#11131a" background="#adc6ff"> {idx} </span>')
    elif client_count > 0:
        parts.append(f'<span foreground="#adc6ff">{idx}</span>')
    else:
        parts.append(f'<span foreground="#363940">{idx}</span>')

print(json.dumps({"text": "  ".join(parts)}))
