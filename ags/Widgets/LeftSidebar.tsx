import app from "ags/gtk4/app";
import Astal from "gi://Astal?version=4.0";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";
import GLib from "gi://GLib";
import AstalWp from "gi://AstalWp";
import AstalMpris from "gi://AstalMpris";
import AstalNetwork from "gi://AstalNetwork";
import AstalBluetooth from "gi://AstalBluetooth";
import AstalHyprland from "gi://AstalHyprland";

const { TOP, RIGHT, BOTTOM } = Astal.WindowAnchor;

function SectionHeader(icon: string, title: string): Gtk.Box {
  const box = new Gtk.Box({ spacing: 8 });
  box.append(new Gtk.Image({ icon_name: icon, pixel_size: 16 }));
  const lbl = new Gtk.Label({ label: title, xalign: 0, hexpand: true });
  lbl.add_css_class("sidebar-section-title");
  box.append(lbl);
  return box;
}

function makeSlider(
  min: number,
  max: number,
  getValue: () => number,
  setValue: (v: number) => void,
  onExternalChange: (cb: () => void) => () => void,
): Gtk.Scale {
  const scale = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    draw_value: false,
    hexpand: true,
  });
  scale.set_range(min, max);
  scale.set_value(getValue());

  let programmatic = false;
  scale.connect("value-changed", () => {
    if (!programmatic) setValue(scale.get_value());
  });

  const unsub = onExternalChange(() => {
    const v = getValue();
    if (Math.abs(scale.get_value() - v) > 0.01) {
      programmatic = true;
      scale.set_value(v);
      programmatic = false;
    }
  });
  scale.connect("destroy", unsub);
  return scale;
}

function getActiveSink(): string {
  try {
    const [, out] = GLib.spawn_command_line_sync("pactl list sinks short");
    const text = new TextDecoder().decode(out);
    for (const line of text.split("\n")) {
      if (line.includes("RUNNING")) {
        return line.trim().split(/\s+/)[1] || "@DEFAULT_SINK@";
      }
    }
  } catch (_) {}
  return "@DEFAULT_SINK@";
}

function getSinkVolume(sink: string): number {
  try {
    const [, out] = GLib.spawn_command_line_sync(`pactl get-sink-volume ${sink}`);
    const text = new TextDecoder().decode(out);
    const m = text.match(/(\d+)%/);
    return m ? parseInt(m[1]) / 100 : 0;
  } catch (_) { return 0; }
}

function getSinkMuted(sink: string): boolean {
  try {
    const [, out] = GLib.spawn_command_line_sync(`pactl get-sink-mute ${sink}`);
    return new TextDecoder().decode(out).includes("Mute: yes");
  } catch (_) { return false; }
}

function getSourceMuted(): boolean {
  try {
    const [, out] = GLib.spawn_command_line_sync("pactl get-source-mute @DEFAULT_SOURCE@");
    return new TextDecoder().decode(out).includes("Mute: yes");
  } catch (_) { return false; }
}

function buildSimpleSlider(
  initVal: number,
  max: number,
  onSet: (v: number) => void,
  onDestroy?: () => void,
): [Gtk.Scale, Gtk.Label] {
  const valueLabel = new Gtk.Label({ label: `${Math.round(initVal * 100)}%` });
  valueLabel.add_css_class("sidebar-section-value");

  const scale = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    draw_value: false,
    hexpand: true,
  });
  scale.set_range(0, max);
  scale.set_value(initVal);

  scale.connect("value-changed", () => {
    const v = scale.get_value();
    onSet(v);
    valueLabel.set_label(`${Math.round(v * 100)}%`);
  });

  if (onDestroy) scale.connect("destroy", onDestroy);
  return [scale, valueLabel];
}

