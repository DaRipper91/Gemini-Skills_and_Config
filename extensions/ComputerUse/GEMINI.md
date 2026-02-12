Computer Use Extension (Browser Control → Actions → State)

Bring real browser automation into Gemini-CLI with a Playwright-powered MCP server and a focused set of /computeruse:* commands.

This extension lets you:

Initialize a Chromium browser at a known viewport & URL

Act on the page (open URL, click, type, scroll, press keys, drag, run JS*)

Capture state (screenshot + optional “ask Gemini about this image”)

Compose multi-step macros from action arrays

* Some actions are scaffolded (“supported but not implemented in MCP yet”) — you’ll see a friendly warning until you add handlers.

Contents

Commands

Typical Flows

Installation & Setup

How Coordinates Work

Examples

Macro JSON Schema

Troubleshooting

Security Notes

Server Architecture

Roadmap Ideas

Commands

Index & Help

/computeruse — quick help and usage tips

Lifecycle

/computeruse:init — start Playwright, open URL, set viewport

/computeruse:close — close browser & release resources

Page Navigation & Input

/computeruse:open — navigate to URL (uses open_web_browser)

/computeruse:click — click at normalized coords (0..1000 scale)

/computeruse:type — focus → replace → type text (optionally press Enter)

/computeruse:scroll — scroll to vertical percent (0..1000)

/computeruse:press — press a key or chord (e.g., Enter, Meta+L)

/computeruse:js — run a JavaScript snippet (stubbed until implemented)

State & Orchestration

/computeruse:state — screenshot + optional Gemini one-shot on the image

/computeruse:macro — run a JSON array of actions (optional per-step screenshots & prompts)

All commands call your MCP tools: initialize_browser, execute_action, capture_state, close_browser.

Typical Flows
1) One-shot explore + caption

/computeruse:init url="https://example.com" width=1440 height=900

/computeruse:click x=120 y=90

/computeruse:type x=300 y=120 text="kittens" press_enter=true

/computeruse:state prompt="Summarize what this page shows."

2) Navigate + interact + multi-step macro

/computeruse:macro actions='[{"name":"open_web_browser","args":{"url":"https://news.ycombinator.com"},"snapshot":true,"label":"hn"}, {"name":"click_at","args":{"x":520,"y":110},"snapshot":true,"label":"first-link"}]' prompt="What changed between steps?"

3) Clean exit

/computeruse:close

Installation & Setup
Requirements (server side)

python3 (3.9+ recommended)

mcp or fastmcp

playwright + Chromium runtime

pip install playwright pillow fastmcp  # or mcp
playwright install chromium


pillow (for image encoding)

Run the MCP server

Use your provided script (Playwright + FastMCP over stdio). Example:

python3 computer_use_mcp.py


The server logs to stderr only; the stdio channel is reserved for MCP.

Wire into Gemini-CLI

Drop the TOML files for /computeruse, /computeruse:init, /computeruse:open, … into your custom commands folder (same place you keep /screenshare).

If you package as an extension, add/merge entries in your gemini-extension.json so Gemini-CLI registers these commands and the MCP server.
Minimal example snippet (adjust to your structure):

{
  "name": "computer-use",
  "version": "0.1.0",
  "mcpServers": [
    {
      "id": "computer-use",
      "command": "python3",
      "args": ["./computer_use_mcp.py"],
      "transport": "stdio"
    }
  ],
  "commands": [
    {"path": "cu/index.toml"},
    {"path": "cu/init.toml"},
    {"path": "cu/open.toml"},
    {"path": "cu/click.toml"},
    {"path": "cu/type.toml"},
    {"path": "cu/scroll.toml"},
    {"path": "cu/press.toml"},
    {"path": "cu/js.toml"},
    {"path": "cu/state.toml"},
    {"path": "cu/macro.toml"},
    {"path": "cu/close.toml"}
  ]
}


If you prefer a single-file command index, you can inline the prompts and keep a leaner manifest — your call.

How Coordinates Work

Your MCP normalizes UI coordinates to 0..1000 in both axes:

The TOML commands accept x, y in that 0..1000 space

MCP converts with:

pixel_x = int(x / 1000 * screen_width)

pixel_y = int(y / 1000 * screen_height)

This makes your macros viewport-independent. Change viewport in /computeruse:init and keep the same flows.

Examples

Initialize at a URL

/computeruse:init url="https://example.com" width=1440 height=900


Open a page

/computeruse:open url="https://duckduckgo.com"


Search (click + type)

/computeruse:click x=220 y=110
/computeruse:type x=220 y=110 text="playwright keyboard shortcuts" press_enter=true


Scroll halfway

/computeruse:scroll y=500


Press a key

/computeruse:press key="End"


Run JS (stubbed until implemented)

/computeruse:js code="return document.title;"


Screenshot + reason

/computeruse:state prompt="What is the main call to action on this page?"


Macro — open → search → screenshot each step

/computeruse:macro actions='[
  {"name":"open_web_browser","args":{"url":"https://google.com"},"snapshot":true,"label":"home"},
  {"name":"type_text_at","args":{"x":250,"y":120,"text":"best espresso grinder","press_enter":true},"snapshot":true,"label":"results"}
]' prompt="Compare the screenshots and describe what changed."

Macro JSON Schema

Each macro step is:

{
  "name": "<action_name>",
  "args": { /* action-specific args */ },
  "snapshot": true,
  "label": "optional_alias"
}


name: one of the actions your MCP supports (e.g., open_web_browser, click_at, type_text_at, scroll_to_percent, press_key, execute_javascript, drag_and_drop).

args: matches the action you call.

snapshot: if true, we call capture_state after the action.

label: optional; used as the screenshot filename hint (<ts>_<label>.png).

Troubleshooting

“Browser not initialized”
Run /computeruse:init first (or call initialize_browser in another command).

Chromium can’t launch / No display (Linux headless)
Use a virtual display:

sudo apt-get install -y xvfb
xvfb-run -s "-screen 0 1440x900x24" python3 computer_use_mcp.py


Blank pages or CSP errors
Some sites block automation. Try different flows, or ensure you’re not blocking scripts.

“Action supported but not implemented”
Your MCP lists the action in _SUPPORTED_ACTIONS, but the handler isn’t coded yet. Add an _execute_* implementation and wire it in execute_action.

Screenshots not saving
Server writes to /tmp/gemini_computer_use. Confirm permissions and free space.

Security Notes

Actions occur locally via Playwright; nothing is executed remotely by default.

The MCP server avoids arbitrary shell execution.

When you pass screenshots to Gemini (via /computeruse:state or /computeruse:macro), you explicitly do so with gemini -p "@<file> …" in the TOML — transparent by design.

Server Architecture

initialize_browser(url, width, height)
Starts Playwright, launches Chromium (headless=False by default), creates context with viewport & device scale factor, opens a Page.

execute_action(action_name, args)
Dispatches to handlers:

Implemented: open_web_browser, click_at, type_text_at

Scaffolded: scroll_to_percent, enter_text_at, select_option_at, drag_and_drop, press_key, execute_javascript
Returns a compact {"ok": true, "result": {...}} or a friendly warning for stubs.

capture_state(action_name, result_ok, error_msg)
Takes a png screenshot, writes it to /tmp/gemini_computer_use/<ts>_<action>.png, returns path + url.

close_browser()
Closes browser/context; resets internal state.