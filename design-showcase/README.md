# ChaiRatio — Daily Ritual approved design

**Daily Ritual was approved as the app’s final design direction on 10 October 2026.** See [the design decision](APPROVED-DESIGN.md) and [the frozen approved prototype](daily-ritual-approved-2026-10-10.html). Other concepts are retained for reference.

Open `index.html` to compare the **same screen across all four concepts**. Its Ratios, Calculator, Methods, Measurements, Recipe details and Cooking buttons update all four previews.

Each direction also has a separate, self-contained HTML page:

- `daily-ritual.html` — the selected editorial design: horizontally paged ratios, paired ingredient cards, a navigation stack and a measurement sheet accessible from every screen.
- `pour-studio.html` — a liquid vessel, a visual batch summary, a control sheet, method tiles and a circular cooking guide.
- `recipe-journal.html` — recipe folios, ruled ingredient lists, a table of contents, margin notes and chapter-style instructions.
- `brew-bench.html` — a calibrated ratio panel, controls-first batch builder, ingredient table, recipe specification grid and cooking timeline.

All four use Daily Ritual's cream, chai and brown palette. Each direction has separate compositions for Ratios, Calculator, Methods, Measurements, Method Details, Cooking Guide and Completion. The three method detail examples bring each gallery to nine screen views.

`clarity.html`, `botanical.html` and `after-hours.html` remain compatible copies of their replacement concepts, so earlier links still open the revised designs.

## Open and edit

The individual HTML pages contain all their own styles, JavaScript and SVG icons. No installation, network, font download or server is required. The comparison index loads the four neighbouring HTML files in iframes, so keep those files together. The device's system fonts and Georgia are used.

Each phone maintains its own session inputs. The main prototype remembers its preferred ratio locally when browser storage is available. Comparison previews start at the same 1:1 ratio for a fair comparison.

To edit shared logic, distinct layouts, or styling, use `src/` and regenerate:

```sh
node design-showcase/build.mjs
```

Optional local preview server:

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory design-showcase
```

## PRD rules

The calculator supports 1–20 whole servings, 150/200/250 mL serving sizes, and five finite water:milk ratios. The yield factor is 1.0, liquid rounding follows the PRD, and glass equivalents round to the nearest quarter of a 200 mL glass. Tea/sugar doses remain unavailable because they have not been validated. Method content and timings are illustrative and require kitchen testing.

## Daily Ritual refinements

- Swipe ratios horizontally, use Left/Right on the focused ratio, or tap a page dot. No up/down arrow controls.
- “Let’s make chai” pushes Calculator. “Methods →” floats at the bottom while calculator content scrolls behind it. Back returns to the previous screen with inputs and scroll position preserved.
- The navigation bar’s `info.circle`-style vector opens “Know your measures” as a sheet. Done, Escape, or a backdrop tap closes it. Background controls are inert while it is open.
- Sizes: Small = 150 mL (default), Medium = 200 mL, Large = 250 mL. The sheet explains all three.
- Tea: Regular / Strong. Sweetness: None / Regular / Sweet.
- The Measurements gallery example shows the modal over Ratios. Other concepts retain their existing navigation and controls.

These HTML refinements follow the latest design feedback where it differs from the original PRD. They do not change the Swift app.
