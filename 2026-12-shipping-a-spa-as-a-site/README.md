# Shipping a SPA as a site

**Created:** 2026-11-17
**Audience:** product dev teams and leads who build SPAs and MFE host shells, plus DevOps engineers. They know CI/CD, ArgoCD and AWS; they don't yet know `modules/site`, the `site-release` chart, KeyValueStore routing or the new names
**Status:** Draft, for the presenter's review. Built 2026-11-17 with content as of that date; to be presented in December 2026. Not yet rehearsed; the status slide (21) must be re-checked before presenting
**Design:** [`docs/superpowers/specs/2026-11-17-shipping-a-spa-as-a-site-design.md`](../docs/superpowers/specs/2026-11-17-shipping-a-spa-as-a-site-design.md)

## Summary

How SPAs and MFE host shells are now delivered as **sites**: a CloudFront distribution, an S3 bucket and a
viewer-request function, created by `modules/site` for one app in one environment. It covers the four phases in
order (infrastructure → app repository → CI → CD), what each produces and who owns it, and the two release
methods, **in-place** and **versioned**: what a release does, how a request is served, how they differ and which
to choose (once per site). SDS is the worked example for in-place and mfe-example for versioned. It ends with
rollback and failed releases, test environments as alias hosts, an API through the site, the top gotchas, what's
ready versus being finalized, and independently released MFEs on the shared CDN as *coming*.

Press **N** while presenting to show the speaker notes, each with a time estimate.

## Running time

Estimates from the speaker notes. The target is 45 minutes, including questions.

| Section | Slides | ~Min |
|---|---|---:|
| Opening: title, what you'll leave with | 1–2 | 1.5 |
| What a site is: the definition, the names | 3–4 | 3.5 |
| The four phases: the flow, who does what | 5–6 | 3.5 |
| Two methods: what a release does, how a request is served, side by side, which to choose | 7–10 | 7 |
| Phase by phase: infrastructure, app repository, CI, CD | 11–14 | 9 |
| Demo: roll back, then forward, on mfe-example develop (slide 16 is the backup, used only if the demo fails) | 15–16 | 5 |
| After the first release: rollback and failures, test environments, an API through the site, gotchas | 17–20 | 5.5 |
| Where things stand: status and where to look; MFEs on the shared CDN (coming) | 21–22 | 3 |
| Questions | 23 | 7 |
| **Total** | | **45** |

## Before presenting