function VolumeSection(): Gtk.Box {
  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6 });
  box.add_css_class("sidebar-section");

  const sink = getActiveSink();
  const initVol = getSinkVolume(sink);
  let isMuted = getSinkMuted(sink);

  const muteIcon = new Gtk.Image({ pixel_size: 16 });
  muteIcon.set_from_icon_name(isMuted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic");
  const muteBtn = new Gtk.Button({ css_classes: ["sidebar-mute-btn"] });
  muteBtn.set_child(muteIcon);
  muteBtn.connect("clicked", () => {
    GLib.spawn_command_line_async(`/usr/bin/pactl set-sink-mute ${sink} toggle`);
    isMuted = !isMuted;
    muteIcon.set_from_icon_name(isMuted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic");
  });

  const titleLbl = new Gtk.Label({ label: "Volume", xalign: 0, hexpand: true });
  titleLbl.add_css_class("sidebar-section-title");

  const [scale, valueLabel] = buildSimpleSlider(initVol, 1.5, (v) => {
    GLib.spawn_command_line_async(`/usr/bin/pactl set-sink-volume ${sink} ${Math.round(v * 100)}%`);
  });

  const pollId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
    const v = getSinkVolume(sink);
    isMuted = getSinkMuted(sink);
    valueLabel.set_label(`${Math.round(v * 100)}%`);
    muteIcon.set_from_icon_name(isMuted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic");
    return GLib.SOURCE_CONTINUE;
  });
  scale.connect("destroy", () => GLib.source_remove(pollId));

  const header = new Gtk.Box({ spacing: 8 });
  header.append(muteBtn);
  header.append(titleLbl);
  header.append(valueLabel);
  box.append(header);
  box.append(scale);
  return box;
}

function MicSection(): Gtk.Box {
  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6 });
  box.add_css_class("sidebar-section");

  try {
    const wp = AstalWp.get_default();
    const mic = wp?.get_default_microphone();
    if (!mic) throw new Error("no mic");

    let isMuted = getSourceMuted();

    const muteIcon = new Gtk.Image({ pixel_size: 16 });
    muteIcon.set_from_icon_name(isMuted ? "audio-input-microphone-muted-symbolic" : "audio-input-microphone-symbolic");
    const muteBtn = new Gtk.Button({ css_classes: ["sidebar-mute-btn"] });
    muteBtn.set_child(muteIcon);
    muteBtn.connect("clicked", () => {
      GLib.spawn_command_line_async("/usr/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle");
      isMuted = !isMuted;
      muteIcon.set_from_icon_name(isMuted ? "audio-input-microphone-muted-symbolic" : "audio-input-microphone-symbolic");
    });

    const muteNotifyId = mic.connect("notify::mute", () => {
      isMuted = mic.mute as boolean;
      muteIcon.set_from_icon_name(isMuted ? "audio-input-microphone-muted-symbolic" : "audio-input-microphone-symbolic");
    });

    const titleLbl = new Gtk.Label({ label: "Microphone", xalign: 0, hexpand: true });
    titleLbl.add_css_class("sidebar-section-title");

    const initVol = mic.volume as number ?? 0;
    const [scale, valueLabel] = buildSimpleSlider(initVol, 1, (v) => {
      GLib.spawn_command_line_async(`/usr/bin/pactl set-source-volume @DEFAULT_SOURCE@ ${Math.round(v * 100)}%`);
    });

    const notifyId = mic.connect("notify::volume", () => {
      valueLabel.set_label(`${Math.round((mic.volume as number) * 100)}%`);
    });
    scale.connect("destroy", () => {
      mic.disconnect(notifyId);
      mic.disconnect(muteNotifyId);
    });

    const header = new Gtk.Box({ spacing: 8 });
    header.append(muteBtn);
    header.append(titleLbl);
    header.append(valueLabel);
    box.append(header);
    box.append(scale);
  } catch (_) {
    box.append(new Gtk.Label({ label: "Microphone unavailable" }));
  }
  return box;
}

function getBrightnessValue(): number {
  try {
    const [, cur] = GLib.spawn_command_line_sync("brightnessctl get");
    const [, max] = GLib.spawn_command_line_sync("brightnessctl max");
    const c = parseInt(new TextDecoder().decode(cur));
    const m = parseInt(new TextDecoder().decode(max));
    return m > 0 ? c / m : 0;
  } catch (_) { return 0; }
}

