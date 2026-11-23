# Shipping a SPA as a site

**Created:** 2026-11-17
**Audience:** product dev teams and leads who build SPAs and MFE host shells, plus DevOps engineers. They know CI/CD, ArgoCD and AWS; they don't yet know `modules/site`, `modules/site-function`, the `site-release` chart, KeyValueStore routing or the new names
**Status:** Draft, for the presenter's review. Built 2026-11-17; brought up to date on 2026-11-23 with content as of that date (`modules/site` v2, spa-example); to be presented in December 2026. Not yet rehearsed; the status slide (21) must be re-checked before presenting
**Design:** [`docs/superpowers/specs/2026-11-17-shipping-a-spa-as-a-site-design.md`](../docs/superpowers/specs/2026-11-17-shipping-a-spa-as-a-site-design.md)

## Summary

How SPAs and MFE host shells are now delivered as **sites**: per environment, a CloudFront distribution, an S3
bucket, DNS records and the site's own certificate, created by `modules/site` v2; once per account, the site's
viewer-request function (and, for versioned, its KeyValueStore), created by `modules/site-function` and attached
by every environment's distribution. It covers the four phases in order (infrastructure → app repository → CI →
CD), what each produces and who owns it, and the two release methods, **in-place** and **versioned**: what a
release does, how a request is served, how they differ and which to choose (once per site; versioned is
preferred). spa-example (develop and staging, on v2) is the worked example for versioned and SDS (test1, still
on v1) for in-place. It ends with rollback through the Promotion Manager and failed releases, each environment as
its own distribution on one shared function, an API through the site, the top gotchas, what's ready versus being
finalized or not yet covered, and independently released MFEs on the shared CDN as *coming*.

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
| Demo: promote forward, then roll back, on spa-example staging (slide 16 is the backup, used only if the demo fails) | 15–16 | 5 |
| After the first release: rollback and failures, environments, an API through the site, gotchas | 17–20 | 6 |
| Where things stand: status and where to look; MFEs on the shared CDN (coming) | 21–22 | 3 |
| Questions | 23 | 6.5 |
| **Total** | | **45** |

## Before presenting

