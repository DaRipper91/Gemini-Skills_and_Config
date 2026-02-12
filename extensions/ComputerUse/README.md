# GeminiCLI_ComputerUse_Extension
A Google Gemini-CLI extension than enables Gemini Computer Use from the CLI

## Installation

gemini extensions install https://github.com/automateyournetwork/GeminiCLI_ComputerUse_Extension.git

### Example Gemini-CLI prompt to VISIBLY browse a web article and produce a Markdown report
Use ComputerUse MCP headfully to VISIBLY browse like a human and produce a final Markdown report.

Goals:
- Read the article at the given URL.
- Scroll like a human (visible motion), taking a snapshot after EACH scroll step.
- Visit all in-article links (avoid mailto/tel/#). Prefer opening in NEW TABS that do not overtake the main article tab. If tab tools are unavailable, open links sequentially and return to the article each time.
- Conclude with a comprehensive Markdown summary (RAFT, retrieval-augmented fine-tuning, key takeaways), citing the pages you visited.

1) initialize_browser(
     url="https://www.automateyournetwork.ca/pyats/augmenting-network-engineering-with-raft/",
     width=1920, height=1080, headless=false)

2) Smoothly scroll the article TOP→BOTTOM with visible pauses. After EACH step, take a snapshot:
   for y in [200, 400, 600, 800, 1000]:
     - execute_action("scroll_to_percent", {"y": y})
     - capture_state(f"scroll_{y}")

3) Return to TOP visibly and snapshot:
   - execute_action("scroll_to_percent", {"y": 0})
   - capture_state("back_to_top")

4) Harvest in-article links (de-dupe, skip mailto/tel/#):
   - execute_action("execute_javascript", {
       "code": "(() => { \
         const scope = document.querySelector('article, main, .post-content, .entry-content') || document.body; \
         const links = Array.from(scope.querySelectorAll('a[href]')); \
         const hrefs = links.map(a => a.href.trim()) \
           .filter(h => h && !h.startsWith('mailto:') && !h.startsWith('tel:') && !h.includes('#')); \
         return Array.from(new Set(hrefs)); \
       })();"
     })

5) Visit each harvested link (limit to 8 to stay readable):
   Preferred (if these tools exist): open_new_tab, list_tabs, switch_to_tab
   - For each <link> (1-based index i):
       - If open_new_tab exists:
           - open_new_tab(url="<link>", focus=true)
           - capture_state(f"link{i}_load")                      # snapshot immediately after load
           - For y in [200, 400, 600, 800, 1000]:
                  execute_action("scroll_to_percent", {"y": y})
                  capture_state(f"link{i}_scroll_{y}")           # snapshot each scroll step
           - switch_to_tab(0)                                   # return to main article tab
       - Else (fallback when tab tools absent):
           - execute_action("open_web_browser", {"url": "<link>"})
           - capture_state(f"link{i}_load")
           - For y in [200, 400, 600, 800, 1000]:
                  execute_action("scroll_to_percent", {"y": y})
                  capture_state(f"link{i}_scroll_{y}")
           - execute_action("open_web_browser", {"url": "https://www.automateyournetwork.ca/pyats/augmenting-network-engineering-with-raft/"})
           - capture_state(f"link{i}_return")                   # confirm we’re back on the main article

6) After links, return to the main article (if not already there) and capture_state("final_overview").

7) Produce a comprehensive Markdown report (no extra screenshots in the report; just text). Structure:
   # RAFT & Retrieval-Augmented Fine-Tuning — Field Notes
   - **Primary article:** title + URL
   - **Other pages visited:** bullet list of titles + URLs
   - **What RAFT is:** 3–6 bullets (your own words)
   - **How RAFT differs from standard fine-tuning:** bullets
   - **Retrieval-Augmented Fine-Tuning pipeline:** concise steps (data prep, retrieval store, adapters/LoRA/full FT, eval)
   - **Cloud vs Local comparison (from the two-part series):** capabilities, privacy, cost, constraints
   - **Implementation notes spotted in pages:** tools, commands, pitfalls
   - **Key takeaways:** 5–8 bullets
   - **References (visited):** list of URLs

Important:
- Keep actions human-visible (no instant jumps).
- If a page won’t load, skip it and continue.
- Take a small pause between scroll steps so motion is obvious.

### Example Searching Wikipedia for "Computer Networking" and producing a Markdown report
#### Wikipedia Exploration: Computer Networks