function BrightnessSection(): Gtk.Box {
  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6 });
  box.add_css_class("sidebar-section");

  const header = SectionHeader("display-brightness-symbolic", "Brightness");
  const valueLabel = new Gtk.Label({ label: `${Math.round(getBrightnessValue() * 100)}%` });
  valueLabel.add_css_class("sidebar-section-value");
  header.append(valueLabel);

  const slider = makeSlider(
    0, 1,
    getBrightnessValue,
    (v) => {
      GLib.spawn_command_line_async(`brightnessctl set ${Math.round(v * 100)}%`);
      valueLabel.set_label(`${Math.round(v * 100)}%`);
    },
    (_cb) => () => {},
  );

  box.append(header);
  box.append(slider);
  return box;
}

function MusicSection(): Gtk.Box {
  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6 });
  box.add_css_class("sidebar-section");
  box.append(SectionHeader("audio-x-generic-symbolic", "Music"));

  try {
    const mpris = AstalMpris.get_default();

    const titleLabel = new Gtk.Label({ xalign: 0, ellipsize: 3, hexpand: true, label: "No media playing" });
    titleLabel.add_css_class("music-title");
    const artistLabel = new Gtk.Label({ xalign: 0, ellipsize: 3, label: "" });
    artistLabel.add_css_class("music-artist");

    const prev = new Gtk.Button({ css_classes: ["music-btn"], sensitive: false });
    prev.set_child(new Gtk.Image({ icon_name: "media-skip-backward-symbolic", pixel_size: 16 }));

    const ppIcon = new Gtk.Image({ icon_name: "media-playback-start-symbolic", pixel_size: 16 });
    const playPause = new Gtk.Button({ css_classes: ["music-btn"], sensitive: false });
    playPause.set_child(ppIcon);

    const next = new Gtk.Button({ css_classes: ["music-btn"], sensitive: false });
    next.set_child(new Gtk.Image({ icon_name: "media-skip-forward-symbolic", pixel_size: 16 }));

    let currentPlayer: AstalMpris.Player | null = null;
    let playerSigs: number[] = [];
    let prevId = 0, ppId = 0, nextId = 0;

    const clearPlayer = () => {
      if (currentPlayer) {
        playerSigs.forEach((id) => currentPlayer!.disconnect(id));
        playerSigs = [];
      }
      if (prevId) { prev.disconnect(prevId); prevId = 0; }
      if (ppId) { playPause.disconnect(ppId); ppId = 0; }
      if (nextId) { next.disconnect(nextId); nextId = 0; }
      currentPlayer = null;
    };

    const updatePlayer = () => {
      clearPlayer();
      const players = mpris.get_players();
      if (players.length === 0) {
        titleLabel.set_label("No media playing");
        artistLabel.set_label("");
        prev.set_sensitive(false);
        playPause.set_sensitive(false);
        next.set_sensitive(false);
        return;
      }

      const player = players[0];
      currentPlayer = player;

      const updateInfo = () => {
        titleLabel.set_label(player.title || "Unknown");
        artistLabel.set_label(player.artist || "");
        const isPlaying = player.playback_status === AstalMpris.PlaybackStatus.PLAYING;
        ppIcon.set_from_icon_name(
          isPlaying ? "media-playback-pause-symbolic" : "media-playback-start-symbolic",
        );
      };

      playerSigs.push(player.connect("notify::title", updateInfo));
      playerSigs.push(player.connect("notify::artist", updateInfo));
      playerSigs.push(player.connect("notify::playback-status", updateInfo));

      prevId = prev.connect("clicked", () => player.previous());
      ppId = playPause.connect("clicked", () => player.play_pause());
      nextId = next.connect("clicked", () => player.next());

      prev.set_sensitive(true);
      playPause.set_sensitive(true);
      next.set_sensitive(true);
      updateInfo();
    };

    const mprisId = mpris.connect("notify::players", updatePlayer);
    box.connect("destroy", () => { clearPlayer(); mpris.disconnect(mprisId); });
    updatePlayer();

    const info = new Gtk.Box({
      orientation: Gtk.Orientation.VERTICAL,
      spacing: 2,
      css_classes: ["music-info-clickable"],
      cursor: Gdk.Cursor.new_from_name("pointer", null),
    });
    info.append(titleLabel);
    info.append(artistLabel);

    const click = new Gtk.GestureClick();
    click.connect("released", () => {
      try {
        const hypr = AstalHyprland.get_default();
        const spotify = hypr.get_clients().find((c) =>
          c.class.toLowerCase().includes("spotify") ||
          c.title.toLowerCase().includes("spotify"),
        );
        if (spotify) hypr.dispatch("workspace", String(spotify.workspace.id));
      } catch (_) {}
    });
    info.add_controller(click);

    const controls = new Gtk.Box({ spacing: 8, halign: Gtk.Align.CENTER });
    controls.append(prev);
    controls.append(playPause);
    controls.append(next);

    box.append(info);
    box.append(controls);
  } catch (_) {
    box.append(new Gtk.Label({ label: "Music unavailable" }));
  }
  return box;
}

