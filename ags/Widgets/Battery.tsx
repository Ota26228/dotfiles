import AstalBattery from "gi://AstalBattery";
import { createBinding } from "ags";

export default function Battery() {
    const battery = AstalBattery.get_default();

    const percent = createBinding(battery, "percentage")(
        (p) => `${Math.round(p * 100)}%`
    );

    return (
        <box
            cssClasses={["battery"]}
            visible={createBinding(battery, "isPresent")}
            spacing={4}

        >
            <image iconName={createBinding(battery,"iconName")} />
            <label label={percent} />
        </box>
    );
}
