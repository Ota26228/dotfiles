import app from "ags/gtk4/app";
import Astal from "gi://Astal?version=4.0";
import Gdk from "gi://Gdk?version=4.0";
import Gtk from "gi://Gtk?version=4.0";
import GLib from "gi://GLib";
import Gio from "gi://Gio";
import Pango from "gi://Pango";

const MODEL = "qwen2.5-coder:7b";
const OLLAMA_URL = "http://localhost:11434/api/chat";

interface Message {
  role: "user" | "assistant";
  content: string;
}

export default function AISidebar({
  gdkmonitor,
}: {
  gdkmonitor: Gdk.Monitor;
}) {
  let messagesBox!: Gtk.Box;
  let scrollWin!: Gtk.ScrolledWindow;
  let isStreaming = false;
  let chatHistory: Message[] = [];

  // ── Helpers ───────────────────────────────────────────────────────────────

  function scrollToBottom() {
    GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
      const adj = scrollWin.get_vadjustment();
      adj.set_value(adj.get_upper() - adj.get_page_size());
      return GLib.SOURCE_REMOVE;
    });
  }

  function appendUserBubble(text: string) {
    const label = new Gtk.Label({
      wrap: true,
      wrap_mode: Pango.WrapMode.WORD_CHAR,
      xalign: 1,
      selectable: true,
    });
    label.set_text(text);
    label.add_css_class("ai-msg-user-text");

    const bubble = new Gtk.Box();
    bubble.add_css_class("ai-msg-user");
    bubble.append(label);

    const spacer = new Gtk.Box({ hexpand: true });
    const row = new Gtk.Box({ hexpand: true });
    row.append(spacer);
    row.append(bubble);
    messagesBox.append(row);
  }

  function appendAssistBubble(): Gtk.Label {
    const label = new Gtk.Label({
      wrap: true,
      wrap_mode: Pango.WrapMode.WORD_CHAR,
      xalign: 0,
      selectable: true,
    });
    label.set_text("▌");
    label.add_css_class("ai-msg-assist-text");

    const bubble = new Gtk.Box();
    bubble.add_css_class("ai-msg-assist");
    bubble.append(label);

    const spacer = new Gtk.Box({ hexpand: true });
    const row = new Gtk.Box({ hexpand: true });
    row.append(bubble);
    row.append(spacer);
    messagesBox.append(row);
    return label;
  }

  function clearMessages() {
    chatHistory = [];
    let child = messagesBox.get_first_child();
    while (child) {
      const next = child.get_next_sibling();
      messagesBox.remove(child);
      child = next;
    }
  }

  // ── Streaming send ────────────────────────────────────────────────────────

  function sendMessage() {
    if (isStreaming) return;

    const buf = inputView.get_buffer();
    const text = buf
      .get_text(buf.get_start_iter(), buf.get_end_iter(), false)
      .trim();
    if (!text) return;

    isStreaming = true;
    buf.set_text("", -1);

    chatHistory.push({ role: "user", content: text });
    appendUserBubble(text);
    const assistLabel = appendAssistBubble();
    scrollToBottom();

    let accumulated = "";

    try {
      const body = JSON.stringify({
        model: MODEL,
        messages: [...chatHistory],
        stream: true,
      });

      const launcher = new Gio.SubprocessLauncher({
        flags:
          Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_MERGE,
      });
      const proc = launcher.spawnv([
        "curl", "-sN",
        "-X", "POST",
        "-H", "Content-Type: application/json",
        "-d", body,
        OLLAMA_URL,
      ]);

      const pipe = proc.get_stdout_pipe();
      if (!pipe) {
        assistLabel.set_text("Error: no stdout pipe from curl.");
        isStreaming = false;
        return;
      }

      const dataStream = new Gio.DataInputStream({ base_stream: pipe });

      function readLine() {
        dataStream.read_line_async(
          GLib.PRIORITY_DEFAULT,
          null,
          (src, res) => {
            try {
              const [line] = src!.read_line_finish_utf8(res);
              if (line === null) {
                // EOF — streaming complete
                assistLabel.set_text(accumulated || "(no response)");
                chatHistory.push({ role: "assistant", content: accumulated });
                isStreaming = false;
                return;
              }
              if (line.trim()) {
                try {
                  const json = JSON.parse(line);
                  accumulated += json.message?.content ?? "";
                  // show blinking cursor while streaming
                  assistLabel.set_text(accumulated + "▌");
                  scrollToBottom();
                } catch (_) {
                  // skip malformed lines
                }
              }
              readLine();
            } catch (e) {
              console.error("Stream read error:", e);
              assistLabel.set_text("Error reading response.");
              isStreaming = false;
            }
          },
        );
      }
      readLine();
    } catch (e) {
      console.error("Ollama request failed:", e);
      assistLabel.set_text("Error: Could not reach Ollama. Is it running?");
      isStreaming = false;
    }
  }

  // ── Input area (built imperatively — needs EventControllerKey) ───────────

  const inputView = new Gtk.TextView({ wrapMode: Gtk.WrapMode.WORD_CHAR });
  inputView.add_css_class("ai-input");

  const inputKeys = new Gtk.EventControllerKey();
  inputKeys.connect("key-pressed", (_, kv, __, state) => {
    if (
      kv === Gdk.KEY_Return &&
      !(state & Gdk.ModifierType.SHIFT_MASK)
    ) {
      sendMessage();
      return Gdk.EVENT_STOP;
    }
    return Gdk.EVENT_PROPAGATE;
  });
  inputView.add_controller(inputKeys);

  const inputScroll = new Gtk.ScrolledWindow({
    hscrollbarPolicy: Gtk.PolicyType.NEVER,
    vscrollbarPolicy: Gtk.PolicyType.AUTOMATIC,
    hexpand: true,
  });
  inputScroll.add_css_class("ai-input-scroll");
  inputScroll.set_child(inputView);
  inputScroll.set_max_content_height(120);
  inputScroll.set_propagate_natural_height(true);

  const sendBtn = new Gtk.Button();
  sendBtn.set_child(new Gtk.Image({ iconName: "go-up-symbolic" }));
  sendBtn.add_css_class("ai-send-btn");
  sendBtn.connect("clicked", () => sendMessage());

  const inputBar = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 8,
  });
  inputBar.add_css_class("ai-input-bar");
  inputBar.append(inputScroll);
  inputBar.append(sendBtn);

  // ── Window ────────────────────────────────────────────────────────────────

  return (
    <window
      $={(self) => {
        const esc = new Gtk.EventControllerKey();
        esc.connect("key-pressed", (_, kv) => {
          if (kv === Gdk.KEY_Escape) {
            self.hide();
            return Gdk.EVENT_STOP;
          }
          return Gdk.EVENT_PROPAGATE;
        });
        self.add_controller(esc);
      }}
      visible={false}
      namespace="ai-sidebar"
      name={`AISidebar-${gdkmonitor.connector}`}
      gdkmonitor={gdkmonitor}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.BOTTOM
      }
      exclusivity={Astal.Exclusivity.NORMAL}
      application={app}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.ON_DEMAND}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        cssClasses={["ai-sidebar-container"]}
        widthRequest={420}
      >
        {/* ── Header ── */}
        <box cssClasses={["ai-sidebar-header"]} spacing={8}>
          <label
            label="AI Assistant"
            cssClasses={["ai-sidebar-title"]}
            hexpand={true}
            xalign={0}
          />
          <label label={MODEL} cssClasses={["ai-sidebar-model-badge"]} />
          <button
            cssClasses={["ai-clear-btn"]}
            onClicked={clearMessages}
            tooltipText="Clear chat"
          >
            <image iconName="edit-clear-symbolic" />
          </button>
        </box>

        {/* ── Messages (ScrolledWindow built imperatively via $=) ── */}
        <box
          $={(self) => {
            const sw = new Gtk.ScrolledWindow({
              hscrollbarPolicy: Gtk.PolicyType.NEVER,
              vscrollbarPolicy: Gtk.PolicyType.AUTOMATIC,
            });
            sw.add_css_class("ai-scroll");
            sw.set_vexpand(true);
            scrollWin = sw;

            const mb = new Gtk.Box({
              orientation: Gtk.Orientation.VERTICAL,
              spacing: 8,
            });
            mb.add_css_class("ai-messages");
            mb.set_vexpand(true);
            messagesBox = mb;

            sw.set_child(mb);
            (self as Gtk.Box).append(sw);
          }}
          vexpand={true}
        />

        {/* ── Input bar (appended via $=) ── */}
        <box $={(self) => (self as Gtk.Box).append(inputBar)} />
      </box>
    </window>
  );
}
