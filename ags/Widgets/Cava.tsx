import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import AstalCava from "gi://AstalCava";

const CHARS = [" ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"];
const BARS = 14;
const FPS = 20;

// Center ♫ in BARS-wide space
const IDLE_TEXT =
  " ".repeat(Math.floor((BARS - 1) / 2)) +
  "♫" +
  " ".repeat(BARS - Math.floor((BARS - 1) / 2) - 1);

function getRunningMonitorSource(): string {
  try {
    const [, out] = GLib.spawn_command_line_sync("pactl list sinks short");
    const text = new TextDecoder().decode(out);
    for (const line of text.split("\n")) {
      if (line.includes("RUNNING")) {
        const name = line.trim().split(/\s+/)[1] || "";
        if (name) return `${name}.monitor`;
      }
    }
  } catch (_) {}
  return "auto";
}

export default function Cava() {
  return (
    <button
      cssClasses={["cava-btn"]}
      valign={Gtk.Align.CENTER}
      tooltipText="Open PulseAudio Volume Control"
      onClicked={() => GLib.spawn_command_line_async("pavucontrol")}
      $={(self) => {
        const label = new Gtk.Label({ label: IDLE_TEXT });
        label.add_css_class("cava-label");
        self.set_child(label);

        try {
          const cava = AstalCava.get_default();
          if (!cava) throw new Error("no cava");

          cava.active = false;
          cava.bars = BARS;
          cava.channels = 1;
          cava.framerate = FPS;
          let currentSource = getRunningMonitorSource();
          (cava as any).source = currentSource;
          cava.active = true;

          const pollTimerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
            const newSource = getRunningMonitorSource();
            if (newSource !== currentSource) {
              currentSource = newSource;
              cava.active = false;
              (cava as any).source = newSource;
              cava.active = true;
            }
            return GLib.SOURCE_CONTINUE;
          });

          const update = () => {
            try {
              const raw = cava.get_values() as unknown as ArrayLike<number>;
              let sum = 0;
              for (let i = 0; i < BARS; i++) sum += raw[i] ?? 0;

              if (sum < 0.01) {
                label.set_label(IDLE_TEXT);
              } else {
                let text = "";
                for (let i = 0; i < BARS; i++) {
                  const v = raw[i] ?? 0;
                  text += CHARS[Math.min(Math.round(v * 8), 8)];
                }
                label.set_label(text);
              }
            } catch (_) {}
          };

          const sigId = cava.connect("notify::values", update);
          const timerId = GLib.timeout_add(
            GLib.PRIORITY_DEFAULT,
            Math.floor(1000 / FPS),
            () => { update(); return GLib.SOURCE_CONTINUE; },
          );

          self.connect("destroy", () => {
            cava.disconnect(sigId);
            GLib.source_remove(timerId);
            GLib.source_remove(pollTimerId);
          });
        } catch (_) {
          label.set_label(IDLE_TEXT);
        }
      }}
    />
  );
}
