# Presentations

A collection of HTML presentations, one per subfolder. Each presentation is a
self-contained `index.html` that opens directly in a browser — no build step.

## Structure

```
presentations/
├── README.md              ← this file (index of all presentations)
├── CLAUDE.md              ← conventions for Claude Code sessions
├── new-presentation.sh    ← scaffolds a new presentation from _template/
├── export-markdown.py     ← writes <slug>/slides.md from <slug>/index.html
├── _template/             ← starting point for new presentations
│   ├── index.html
│   ├── README.md
│   └── assets/
└── <presentation-slug>/   ← one folder per presentation
    ├── index.html         ← the slides
    ├── slides.md          ← generated: every slide's text + speaker notes
    ├── README.md          ← summary + sources/references used
    └── assets/            ← images, diagrams, data
```

## Creating a new presentation

```bash
./new-presentation.sh my-topic "My Topic Title"
open my-topic/index.html
```

Then edit `my-topic/index.html` and record every source you use in
`my-topic/README.md`.

## Text export

`slides.md` holds the text of every slide and its speaker notes as plain
Markdown, for reading, reviewing or searching a deck without opening it.
Regenerate it whenever `index.html` changes, and commit both together:

```bash
./export-markdown.py my-topic   # one presentation
./export-markdown.py            # every presentation
```

Don't edit `slides.md` by hand; `index.html` is the source of truth.

## Viewing

Open any `index.html` in a browser.

- **→ / Space / PageDown**: next slide
- **← / PageUp**: previous slide
- **Home / End**: first / last slide
- **F**: toggle fullscreen
- **Print (⌘P)**: one slide per page, so you can save as PDF

## Index

| Presentation | Description | Date |
|---|---|---|
| [Moving to GitHub Actions](github-actions-strategy/) | For dev teams and leads: what changes moving from CircleCI to GitHub Actions: paved road, versioning, release-please, hardening | 2026-10-27 |
