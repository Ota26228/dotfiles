import GLib from "gi://GLib";
import app from "ags/gtk4/app";
import Gdk from "gi://Gdk?version=4.0";
import { createPoll } from "ags/time";

export default function Clock({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const date = createPoll("", 1000, () =>
    GLib.DateTime.new_now_local().format("%Y-%m-%d") ?? "",
  );
  const time = createPoll("", 1000, () =>
    GLib.DateTime.new_now_local().format("%H:%M:%S") ?? "",
  );

  return (
    <button
      cssClasses={["clock"]}
      onClicked={() => {
        const win = app.get_window(`calendar-popup-${gdkmonitor.connector}`);
        if (win) win.visible = !win.visible;
      }}
    >
      <box spacing={6}>
        <label label={date} cssClasses={["clock-date"]} />
        <label label={time} cssClasses={["clock-time"]} />
      </box>
    </button>
  );
}