function clearBox(box: Gtk.Box) {
  let child = box.get_first_child();
  while (child) {
    const next = child.get_next_sibling();
    box.remove(child);
    child = next;
  }
}

function strengthBars(pct: number): string {
  if (pct > 75) return "▂▄▆█";
  if (pct > 50) return "▂▄▆ ";
  if (pct > 25) return "▂▄  ";
  return "▂   ";
}

function makeScrollList(maxHeight: number): [Gtk.ScrolledWindow, Gtk.Box] {
  const inner = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 2 });
  const scroll = new Gtk.ScrolledWindow({
    hscrollbar_policy: Gtk.PolicyType.NEVER,
    propagate_natural_height: true,
    max_content_height: maxHeight,
  });
  scroll.set_child(inner);
  return [scroll, inner];
}

function WifiSection(): Gtk.Box {
  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6 });
  box.add_css_class("sidebar-section");

  try {
    const network = AstalNetwork.get_default();
    const wifi = network.get_wifi();
    if (!wifi) throw new Error("no wifi");

    const header = SectionHeader("network-wireless-symbolic", "Wi-Fi");
    const toggle = new Gtk.Switch({ valign: Gtk.Align.CENTER, active: wifi.enabled });
    toggle.connect("notify::active", () => { wifi.enabled = toggle.get_active(); });
    const enabledId = wifi.connect("notify::enabled", () => toggle.set_active(wifi.enabled));
    toggle.connect("destroy", () => wifi.disconnect(enabledId));
    header.append(toggle);
    box.append(header);

    const [scroll, apListBox] = makeScrollList(220);
    let expandedSSID: string | null = null;

    interface APInfo { ssid: string; signal: number; inUse: boolean; needsPw: boolean }

    const getAPsFromNmcli = (): APInfo[] => {
      try {
        const [, listBuf] = GLib.spawn_command_line_sync(
          "nmcli -t --escape no -f IN-USE,SSID,SIGNAL,SECURITY device wifi list",
        );
        const [, conBuf] = GLib.spawn_command_line_sync(
          "nmcli -t --escape no -f NAME,TYPE connection show",
        );
        const listText = new TextDecoder().decode(listBuf);
        const conText = new TextDecoder().decode(conBuf);

        const savedSSIDs = new Set<string>();
        for (const line of conText.trim().split("\n")) {
          if (!line.trim()) continue;
          const parts = line.split(":");
          const type = parts[parts.length - 1];
          const name = parts.slice(0, -1).join(":");
          if (type.includes("wireless") && name.trim()) savedSSIDs.add(name.trim());
        }

        const seen = new Set<string>();
        const aps: APInfo[] = [];
        for (const line of listText.trim().split("\n")) {
          if (!line.trim()) continue;
          const parts = line.split(":");
          if (parts.length < 3) continue;
          const inUse = parts[0].trim() === "*";
          const security = parts[parts.length - 1].trim();
          const signal = parseInt(parts[parts.length - 2]) || 0;
          const ssid = parts.slice(1, -2).join(":").trim();
          if (!ssid || ssid === "--" || seen.has(ssid)) continue;
          seen.add(ssid);
          const saved = savedSSIDs.has(ssid);
          const needsPw = security !== "" && !saved;
          aps.push({ ssid, signal, inUse, needsPw });
        }
        return aps.sort((a, b) => b.signal - a.signal);
      } catch (_) { return []; }
    };

    const buildApList = () => {
      clearBox(apListBox);
      for (const ap of getAPsFromNmcli().slice(0, 20)) {
        const wrapper = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL });

        const row = new Gtk.Button({ css_classes: ap.inUse ? ["ap-item", "ap-active"] : ["ap-item"] });
        const rowBox = new Gtk.Box({ spacing: 6 });
        const ssidLabel = new Gtk.Label({ label: ap.ssid, xalign: 0, hexpand: true, ellipsize: 3 });
        const sigLabel = new Gtk.Label({ label: strengthBars(ap.signal) });
        sigLabel.add_css_class("ap-strength");
        rowBox.append(ssidLabel);
        rowBox.append(sigLabel);
        row.set_child(rowBox);

        const pwRow = new Gtk.Box({
          spacing: 6,
          css_classes: ["ap-pw-row"],
          visible: expandedSSID === ap.ssid,
        });
        const pwEntry = new Gtk.Entry({
          visibility: false,
          input_purpose: Gtk.InputPurpose.PASSWORD,
          placeholder_text: "Password",
          hexpand: true,
        });
        const connectBtn = new Gtk.Button({ css_classes: ["sidebar-section-btn"] });
        connectBtn.set_child(new Gtk.Label({ label: "Connect" }));

        const doConnect = () => {
          const pw = pwEntry.get_text();
          GLib.spawn_command_line_async(
            pw ? `nmcli device wifi connect "${ap.ssid}" password "${pw}"`
               : `nmcli device wifi connect "${ap.ssid}"`,
          );
          pwEntry.set_text("");
          pwRow.visible = false;
          expandedSSID = null;
        };
        pwEntry.connect("activate", doConnect);
        connectBtn.connect("clicked", doConnect);
        pwRow.append(pwEntry);
        pwRow.append(connectBtn);

        row.connect("clicked", () => {
          if (!ap.needsPw) {
            GLib.spawn_command_line_async(`nmcli device wifi connect "${ap.ssid}"`);
          } else {
            const willShow = expandedSSID !== ap.ssid;
            expandedSSID = willShow ? ap.ssid : null;
            pwRow.visible = willShow;
            if (willShow) pwEntry.grab_focus();
          }
        });

        wrapper.append(row);
        if (ap.needsPw) wrapper.append(pwRow);
        apListBox.append(wrapper);
      }
    };

    const apId = wifi.connect("notify::access-points", buildApList);
    apListBox.connect("destroy", () => wifi.disconnect(apId));
    buildApList();
    box.append(scroll);
  } catch (_) {
    box.append(new Gtk.Label({ label: "Wi-Fi unavailable" }));
  }
  return box;
}