Headless=false for visible browsing.

You will systematically explore Wikipedia (and optionally Google) articles about computer networks using the ComputerUse MCP tools. Use selectors (not coordinates), add pauses so the typing is obvious, and take screenshots after each major step.

Phase 1: Initialize & Search (Wikipedia)

Initialize headful browser

initialize_browser(url="https://www.wikipedia.org", width=1920, height=1080, headless=false)
capture_state("wikipedia_home")
pause(800)


Search for “Computer Network” with visible typing

fill_selector('input[name="search"]', 'Computer Network', true, true)
pause(800)   # let navigation/rendering be seen
capture_state("wiki_search_results_or_article")


Note: Wikipedia may jump straight to the article. Continue from whatever page loads.

Phase 2: Explore the page/results with smooth pacing

Scroll (top → bottom) with pauses

for y in [200, 400, 600, 800, 1000]:
  execute_action("scroll_to_percent", {"y": y})
  pause(700)
  capture_state(f"wiki_scroll_{y}")


Return to top

execute_action("scroll_to_percent", {"y": 0})
pause(500)
capture_state("wiki_top")

Phase 3: Extract & Visit Links (up to 8)

Extract article links on current page

execute_action("execute_javascript", {
  "code": "(() => {\
    const links = Array.from(document.querySelectorAll('a[href*=\"/wiki/\"]'))\
      .map(a => a.href)\
      .filter(h => h.includes('wikipedia.org/wiki/') && !h.includes('#'))\
      .filter((v, i, a) => a.indexOf(v) === i);\
    return links.slice(0, 8);\
  })()"
})
pause(600)


Visit each link in sequence
For each link i:

execute_action("open_web_browser", {"url": "{{link_i}}"})
pause(900)
capture_state(f"article_{i}_loaded")

for y in [0, 250, 500, 750, 1000]:
  execute_action("scroll_to_percent", {"y": y})
  pause(650)
  capture_state(f"article_{i}_scroll_{y}")

# Go back to the search/article hub if desired:
# execute_action("open_web_browser", {"url": "<the-page-you-extracted-from>"})
# pause(600)

(Optional) Phase 3b: Also show a Google search (for demo effect)
execute_action("open_web_browser", {"url": "https://www.google.com"})
pause(700)
capture_state("google_home")

fill_selector('textarea[name=\"q\"]', 'Computer Network', true, true)
pause(900)
capture_state("google_results_top")

execute_action("scroll_to_percent", {"y": 600})
pause(700)
capture_state("google_results_mid")

Phase 4: Summary Report (after all visits)

After visiting all targets, produce a Markdown summary:

# Wikipedia Exploration Report: Computer Networks

## Search Query
- **Primary Query:** Computer Network
- **Search URL:** [Insert the URL where the search happened]

## Articles Visited (up to 8)
1. [Title 1](URL) — 1–2 sentence summary
2. [Title 2](URL) — 1–2 sentence summary
...

## Key Learnings
- ...
- ...

## Major Subtopics
- **Protocols & Standards:** ...
- **Topology & Architecture:** ...
- **History & Development:** ...
- **Technologies & Components:** ...
- **Related Disciplines:** ...

## All URLs Visited
1. URL
2. URL
...

## Environment Variables

🧩 Recommended ComputerUse MCP Environment Variables

Variable	Purpose	Recommended for Demo	Example

CU_HEADFUL	Launch the browser with a visible window.	✅ Yes	export CU_HEADFUL=1

CU_SLOW_MO	Milliseconds of delay between Playwright actions (move, click, type).	✅ Yes	export CU_SLOW_MO=700

CU_SHOW_CURSOR	Display cyan “cursor ring” overlay to visualize movement.	✅ Yes	export CU_SHOW_CURSOR=true

CU_NO_SANDBOX	Disable Chromium sandbox if Playwright complains (needed in some Docker/macOS setups).	optional	export CU_NO_SANDBOX=1

CU_BROWSER	Force a specific browser (chromium, firefox, webkit) if you installed all.	optional	export CU_BROWSER=chromium

CU_DEVICE_SCALE	Override Retina scaling (use 2 on macOS for pixel-accurate clicks).	optional	export CU_DEVICE_SCALE=2


🧠 Typical macOS Demo Setup

export CU_HEADFUL=1

export CU_SLOW_MO=800

export CU_SHOW_CURSOR=true

export CU_DEVICE_SCALE=2

export CU_NO_SANDBOX=0
