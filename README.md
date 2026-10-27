# Presentations

A collection of HTML presentations, one per subfolder. Each presentation is a
self-contained `index.html` that opens directly in a browser — no build step.

## Structure

```
presentations/
├── README.md              ← this file (index of all presentations)
├── CLAUDE.md              ← conventions for Claude Code sessions
├── new-presentation.sh    ← scaffolds a new presentation from _template/
├── _template/             ← starting point for new presentations
│   ├── index.html
│   ├── README.md
│   └── assets/
└── <presentation-slug>/   ← one folder per presentation
    ├── index.html         ← the slides
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
| _None yet_ | | |
