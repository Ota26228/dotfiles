import app from "ags/gtk4/app";
import Astal from "gi://Astal?version=4.0";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";

export default function CalendarPopup({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const { TOP, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      name={`calendar-popup-${gdkmonitor.connector}`}
      application={app}
      visible={false}
      namespace="calendar-popup"
      gdkmonitor={gdkmonitor}
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      marginTop={48}
      marginRight={8}
      $={(self) => {
        const esc = new Gtk.EventControllerKey();
        esc.connect("key-pressed", (_, kv) => {
          if (kv === Gdk.KEY_Escape) { self.hide(); return true; }
          return false;
        });
        self.add_controller(esc);

        const outer = new Gtk.Box();
        outer.add_css_class("calendar-popup");

        const cal = new Gtk.Calendar();
        outer.append(cal);

        self.set_child(outer);
      }}
    />
  );
}
