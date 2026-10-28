# Presentation guide

How a deck in this repo is planned, built, reviewed and checked, and the design every
deck shares. It's what worked on [Moving to GitHub Actions](../moving-to-github-actions/);
that deck is the reference example for everything below.

The repo's rules (folder layout, `README.md` sources, `slides.md` export) are in
[`CLAUDE.md`](../CLAUDE.md). This guide doesn't repeat them.

## Process

### 1. Plan: write a design spec

Before any slides, write `docs/superpowers/specs/YYYY-MM-DD-<slug>-design.md`
([example](superpowers/specs/2026-10-27-moving-to-github-actions-design.md)). Sections:

| Section | What it settles |
|---|---|
| Intent | What the deck is for, and its tone (inform, sell, decide) |
| Audience | Who's in the room, what they already know, what they care about |
| Goals | What someone should know or do afterwards, numbered |
| Non-goals | What the deck deliberately doesn't cover |
| Anti-goals | What would make it a failure even if accurate (e.g. reads like a standards doc, invents figures) |
| Constraints | Total time including Q&A; the date the content must be accurate as of |
| Structure and timing | One row per section with its minutes; these add up to the total |
| Content by section | The points each section makes |
| Left to the builder | Visual design, wording, diagrams, demo fallbacks |
| Sources | Everything the content comes from |
| Open questions | Anything only the presenter can answer |

### 2. Scaffold

```bash
./new-presentation.sh <slug> "<Title>"
```

Then fill in the deck README's header (audience, status), and add the deck to the Index
table in the root `README.md`.

### 3. Build

- **Speaker notes on every slide**, starting with a time estimate: `⏱ 1.5 min.` Then the
  talking points, and click-by-click steps on demo slides.
- **Running-time table** in the deck README: slides and minutes per section, with a total.
  For a 60-minute session, aim for about 30 slides (about 2 minutes each, more for demos).
- **Record every source as you use it**, in the deck README, in the same change.
- **Don't invent figures.** If something isn't confirmed, say "being finalized" on the slide
  and note why in the speaker notes.
- **Every live demo gets a backup slide** with screenshots, so a failed demo doesn't stall the
  session.
- Keep CSS that only this deck needs at the end of its `<style>`, under
  `/* Additions for this deck */`, so it's easy to tell apart from the template.

### 4. Review

