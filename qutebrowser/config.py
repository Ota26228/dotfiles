config.load_autoconfig(False)

# =============================================================================
# General
# =============================================================================
c.auto_save.session = True
c.session.lazy_restore = True
c.url.default_page = "https://google.com"
c.url.start_pages = ["https://google.com"]

# =============================================================================
# Search engines
# =============================================================================
c.url.searchengines = {
    "DEFAULT": "https://google.com/?q={}",
    "g": "https://google.com/search?q={}",
    "gh": "https://github.com/search?q={}",
    "w": "https://ja.wikipedia.org/wiki/{}",
}

# =============================================================================
# UI
# =============================================================================
c.fonts.default_family = "monospace"
c.fonts.default_size = "11pt"
c.tabs.position = "top"
c.tabs.show = "multiple"
c.statusbar.show = "always"
c.scrolling.smooth = True

# =============================================================================
# Content
# =============================================================================
c.content.headers.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
c.content.blocking.enabled = True
c.content.blocking.method = "both"
c.content.javascript.enabled = True
c.content.autoplay = False
c.content.cookies.accept = "all"
c.content.geolocation = False
c.content.notifications.enabled = False

# =============================================================================
# Dark mode
# =============================================================================
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True

# =============================================================================
# Keybindings
# =============================================================================
config.bind("J", "tab-prev")
config.bind("K", "tab-next")

config.bind("x", "tab-close")
config.unbind("d")

config.bind(",m", "spawn mpv {url}")
config.bind(",y", "yank")

# config.bind(",p", "spawn --userscript qute-bitwarden")
config.set('qt.args', ['disable-features=VaapiVideoDecoder,VaapiVideoDecodeLinuxGL'])
