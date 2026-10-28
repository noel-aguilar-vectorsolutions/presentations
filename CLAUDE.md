# Presentations repo — conventions

This repo holds HTML presentations, one per subfolder.

## Rules

- **One folder per presentation**, named in kebab-case (e.g. `aws-cost-review`).
  Create it with `./new-presentation.sh <slug> "<Title>"`, which copies `_template/`.
- **`index.html` is self-contained**: inline CSS/JS, no build step. Images and
  data go in the presentation's `assets/` folder and are referenced relatively.
  External libraries (charts, diagrams) only from a CDN with a pinned version.
- **`README.md` in every presentation folder** records what the deck is
  about and **every source used**: URLs, Confluence/Jira links, documents,
  repos, people consulted, and any data files. When you pull in information
  from anywhere, add it to the Sources section in the same change.
- **`slides.md` in every presentation folder** is a plain-Markdown export of
  `index.html`: every slide's text and speaker notes, for reading, reviewing and
  searching. Whenever `index.html` changes, run `./export-markdown.py <slug>` in
  the same change and commit the regenerated `slides.md` with it. Never edit
  `slides.md` by hand; `index.html` is the source of truth.
- **Update the Index table** in the root `README.md` when a presentation is
  added or renamed.
- Don't modify `_template/` while working on a specific presentation. Change it
  only when asked to improve the template itself.

## Slide markup

Each slide is a `<section class="slide">` inside `<main class="deck">`.
Speaker notes go in `<aside class="notes">` inside the slide (hidden on screen
and in print). Utility classes available in the template: `.title-slide`,
`.two-col`, `.muted`, `.big`.
Any `<img>` on a slide can be clicked to show it full size in a dialog; give it
a meaningful `alt`.