function BluetoothSection(): Gtk.Box {
  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 6 });
  box.add_css_class("sidebar-section");

  try {
    const bt = AstalBluetooth.get_default();

    const header = SectionHeader("bluetooth-symbolic", "Bluetooth");
    const toggle = new Gtk.Switch({ valign: Gtk.Align.CENTER, active: bt.is_powered });
    toggle.connect("notify::active", () => {
      if (bt.is_powered !== toggle.get_active()) bt.toggle();
    });
    const powerId = bt.connect("notify::is-powered", () => toggle.set_active(bt.is_powered));
    toggle.connect("destroy", () => bt.disconnect(powerId));
    header.append(toggle);
    box.append(header);

    // Scan button
    const scanBtn = new Gtk.Button({ css_classes: ["sidebar-section-btn"] });
    const scanLabel = new Gtk.Label({ label: "Scan" });
    scanBtn.set_child(scanLabel);
    let scanTimer = 0;

    const stopScan = () => {
      const adapters = bt.get_adapters();
      if (adapters.length > 0) {
        try { adapters[0].stop_discovery(); } catch (_) {}
      }
      scanLabel.set_label("Scan");
      if (scanTimer) { GLib.source_remove(scanTimer); scanTimer = 0; }
    };

    scanBtn.connect("clicked", () => {
      const adapters = bt.get_adapters();
      if (adapters.length === 0) return;
      const adapter = adapters[0];
      if (adapter.discovering) {
        stopScan();
      } else {
        try {
          adapter.start_discovery();
          scanLabel.set_label("Scanning…");
          scanTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 15000, () => {
            stopScan();
            return GLib.SOURCE_REMOVE;
          });
        } catch (_) {}
      }
    });
    box.append(scanBtn);
    box.connect("destroy", () => { if (scanTimer) GLib.source_remove(scanTimer); });

    const [scroll, deviceListBox] = makeScrollList(200);

    const buildDeviceList = () => {
      clearBox(deviceListBox);
      const devices = bt.get_devices();

      if (devices.length === 0) {
        const emptyLabel = new Gtk.Label({ label: "No devices — press Scan" });
        emptyLabel.add_css_class("sidebar-section-value");
        deviceListBox.append(emptyLabel);
        return;
      }

      devices.forEach((device) => {
        const row = new Gtk.Box({ spacing: 6, css_classes: ["bt-device-row"] });
        const nameLabel = new Gtk.Label({
          label: device.name || device.address || "Unknown",
          xalign: 0,
          hexpand: true,
          ellipsize: 3,
        });

        const btn = new Gtk.Button({ css_classes: ["sidebar-section-btn"] });
        const getBtnLabel = () =>
          device.connected ? "Disconnect" : device.paired ? "Connect" : "Pair";
        const btnLabel = new Gtk.Label({ label: getBtnLabel() });
        btn.set_child(btnLabel);

        const connId = device.connect("notify::connected", () => btnLabel.set_label(getBtnLabel()));
        const pairId = device.connect("notify::paired", () => btnLabel.set_label(getBtnLabel()));
        row.connect("destroy", () => {
          device.disconnect(connId);
          device.disconnect(pairId);
        });

        btn.connect("clicked", () => {
          const addr = device.address;
          if (device.connected) {
            GLib.spawn_command_line_async(`bluetoothctl disconnect ${addr}`);
          } else if (device.paired) {
            GLib.spawn_command_line_async(`bluetoothctl connect ${addr}`);
          } else {
            GLib.spawn_command_line_async(`bluetoothctl pair ${addr}`);
          }
        });

        row.append(nameLabel);
        row.append(btn);
        deviceListBox.append(row);
      });
    };

    const devId = bt.connect("notify::devices", buildDeviceList);
    deviceListBox.connect("destroy", () => bt.disconnect(devId));
    buildDeviceList();
    box.append(scroll);
  } catch (_) {
    box.append(new Gtk.Label({ label: "Bluetooth unavailable" }));
  }
  return box;
}

