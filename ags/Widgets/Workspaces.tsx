 import Hyprland from "gi://AstalHyprland";
  import Gtk from "gi://Gtk?version=4.0";

  export default function Workspaces() {
    const hypr = Hyprland.get_default();

    return (
      <box
        cssClasses={["workspaces"]}
        valign={Gtk.Align.CENTER}
        spacing={6}
        $={(self) => {
          for (let i = 1; i <= 5; i++) {
            const dot = new Gtk.Box({
              valign: Gtk.Align.CENTER,
              halign: Gtk.Align.CENTER,
              width_request: 8,
              height_request: 8,
            });
            dot.add_css_class("ws-dot");

            const update = () => {
              const focused = hypr.get_focused_workspace();
              const exists = hypr.get_workspaces().some((ws) => ws.id === i);

              if (focused?.id === i) {
                dot.remove_css_class("ws-used");
                dot.add_css_class("ws-active");
              } else if (exists) {
                dot.remove_css_class("ws-active");
                dot.add_css_class("ws-used");
              } else {
                dot.remove_css_class("ws-active");
                dot.remove_css_class("ws-used");
              }
            };

            const id1 = hypr.connect("notify::focused-workspace", update);
            const id2 = hypr.connect("notify::workspaces", update);
            dot.connect("destroy", () => {
              hypr.disconnect(id1);
              hypr.disconnect(id2);
            });
            update();
            self.append(dot);
          }
        }}
      />
    );
  }