- **Re-check the status slide (21)** and its speaker notes. As of 2026-11-17: `modules/site` v1.1.0 (versioned)
  was on branch `feat/COREOPS-4536-site-versioned-routing` with no PR or tag; the how-to was a draft; the site-unit
  how-to (infrastructure-standards#39) was open; the nonprod certificate had no `*.test1-3` names. Anything merged
  since moves from "being finalized" to "available"; slides 9, 11 and 18 mention the same items.
- **Demo prerequisite:** a release newer than 1.9.0 live on mfe-example develop (any merge to mfe-example `main`
  auto-deploys one). 1.9.0 is the first release that shows its version in the footer.
- **Backup slide (16):** replace the two placeholders with screenshots from the rehearsal (the promotion in the
  Promotion Manager, the Argo app and its Job).

## Diagrams

The seven diagrams were made with [archify](https://github.com/tt-a1i/archify) (3.2.0) from the how-to's
Mermaid diagrams, every label checked against the how-to. Each passed archify's `finalize` gates (validate,
deliver, check, browser-check) and was exported with the viewer's own **SVG · Light** and **SVG · Dark** export.
The export is post-processed: the background and grid are removed so the slide shows through, the canvas is
cropped to the drawing, and the font's code ligatures are turned off (they joined `<app>-site` into one glyph).
Slides embed them with `<picture>`, so the dark variant follows `prefers-color-scheme`; print uses the light one.

| Diagram | Slide | Source |
|---|---|---|
| `four-phases` | 5 | how-to, "The four phases" and "Who does what" |
| `release` | 7 | how-to, "What a release does" |
| `request` | 8 | how-to, "How a request is served" |
| `site-unit` | 11 | how-to, step 2 ("What it creates") |
| `ci` | 13 | how-to, step 5 |
| `cd` | 14 | how-to, phase 4 |
| `alias-hosts` | 18 | how-to, "Optional: test environments"; strategy §4.4.3 (illustrative: not set up yet) |

To rebuild one, from the repo root (needs Node 18+, Google Chrome and the archify skill):

```bash
A=~/.claude/skills/archify/bin/archify.mjs
D=2026-12-shipping-a-spa-as-a-site/assets/diagrams
node $A finalize workflow $D/src/release.candidate.json tmp/archify/release.html --quality showcase --json
node $D/src/export-svg.mjs tmp/archify/release.html $D release   # writes release-light.svg, release-dark.svg
```

Use `architecture` instead of `workflow` for `request`, `site-unit` and `alias-hosts`. The archify HTML goes to
`tmp/` (not committed, about 800 KB each); the candidates in `assets/diagrams/src/` are the sources.

## Sources

Every source of information used in this presentation goes here.

### Documents & links
- `~/workspaces/cowork/site-platform-strategy/deployment/docs/how-to-deliver-a-spa-as-a-site.md` (draft, read
  2026-11-17): the deck's spine. The four phases and what flows between them; who does what; the names; the
  differences that matter, what a release does, how a request is served, the side-by-side table and which to
  choose; every step's details (build contract, values blocks, CI, ApplicationSet `retry.limit: 2` and its
  rationale, the promotion config, the first promotion); rollback, failed releases, retention; the optional API
  and test-environment sections; the troubleshooting rows on slide 20; the Job log lines on slide 16 (release
  1.5.0, 2026-11-11). Its seven Mermaid diagrams are the specs for the archify diagrams
- `~/workspaces/cowork/site-platform-strategy/site-hosting-strategy.md`: §4.0 vocabulary and naming (slides 3–4),
  §4.1–4.2 the two tiers and the MFE rule (slides 3 and 22), §4.4.3 test environments as alias hosts (slide 18),
  §4.5 ownership, §4.9 what is Terraform, GitOps and runtime (slides 6 and 11)
- `~/workspaces/cowork/site-platform-strategy/proposed-standards.md`: 7.6 retention (at least 10 non-live
  versions, never a live one, deletion off by default), 7.12 the Job never retries itself (`backoffLimit: 0`),
  7.13 pin `site-release` exactly (mfe-example 1.4.0 failed to render with a range), §8 MFEs on the shared CDN
  (slide 22; all proposed)
- `~/workspaces/cowork/site-platform-strategy/TRACKER.md`, session log to 2026-11-16: the status on slide 21,
  1.8.0 going live through the KeyValueStore, the bucket clean-up, the nonprod certificate's `*.develop` and
  `*.staging` names only
- Archify diagrams in `~/workspaces/cowork/site-platform-strategy/diagrams/archify/` (2026-11-06): `site-topology`,
  `site-request`, `site-publish`, `site-alias`. Read as references only: they predate the in-place/versioned split
  and are tall sequence or two-account diagrams that don't fit a slide, so the deck's diagrams are new candidates
  (see Diagrams). Labels such as `host_mode = site` were not reused

