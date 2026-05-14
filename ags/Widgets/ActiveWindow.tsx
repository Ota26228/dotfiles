import Hyprland from "gi://AstalHyprland";
import Gtk from "gi://Gtk?version=4.0";
import Pango from "gi://Pango";

export default function ActiveWindow() {
  const hypr = Hyprland.get_default();

  return (
    <label
      cssClasses={["active-window"]}
      maxWidthChars={24}
      ellipsize={Pango.EllipsizeMode.END}
      valign={Gtk.Align.CENTER}
      $={(self) => {
        const update = () => {
          const client = hypr.get_focused_client();
          if (client) {
            self.set_label(client.get_class() || client.get_title() || "");
            self.set_visible(true);
          } else {
            self.set_visible(false);
          }
        };
        const id = hypr.connect("notify::focused-client", update);
        self.connect("destroy", () => hypr.disconnect(id));
        update();
      }}
    />
  );
}
