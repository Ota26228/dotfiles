#!/usr/bin/env -S ags run
import app from "ags/gtk4/app";
import GLib from "gi://GLib";
import { createBinding, For, This } from "ags";
import Bar from "./Bar";
import Applauncher from "./Widgets/Applauncher";
import LeftSidebar from "./Widgets/LeftSidebar";
import Notifications from "./Widgets/Notifications";
import CalendarPopup from "./Widgets/CalendarPopup";

app.start({
  instanceName: "mybar",
  css: `${GLib.get_user_config_dir()}/ags/style.css`,
  requestHandler(argv, res) {
    if (argv[0] === "launcher") {
      const win = app.get_window("applauncher");
      if (win) { win.visible = !win.visible; return res("ok"); }
    }
    if (argv[0] === "sidebar") {
      const monitors = app.get_monitors();
      if (monitors.length > 0) {
        const win = app.get_window(`right-sidebar-${monitors[0].connector}`);
        if (win) { win.visible = !win.visible; return res("ok"); }
      }
    }
    return res("unknown command");
  },
  main() {
    const launcher = Applauncher();
    app.add_window(launcher as any);

    const monitors = createBinding(app, "monitors");
    return (
      <For each={monitors}>
        {(m) => (
          <This this={app}>
            <Bar gdkmonitor={m} />
            <LeftSidebar gdkmonitor={m} />
            <Notifications gdkmonitor={m} />
            <CalendarPopup gdkmonitor={m} />
          </This>
        )}
      </For>
    );
  },
});