Write a review to `tmp/<slug>-review.md` (`tmp/` isn't committed). Read every slide and
its notes, add up the ⏱ values against the target, and cover:

1. **Repetition**: the same point made on more than one slide. Pick the slide that owns it
   and cut it from the others.
2. **Drop or combine**: slides that could go, or merge, to hit the time.
3. **Order**: does each slide build on the one before?
4. **Anything that would trip up the audience**: jargon, unexplained acronyms, claims that
   need a source.

Apply what you agree with, and note the review in the deck README's sources.

### 5. Check

```bash
./check-presentation.sh <slug>              # 1600x900 (16:9)
./check-presentation.sh <slug> 1440x900     # a 16:10 laptop
```

It writes a screenshot of every slide in light and dark mode, and a PDF, to
`tmp/check/<slug>/`. Look at all of them. Slides cut off anything that doesn't fit, so text
running into the footer or missing at the bottom means the slide needs `.dense` or less on it.

### 6. Export and commit

```bash
./export-markdown.py <slug>
```

Commit `index.html` and `slides.md` together. Commit messages are Conventional Commits with
the deck's slug as the scope: `feat(<slug>): add the demo slides`,
`docs(<slug>): update speaker notes`.

### 7. Rehearse

Open `index.html`, press **F** for fullscreen and **N** to show the speaker notes with their
time estimates. Update the ⏱ values and the running-time table with what you actually take.

## Design

### Brand

Decks are Vector Solutions branded. The template sets all of this up; where it came from is
listed in [`_template/README.md`](../_template/README.md).

| Token | Light | Dark | Used for |
|---|---|---|---|
| `--b-deep` | `#1a439b` | | Headings, the end of the brand gradient |
| `--b-mid` / `--b-cyan` / `--b-teal` / `--b-green` | `#2c61ad` / `#2581c4` / `#439ab8` / `#81c089` | | The brand gradient, chart and timeline colours |
| `--fg` | `#26323a` | `#e6edf6` | Body text |
| `--heading` | `--b-deep` | `#a9cdf5` | `h1`, `h2`, table headers |
| `--accent` | `#0076b8` | `#5cb6f2` | `h3`, links, `.kicker` |
| `--muted` | `#5b6670` | `#9fb0c4` | Secondary text |
| `--surface` / `--border` | `#eef4fa` / `#d3e0ee` | `#142a52` / `#26406d` | Cards, code, table headers |
| `--ok` / `--bad` / `--warn` | `#2f8a48` / `#c0392b` / `#c25a1c` | `#7ccb8a` / `#f0716a` / `#f29a5c` | `.yes`, `.no`, `.pill.warn` |
| `--bg` | `#ffffff` | `#0c1a35` | Page background |

Every slide has the footer from the Vector PowerPoint master: the logo bottom left (white in
dark mode), the green-to-blue strip, and the slide counter at the right. The diamond outlines
in the top-right corner are the motif from the brand backgrounds.

Use colours through the tokens, never as hex values in a slide, so dark mode keeps working.

### Screen size

Slides are designed for **16:9** and scale with the window. Body text is
`max(14px, min(2.2vw, 3.9vh))`: at 16:9 the width and height terms are equal, and on any
other shape the smaller one wins, so the slide keeps its proportions instead of overflowing.

| Screen | Body text |
|---|---|
| 1920×1080 (projector, external monitor) | 42px |
| 1600×900 (what `check-presentation.sh` uses) | 35px |
| 1440×900 (16:10 laptop) | 32px |
| 1280×720 | 28px |
| Print / PDF (1280×720 pages) | 26px, fixed |
| Phone (≤ 700px wide) | 18px, columns stack |

### Type scale

Sizes are relative to the body text, so they scale with it. **Don't go below `.55em`**; it's
already small at the back of a room.

| Element | Size |
|---|---|
| Title-slide `h1` | 3em |
| `h1` | 2.4em |
| `h2` (slide title), `.big` | 1.6em |
| `h3` (card and column headings) | 1.1em |
| Body text, `li` | 1em |
| `code` | .85em |
| `pre` | .7em |
| `.dense` (tables, busy slides) | .62em |
| `.kicker`, `.pill` | .55em |

### Layout

- Slide padding is 6vh top, 8vw sides and 11vh bottom (clear of the footer).
- Paragraphs and list items are at most 60 characters wide; `.dense` lifts that limit.
- Images are at most 60% of the screen's height, and diagrams 46%. Click an image to see
  it full size.
- One idea per slide: a `.kicker` naming the section, an `h2` that says the point, then the
  content.

### Components

All in the template. See the GitHub Actions deck for each one in use.

| Markup | What it's for |
|---|---|
| `.slide.title-slide.brand.photo` | Title and Questions slides: the brand photo background, white text |
| `.slide.brand` | Section openers or a key message: brand gradient, white text |
| `<p class="kicker">` | Small all-caps line above the slide title, naming the section |
| `.two-col` | Two columns, e.g. before and after |
| `.cards` / `.cards.two` > `.card` | Three (or two) boxes side by side; start one with `<span class="num">1</span>` for a numbered list |
| `<p class="callout">` | The one line to remember from a slide |
| `.dense` | Smaller text, for a table or a busy slide |
| `<table>` with `<thead>` | Comparisons; wrap in `.dense` |
| `.pill` / `.pill.warn` | A small label, e.g. "proposed" |
| `.yes` / `.no` | ✓ / ✗ in tables |
| `.muted` / `.big` | Secondary text / a large statement |
| `<svg class="diagram">` with `dg-*` classes | Inline diagrams that follow dark mode: `dg-box`, `dg-text`, `dg-small`, `dg-mono`, `dg-line`, `dg-dot`, `dg-zone`, `dg-arrowhead`, each with `.accent` where it applies |
| `<aside class="notes">` | Speaker notes, starting with `⏱ N min.` |