export default function LeftSidebar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const name = `right-sidebar-${gdkmonitor.connector}`;

  return (
    <window
      name={name}
      application={app}
      visible={false}
      namespace="right-sidebar"
      gdkmonitor={gdkmonitor}
      anchor={TOP | RIGHT | BOTTOM}
      exclusivity={Astal.Exclusivity.NORMAL}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self) => {
        const esc = new Gtk.EventControllerKey();
        esc.connect("key-pressed", (_, kv) => {
          if (kv === Gdk.KEY_Escape) { self.hide(); return true; }
          return false;
        });
        self.add_controller(esc);
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["sidebar-container"]}>
        <box cssClasses={["sidebar-header"]} spacing={8}>
          <label label="Controls" cssClasses={["sidebar-title"]} hexpand xalign={0} />
          <button cssClasses={["sidebar-close-btn"]} onClicked={() => app.get_window(name)?.hide()}>
            <image iconName="window-close-symbolic" pixelSize={14} />
          </button>
        </box>
        <scrolledwindow vexpand hscrollbarPolicy={Gtk.PolicyType.NEVER} kineticScrolling={false}>
          <box
            orientation={Gtk.Orientation.VERTICAL}
            spacing={8}
            cssClasses={["sidebar-body"]}
            $={(self) => {
              self.append(VolumeSection());
              self.append(MicSection());
              self.append(BrightnessSection());
              self.append(MusicSection());
              self.append(WifiSection());
              self.append(BluetoothSection());
            }}
          />
        </scrolledwindow>
      </box>
    </window>
  );
}
