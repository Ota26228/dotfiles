import app from "ags/gtk4/app";
import Astal from "gi://Astal?version=4.0";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";
import GLib from "gi://GLib";
import AstalNotifd from "gi://AstalNotifd";

const { TOP, RIGHT } = Astal.WindowAnchor;

export default function Notifications({ gdkmonitor }: { gdkmonitor: Gdk.Monitor }) {
  const name = `notifications-${gdkmonitor.connector}`;

  return (
    <window
      name={name}
      application={app}
      visible={false}
      namespace="notifications"
      gdkmonitor={gdkmonitor}
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      cssClasses={["notification-window"]}
      marginTop={48}
      marginRight={8}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={8}
        $={(self) => {
          const win = app.get_window(name);
          const notifd = AstalNotifd.get_default();

          const dismiss = (row: Gtk.Box, notif: AstalNotifd.Notification) => {
            try { notif.dismiss(); } catch (_) {}
            self.remove(row);
            if (!self.get_first_child()) win?.hide();
          };

          const id = notifd.connect("notified", (_, nid) => {
            const notif = notifd.get_notification(nid);
            if (!notif) return;

            const row = new Gtk.Box({ spacing: 8, css_classes: ["notif-popup"] });

            const content = new Gtk.Box({
              orientation: Gtk.Orientation.VERTICAL,
              spacing: 2,
              hexpand: true,
            });

            const summary = new Gtk.Label({
              label: notif.summary || "Notification",
              xalign: 0,
              ellipsize: 3,
            });
            summary.add_css_class("notif-summary");
            content.append(summary);

            if (notif.body) {
              const body = new Gtk.Label({ label: notif.body, xalign: 0, wrap: true });
              body.set_ellipsize(3);
              body.add_css_class("notif-body");
              content.append(body);
            }

            const appName = new Gtk.Label({ label: notif.app_name || "", xalign: 0 });
            appName.add_css_class("notif-app");
            content.append(appName);

            const closeBtn = new Gtk.Button({ css_classes: ["notif-close"] });
            closeBtn.set_child(new Gtk.Image({ icon_name: "window-close-symbolic", pixel_size: 12 }));
            closeBtn.connect("clicked", () => dismiss(row, notif));

            row.append(content);
            row.append(closeBtn);
            self.append(row);
            win?.show();

            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
              try { dismiss(row, notif); } catch (_) {}
              return GLib.SOURCE_REMOVE;
            });
          });

          self.connect("destroy", () => notifd.disconnect(id));
        }}
      />
    </window>
  );
}