- **Re-check the status slide (21)** and its speaker notes. As of 2026-11-23: `site-v2.0.0` and
  `site-function-v1.0.1` tagged; `site-release@v0.4.1` the latest chart; spa-example live on develop (1.0.3) and
  staging (1.0.2); SDS on `site-v1.0.0` until COREOPS-4776, so in-place hasn't run on v2; mfe-example on v1 until
  COREOPS-4759 (its unit on terragrunt-demo-infrastructure#19, open); no test environment or production on v2;
  the how-to waiting for approval, moving to cicd-standards `docs/how-to` (COREOPS-4543); infrastructure-standards
  #39 (*Create a site unit*), #43 (§16 certificates) and #44 (§17 DNS) open. Anything merged or moved since
  changes its row; slides 9, 11 and 18 mention the same items.
- **Demo prerequisite:** spa-example staging serves an older release than one already in its bucket, with develop
  on a different one, so the demo shows only staging's key moving. On 2026-11-23: staging 1.0.2, develop 1.0.3,
  and 1.0.3 already uploaded to staging's bucket. If they've moved, adjust the versions on slide 15. Staging is
  promoted only by hand, so nothing moves it during the session. You need access to the Promotion Manager
  (spa-example-appset, staging, including its Rollback), ArgoCD (`staging-spa-example`) and the cluster's
  `staging` namespace for the Job log.
- **Backup slide (16):** replace the two placeholders with screenshots from the rehearsal (the promotion and the
  rollback in the Promotion Manager, the Argo app and its Job).

## Diagrams

The seven diagrams were made with [archify](https://github.com/tt-a1i/archify) (3.2.0) from the how-to's
Mermaid diagrams, every label checked against the how-to. Each passed archify's `finalize` gates (validate,
deliver, check, browser-check) and was exported with the viewer's own **SVG · Light** and **SVG · Dark** export.
The export is post-processed: the background and grid are removed so the slide shows through, the canvas is
cropped to the drawing, and the font's code ligatures are turned off (they joined `<app>-site` into one glyph).
Slides embed them with `<picture>`, so the dark variant follows `prefers-color-scheme`; print uses the light one.

| Diagram | Slide | Source |
|---|---|---|
| `four-phases` | 5 | how-to, "The four phases" and "Who does what" (re-rendered 2026-11-23: the function unit) |
| `release` | 7 | how-to, "What a release does" |
| `request` | 8 | how-to, "How a request is served" |
| `site-unit` | 11 | how-to, step 2, "What the two units create" (re-rendered 2026-11-23: function unit and site unit, the site's own certificate) |
| `ci` | 13 | how-to, step 5 (re-rendered 2026-11-23: the ECR check after the build; skip on the same commit, fail on another) |
| `cd` | 14 | how-to, phase 4 |
| `shared-function` | 18 | how-to, step 8 and "Optional: test environments"; TRACKER "Live facts" (the store's two keys, 2026-11-23). Replaces `alias-hosts` |

To rebuild one, from the repo root (needs Node 18+, Google Chrome and the archify skill):

```bash
A=~/.claude/skills/archify/bin/archify.mjs
D=2026-12-shipping-a-spa-as-a-site/assets/diagrams
node $A finalize workflow $D/src/release.candidate.json tmp/archify/release.html --quality showcase --json
node $D/src/export-svg.mjs tmp/archify/release.html $D release   # writes release-light.svg, release-dark.svg
```

Use `architecture` instead of `workflow` for `request`, `site-unit` and `shared-function`. The archify HTML goes
to `tmp/` (not committed, about 800 KB each); the candidates in `assets/diagrams/src/` are the sources.

## Sources

Every source of information used in this presentation goes here.

### Documents & links
- `~/workspaces/cowork/site-platform-strategy/deployment/docs/how-to-deliver-a-spa-as-a-site.md` (draft,
  rewritten and verified 2026-11-23, commit `53194a4`; read 2026-11-23): the deck's spine. The two modules and
  the function unit; spa-example as the versioned example, SDS on v1 as the in-place one; the four phases and what
  flows between them; who does what; the names; the differences that matter, what a release does, how a request
  is served, the side-by-side table and which to choose; every step's details (the function unit and site unit,
  the module-issued certificate and `dns_zones`, the hostname check, build contract, values blocks and the
  `site.hosts` rule, CI, ApplicationSet `retry.limit: 2`, the promotion config, the first promotion, step 8
  promote to staging); rollback through the Promotion Manager (the staging rollback log on slide 16), failed
  releases, `current.json`, retention; the optional API and test-environment sections; production and vanity
  names not yet covered; retiring the old deploy; the troubleshooting rows on slide 20. Its Mermaid diagrams are
  the specs for the archify diagrams. Its SDS example uses `/sds/test1/site` (corrected 2026-11-23)
- `~/workspaces/cowork/site-platform-strategy/deployment/docs/plan-site-v2-and-site-example.md` §1–§2 (read
  2026-11-23): the decisions behind v2 (one distribution per environment; the CloudFront Functions quota; one
  function per site per account; the accepted trade-offs; the function unit in `platform/`) (slides 11 and 18)
- `~/workspaces/cowork/site-platform-strategy/site-hosting-strategy.md` (read 2026-11-23): §0 and §4.9.1b, the
  two modules (slide 3); §4.0 vocabulary and naming (slides 3–4); §4.1–4.2 the two tiers and the MFE rule
  (slides 3 and 22); §4.4.2 the account quotas, a default of 100 CloudFront Functions per account whose
  raisability is unknown, 13 in use in CORE nonprod on 2026-11-19, about 17 more sites at one function per
  distribution against about 87 at one per site per account, and the accepted trade-offs (slides 11 and 18), with
  the 2026-11-21 decision-log correction; §4.4.3 each test environment gets its own distribution, aliasing the
  versioned-only alternative (slide 18; its certificate paragraph is out of date and not used); §4.5 ownership;
  §4.9 what is Terraform, GitOps and runtime (slides 6 and 11)
- [Amazon CloudFront quotas](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cloudfront-limits.html),
  "Quotas on CloudFront Functions" (read 2026-11-17): functions per AWS account, 100 (slide 11). Read through the
  strategy's 2026-11-21 correction: a default quota, raisability unknown
- `~/workspaces/cowork/site-platform-strategy/proposed-standards.md` (read 2026-11-23): 4.13 each environment's
  `site.hosts` lists only its own hostnames (slides 12, 18, 20); 4.9–4.12 one distribution per environment, one
  function per site per account, the function unit (moved to infrastructure-standards #39); 7.6 retention (at
  least 10 non-live versions, never a live one, deletion off by default), 7.12 the Job never retries itself
  (`backoffLimit: 0`), 7.13 pin `site-release` exactly (mfe-example 1.4.0 failed to render with a range), §8
  MFEs on the shared CDN (slide 22; all proposed)
- `~/workspaces/cowork/site-platform-strategy/TRACKER.md`, "Resume here" and the session log to 2026-11-23: the
  status on slide 21; spa-example's develop and staging releases, the staging promotion of 1.0.3 and rollback to
  1.0.2 with develop untouched, edge timings (6 to 31 s at the Job's edge); the live facts (one function
  `terragrunt-demo-spa-example-nonprod-site`, one store with keys develop 1.0.3 and staging 1.0.2); the quota
  correction (13 functions); mfe-example#43 and #44 (CircleCI retired, 1.9.3)
- Archify diagrams in `~/workspaces/cowork/site-platform-strategy/diagrams/archify/` (2026-11-06): `site-topology`,
  `site-request`, `site-publish`, `site-alias`. Read as references only: they predate the in-place/versioned split
  and the shared function, so the deck's diagrams are new candidates (see Diagrams). Labels such as
  `host_mode = site` were not reused

### Internal (Confluence / Jira / repos)
- [COREOPS-4535](https://lmsportal.atlassian.net/browse/COREOPS-4535) (epic),
  [COREOPS-4543](https://lmsportal.atlassian.net/browse/COREOPS-4543) (the how-to, to cicd-standards),
  [COREOPS-4759](https://lmsportal.atlassian.net/browse/COREOPS-4759) (mfe-example to v2) and
  [COREOPS-4776](https://lmsportal.atlassian.net/browse/COREOPS-4776) (SDS to v2): cited on slides 3, 4, 9 and 21.
  COREOPS-4783 and 4784 (the library's site build) in slide 13's notes
- vector-shared-terraform-modules: tags `site-v2.0.0` (#46, 2026-11-22) and `site-function-v1.0.1` (#47,
  2026-11-21), checked with `git` on 2026-11-23; `modules/site-function/functions/viewer-request-in-place.js` and
  `viewer-request-versioned.js` (slide 8); `modules/site` `variables.tf` at `site-v2.0.0` (`function`,
  `dns_zones`, `retention`). `site-v1.0.0` (SDS) and `site-v1.1.0` (mfe-example) are v1 and not presented
- vector-shared-helm-charts `charts/site-release/README.md` on `main`; tags up to `site-release@v0.4.1`: exactly one
  of `site:` and `inPlace:`, pin an exact version
- spa-example `main` at `2470067`: `helm/spa-example` (`Chart.yaml` on `site-release` 0.4.1,
  `envs/values-develop.yaml`, `envs/values-staging.yaml`, slide 12), `.github/workflows/ci.yml` (slide 13),
  `src/App.tsx` and `src/pages/About.tsx` (the footer and the About page, slides 15–16); tags `v1.0.0`–`v1.0.3`
- terragrunt-demo-infrastructure `main`: `platform/spa-example-site-function` and `application/spa-example-site`
  (PRs #20 and #21, merged 2026-11-22), the names on slide 4; #19 (mfe-example's unit, open, `site-v1.1.0`)
- poc-rendered-k8s-manifests commit `818f695` (2026-11-23): `chore(rollback): revert
  app-manifests/spa-example-appset/core-nonprod-east/staging/manifests.yaml to 1.0.2`, the Promotion Manager
  rollback (slide 17)
- SDS, the in-place example: sds-infrastructure `application/sds-site` (`unit_tf/main.tf`: `modules/site`
  `site-v1.0.0`, `routing = "in-place"`; `environments/test1` its only leaf; PRs #4 and #6, merged), and sds
  `main`: `src/helm/sds-site` (`Chart.yaml` on `site-release` 0.3.0, `values.yaml`, `envs/values-test1.yaml`,
  slide 12; the image tag comment on slide 13) and `.github/workflows/ci.yml`
- mfe-example `main` at `7d71044`: the MFE shell on v1 (slide 3), #44 retired CircleCI (slide 21's notes)
- infrastructure-standards #39 (*Create a site unit*), #43 (§16 certificates), #44 (§17 DNS), all open on
  2026-11-23: slides 11 and 21
- PR and tag states checked with `gh` and `git` on 2026-11-23

### Review
- `tmp/2026-12-shipping-a-spa-as-a-site-review.md` (not committed), 2026-11-17: repetition, cuts, order and
  jargon, per the presentation guide. Nothing to cut; slide 19 is the first to go if the demo runs long
- An audit of the deck against the 2026-11-23 sources (a Claude session report, not kept as a file), 2026-11-23:
  what was out of date per slide, the diagrams to redo, and the decisions below

### People consulted
- Noel Aguilar, DevOps (presenter), 2026-11-17: audience, 45 minutes, December 2026; one "coming next" slide
  for MFEs on the shared CDN; a live demo; a few short snippets only; rollback and failures, test environments,
  the API and gotchas included; teams start themselves in their own infrastructure repo; SDS for in-place;
  keystone-cx-tools left out; independently released MFEs are supported, on the shared CDN rather than as sites
  (slide 3)
- Noel Aguilar, 2026-11-23: spa-example (v2, develop and staging) is the versioned example, and mfe-example is
  named once, as an MFE shell delivered the same way, on v1 until COREOPS-4759; the demo is a promotion of 1.0.3
  to spa-example staging and a Promotion Manager Rollback to 1.0.2, with develop's footer unchanged; versioned
  stays preferred, for instant rollback, the self-reverting release check, releases per hostname, old releases
  kept and being proven on v2, and the function quota moves to slide 11 as the reason for one function per site
  per account; the Promotion Manager's rollback is the recommended rollback. (Replaces the 2026-11-17 choices of
  mfe-example, a demo on mfe-example develop, and versioned preferred because alias hosts kept the function count
  down)

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background, taken unchanged from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx`
- `assets/vector-logo.png` and `assets/vector-logo-white.png`: the Vector Solutions logos, taken unchanged from `vector-template.pptx` (`ppt/media/image2.png` and `image7.png`). The white one is used on brand slides and in dark mode
- `assets/diagrams/*-light.svg`, `*-dark.svg`: exported from the archify candidates in `assets/diagrams/src/`
  (see Diagrams), 2026-11-17; `four-phases`, `site-unit`, `ci` and `shared-function` 2026-11-23
- `assets/demo-spa-example-staging-1.0.2.png`: headless Chrome screenshot of https://spa-example.staging.vsp-nonprod.com/about
  on 2026-11-23 at 2× pixel density, cropped to the release paragraph and the footer "staging · release 1.0.2"
  (slide 16). Replaces `demo-mfe-example-1.9.0.png`
- Live checks on 2026-11-23: spa-example served 1.0.3 on develop and 1.0.2 on staging
  (`<meta name="release-version">`), staging's `/config/spa-example-config.json` names staging; mfe-example develop
  served 1.9.3; https://test1.vectorsds-nonprod.com/ served 200

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors, the rounded-diamond outline motif and the title background
- `~/OneDrive - Vector Solutions/Documents/presentations/vector-template.pptx` (Vector Solutions PowerPoint template): the footer on its slide master (logo, then the strip's gradient `#96D448` → `#293D9A` → `#5AB7E6`)

## Notes

- Diagram text is smaller than slide text: at 1600×900, node labels are about 16px and edge labels about 11px.
  The diagrams are kept within the guide's 46% height limit (38% on slide 11, which also has a snippet); click
  one to see it full screen.
- The site-unit names for SDS differ from the pattern (its only site, so app = product, and a product domain), and
  SDS has no function unit while it's on v1; the speaker notes on slide 4 say so.
- vs-skills is no longer an example: it uses neither the module nor the chart (the how-to dropped it on 2026-11-23).
