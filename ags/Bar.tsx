import app from "ags/gtk4/app";
import Astal from "gi://Astal?version=4.0";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";
import Clock from "./Widgets/Clock";
import Workspaces from "./Widgets/Workspaces";
import Battery from "./Widgets/Battery";
import ActiveWindow from "./Widgets/ActiveWindow";
import Cava from "./Widgets/Cava";

export default function Bar({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      namespace="bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
      cssClasses={["bar"]}
    >
      <centerbox heightRequest={40}>
        <box $type="start" spacing={6} valign={Gtk.Align.CENTER}>
          <button
            cssClasses={["bar-icon-btn"]}
            valign={Gtk.Align.CENTER}
            tooltipText="Launch app"
            onClicked={() => {
              const win = app.get_window("applauncher");
              if (win) win.visible = !win.visible;
            }}
          >
            <image iconName="system-search-symbolic" pixelSize={14} />
          </button>
          <Workspaces />
          <ActiveWindow />
        </box>
        <box $type="center" valign={Gtk.Align.CENTER}>
          <Cava />
        </box>
        <box $type="end" spacing={6} valign={Gtk.Align.CENTER}>
          <Battery />
          <Clock gdkmonitor={gdkmonitor} />
          <button
            cssClasses={["bar-icon-btn"]}
            valign={Gtk.Align.CENTER}
            tooltipText="Controls"
            onClicked={() => {
              const win = app.get_window(`right-sidebar-${gdkmonitor.connector}`);
              if (win) win.visible = !win.visible;
            }}
          >
            <image iconName="open-menu-symbolic" pixelSize={14} />
          </button>
        </box>
      </centerbox>
    </window>
  );
}
