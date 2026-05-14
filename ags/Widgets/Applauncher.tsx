import app from "ags/gtk4/app";
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import Gdk from "gi://Gdk?version=4.0";
import Astal from "gi://Astal?version=4.0";

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

export default function Applauncher() {
  const allApps = Gio.AppInfo.get_all().filter((a) => a.should_show());
  let searchEntry!: Gtk.Entry;
  let appList!: Gtk.Box;

  const close = () => app.get_window("applauncher")?.hide();

  const showApps = (query: string) => {
    let child = appList.get_first_child();
    while (child) {
      const next = child.get_next_sibling();
      appList.remove(child);
      child = next;
    }

    allApps
      .filter((a) =>
        a.get_display_name().toLowerCase().includes(query.toLowerCase()),
      )
      .slice(0, 8)
      .forEach((appInfo) => {
        const btn = new Gtk.Button({ css_classes: ["app-item"] });
        const row = new Gtk.Box({ spacing: 12 });

        const gicon = appInfo.get_icon();
        if (gicon) {
          const icon = Gtk.Image.new_from_gicon(gicon);
          icon.set_pixel_size(32);
          row.append(icon);
        }

        const label = new Gtk.Label({
          label: appInfo.get_display_name(),
          xalign: 0,
          hexpand: true,
        });
        row.append(label);

        btn.set_child(row);
        btn.connect("clicked", () => {
          const desktopInfo = appInfo as Gio.DesktopAppInfo;
          if (desktopInfo.get_boolean("Terminal")) {
            const exec = (desktopInfo.get_string("Exec") ?? "")
              .replace(/%[uUfFdDnNickvm]/g, "")
              .trim();
            GLib.spawn_command_line_async(`alacritty -e ${exec}`);
          } else {
            appInfo.launch([], null);
          }
          close();
        });
        appList.append(btn);
      });
  };

  return (
    <window
      name="applauncher"
      application={app}
      visible={false}
      namespace="launcher"
      anchor={TOP | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self) => {
        self.connect("show", () => {
          searchEntry?.set_text("");
          searchEntry?.grab_focus();
          showApps("");
        });
        const esc = new Gtk.EventControllerKey();
        esc.connect("key-pressed", (_, kv) => {
          if (kv === Gdk.KEY_Escape) {
            self.hide();
            return true;
          }
          return false;
        });
        self.add_controller(esc);
      }}
    >
      <box halign={Gtk.Align.START} marginStart={8}>
        <box
          orientation={Gtk.Orientation.VERTICAL}
          spacing={8}
          cssClasses={["launcher-content"]}
        >
          <entry
            $={(self) => {
              searchEntry = self;
              self.connect("changed", () => showApps(self.get_text()));
            }}
            cssClasses={["launcher-search"]}
            placeholder_text="Search..."
          />
          <box
            $={(self) => {
              appList = self;
              showApps("");
            }}
            orientation={Gtk.Orientation.VERTICAL}
          />
        </box>
      </box>
    </window>
  );
}