### Internal (Confluence / Jira / repos)
- [COREOPS-4535](https://lmsportal.atlassian.net/browse/COREOPS-4535) (epic) and
  [COREOPS-4536](https://lmsportal.atlassian.net/browse/COREOPS-4536) (story, versioned sites): cited on slide 21
- vector-shared-terraform-modules `modules/site`: tag `site-v1.0.0` (in-place, merged 2026-11-16, #42); branch
  `feat/COREOPS-4536-site-versioned-routing` at `6b60d6c` (v1.1.0, no PR or tag on 2026-11-17): `variables.tf`
  (`routing` required with no default, switching not supported; `retention` with `keep` at least 10 and
  `delete_enabled` false by default), `functions/viewer-request-in-place.js` and `viewer-request-versioned.js`
- vector-shared-helm-charts `charts/site-release/README.md` on `main`; tags `site-release@v0.2.0` to `@v0.3.1`:
  exactly one of `site:` and `inPlace:`, pin an exact version
- mfe-example `main` at `51f4c18`: `helm/mfe-example` (`Chart.yaml` 0.4.0 on `site-release` 0.3.1, `values.yaml`,
  `envs/values-develop.yaml`, slide 12), `Dockerfile` (busybox 1.38.0 pinned by digest), `.github/workflows/ci.yml`
  (skip a version already in ECR, `RELEASE_VERSION`, the entry-file check), `projects/shell/webpack.config.js`
  (`RELEASE_VERSION`, the footer's `<meta name="release-version">`); PRs #39 and #40 (merged 2026-11-17)
- terragrunt-demo-infrastructure `application/mfe-example-site` (PR #19, open on 2026-11-17): the names on slide 4
- SDS, the in-place example: sds-infrastructure `application/sds-site` (`unit_tf/main.tf`: `modules/site`
  `site-v1.0.0`, `routing = "in-place"`; `environments/test1/terragrunt.hcl`: hostnames, `/api` and `/admin`;
  PRs #4 and #6, merged), and sds `main` at `1a81853`: `src/helm/sds-site` (`Chart.yaml` on `site-release`
  0.3.0, `values.yaml`, `envs/values-test1.yaml`, slide 12; the image tag comment on slide 13) and
  `.github/workflows/ci.yml`
- infrastructure-standards#39 (*Create a site unit*, open on 2026-11-17): linked from slides 11 and 21
- PR and tag states checked with `gh` and `git` on 2026-11-17

### Review
- `tmp/2026-12-shipping-a-spa-as-a-site-review.md` (not committed), 2026-11-17: repetition, cuts, order and
  jargon, per the presentation guide. Nothing to cut; slide 19 is the first to go if the demo runs long

### People consulted
- Noel Aguilar, DevOps (presenter), 2026-11-17: audience, 45 minutes, December 2026; one "coming next" slide
  for MFEs on the shared CDN; a live roll back and forward demo on mfe-example develop; a few short snippets
  only; rollback and failures, test environments, the API and gotchas included; teams start themselves in their
  own infrastructure repo; SDS for in-place and mfe-example for versioned; keystone-cx-tools left out

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background, taken unchanged from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx`
- `assets/vector-logo.png` and `assets/vector-logo-white.png`: the Vector Solutions logos, taken unchanged from `vector-template.pptx` (`ppt/media/image2.png` and `image7.png`). The white one is used on brand slides and in dark mode
- `assets/diagrams/*-light.svg`, `*-dark.svg`: exported from the archify candidates in `assets/diagrams/src/`
  (see Diagrams), 2026-11-17
- `assets/demo-mfe-example-1.9.0.png`: headless Chrome screenshot of https://mfe-example.develop.vsp-nonprod.com/
  on 2026-11-17 at 2× pixel density, cropped to the end of the Getting started card and the "Version 1.9.0" line under it (slide 16)
- Live checks on 2026-11-17: mfe-example develop served 1.9.0 (`<meta name="release-version" content="1.9.0">`);
  https://test1.vectorsds-nonprod.com/ served 200 and `/config.json` from S3 with `no-cache`

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors, the rounded-diamond outline motif and the title background
- `~/OneDrive - Vector Solutions/Documents/presentations/vector-template.pptx` (Vector Solutions PowerPoint template): the footer on its slide master (logo, then the strip's gradient `#96D448` → `#293D9A` → `#5AB7E6`)

## Notes

- Diagram text is smaller than slide text: at 1600×900, node labels are about 16px and edge labels about 11px.
  The diagrams are kept within the guide's 46% height limit; click one to see it full screen.
- The how-to says "vs-skills and SDS" are the in-place reference apps; the deck quotes SDS's real values and
  mentions vs-skills only where the how-to does.
- The site-unit names for SDS differ from the pattern (its only site, so app = product, and a product domain);
  the speaker notes on slide 4 say so.
