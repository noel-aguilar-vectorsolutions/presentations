# Shipping a SPA as a site

**Created:** 2026-11-17
**Audience:** product dev teams and leads who build SPAs and MFE host shells, plus DevOps engineers. They know CI/CD, ArgoCD and AWS; they don't yet know `modules/site`, `modules/site-function`, the `site-release` chart, KeyValueStore routing or the new names
**Status:** Draft, for the presenter's review. Built 2026-11-17; brought up to date on 2026-11-23 (`modules/site` v2, spa-example) and on 2026-11-24 (site-release 0.5.0 and `cacheFor`, spa-example 1.0.4, the how-to split in two), with content as of 2026-11-24; to be presented in December 2026. Not yet rehearsed; the status slide (21) must be re-checked before presenting
**Design:** [`docs/superpowers/specs/2026-11-17-shipping-a-spa-as-a-site-design.md`](../docs/superpowers/specs/2026-11-17-shipping-a-spa-as-a-site-design.md)

## Summary

How SPAs and MFE host shells are now delivered as **sites**: per environment, a CloudFront distribution, an S3
bucket, DNS records and the site's own certificate, created by `modules/site` v2; once per account, the site's
viewer-request function (and, for versioned, its KeyValueStore), created by `modules/site-function` and attached
by every environment's distribution. It covers the four phases in order (infrastructure → app repository → CI →
CD), what each produces and who owns it, and the two release methods, **in-place** and **versioned**: what a
release does, how a request is served, how they differ and which to choose (once per site; versioned is
preferred). spa-example (develop and staging, on v2) is the only worked example; where in-place differs, the deck
shows spa-example's names in place as an illustration, since no site runs in-place on v2 yet. It ends with rollback through the Promotion Manager and failed releases, each environment as
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
| Demo: promote forward, check the cache headers, then roll back, on spa-example staging (slide 16 is the backup, used only if the demo fails) | 15–16 | 5.5 |
| After the first release: rollback and failures, environments, an API through the site, gotchas | 17–20 | 6 |
| Where things stand: status and where to look; MFEs on the shared CDN (coming) | 21–22 | 3 |
| Questions | 23 | 6 |
| **Total** | | **45** |

## Before presenting

- **Re-check the status slide (21)** and its speaker notes. As of 2026-11-24: `site-v2.0.0` and
  `site-function-v1.0.1` tagged (`site-v2.0.1` since, CHANGELOG only); `site-release@v0.5.0` the latest chart,
  with `cacheFor`; spa-example on site-release 0.5.0 from 1.0.4, live on develop (1.0.4) and staging (1.0.2); no
  site in-place on v2 yet; mfe-example on v1 until COREOPS-4759 (its unit on terragrunt-demo-infrastructure#19,
  open); no test environment or production on v2; the how-to split in two: *Create a site unit*
  (infrastructure-standards `docs/how-to/site-unit.md`, with §15.2.1, in review on #39) and *Deliver a SPA as a
  site* (moving to cicd-standards `docs/how-to/deliver-a-spa-as-a-site.md` after #39 merges, COREOPS-4543); #43
  (§16 certificates) and #44 (§17 DNS) open. Anything merged or moved since changes its row; slides 2, 9, 11, 18
  and 23 mention the same items. Also re-check two figures: CORE nonprod's
  CloudFront Functions count (13 on 2026-11-19, slide 11's caption and notes; `aws cloudfront list-functions`
  lists each function twice, DEVELOPMENT and LIVE) and the versions on slide 18's caption (develop 1.0.4,
  staging 1.0.2 on 2026-11-24).
- **Demo start state (a prerequisite):** spa-example staging on 1.0.2 with a newer version (1.0.4) available to
  promote, and develop on 1.0.4, so the demo shows only staging's key moving. That is the state as of
  2026-11-24: the Promotion Manager auto-deployed 1.0.4 to develop (poc-rendered-k8s-manifests `120d807`,
  00:40Z), and staging is on 1.0.2 after its rollback on 2026-11-23. Check both footers first: open `/about`
  on each host, or `curl -s https://spa-example.<env>.vsp-nonprod.com/ | grep -o 'release-version" content="[^"]*"'`
  for `develop` and `staging`. Develop gets every release from main, so it may be newer by then. To restore
  staging, in the Promotion Manager (spa-example-appset): roll staging back to its 1.0.2 promotion (or promote
  1.0.2 to staging). If the versions differ, use staging's current version and a newer one already built on
  site-release 0.5.0 or later (1.0.4 is the first), and change the numbers on slides 15, 16 and 18. Staging is
  promoted only by hand, so nothing moves it during the session.
- **The cache beat (step 4):** after the promotion, `curl -sI` staging's `/favicon.svg` (expect
  `no-cache, max-age=0, must-revalidate`) and one `/releases/spa-example/1.0.4/assets/…` file (expect
  `public, max-age=31536000, immutable`). Do it before the Rollback: 1.0.2's files keep the headers their
  pre-0.5.0 upload gave them. Not yet tried on staging; confirm at rehearsal.
- **The Rollback is for staging:** in step 4, choose the Rollback for the **staging** environment, not develop,
  and check the environment the Promotion Manager shows before confirming (both the promotion and the
  Rollback). At rehearsal, note where the UI shows which environment a Rollback applies to, in slide 15's notes.
- **Access for the demo:** the Promotion Manager (spa-example-appset, staging, including its Rollback), ArgoCD
  (`staging-spa-example`) and `kubectl --context core-nonprod-us-east-2` on the `staging` namespace for the Job
  log. Run the log command after ArgoCD shows the new Job (each sync replaces it), and again for the rollback.
- **Backup slide (16):** its About-page screenshot, Job log and store listing are from the 2026-11-23 run
  (1.0.3 → 1.0.2, develop on 1.0.3) and are labelled so. Replace the placeholders with captures from the
  rehearsal: the promotion of 1.0.4 and the Rollback in the Promotion Manager; the Argo app and its Job; and that
  run's Job log (the `cache:` line, `1.0.2 -> 1.0.4`, `serves`) with the `curl -I` headers, which replace the
  2026-11-23 log and store listing.

## Diagrams

The seven diagrams were made with [archify](https://github.com/tt-a1i/archify) (3.2.0) from the how-to's
Mermaid diagrams, every label checked against the how-to. Each passed archify's `finalize` gates (validate,
deliver, check, browser-check) and was exported with the viewer's own **SVG · Light** and **SVG · Dark** export.
The export is post-processed: the background and grid are removed so the slide shows through, the canvas is
cropped to the drawing, and the font's code ligatures are turned off (they joined `<app>-site` into one glyph).
Slides embed them with `<picture>`, so the dark variant follows `prefers-color-scheme`; print uses the light one.

| Diagram | Slide | Source |
|---|---|---|
| `four-phases` | 5 | how-to, "The four phases" and "Who does what" (re-rendered 2026-11-23: the function unit; 2026-11-24: the site unit's tag is "code owner approves", only the function unit needs DevOps) |
| `release` | 7 | how-to, "What a release does" |
| `request` | 8 | how-to, "How a request is served" (re-rendered 2026-11-23: versions 1.0.3; the 404/503 tags moved to the slide's caption) |
| `site-unit` | 11 | how-to, step 2, "What the two units create" (re-rendered 2026-11-23: function unit and site unit, the site's own certificate; the versioned-only parts folded into the CloudFront and SSM labels so the diagram is shorter and its text larger) |
| `ci` | 13 | how-to, step 5 (re-rendered 2026-11-23: the ECR check after the build; skip on the same commit, fail on another) |
| `cd` | 14 | how-to, phase 4 (re-rendered 2026-11-23: the Job "runs on each sync" instead of "Sync hook") |
| `shared-function` | 18 | how-to, step 8 and "Optional: test environments"; TRACKER "Live facts". Replaces `alias-hosts`; production is in the caption, not the diagram, to keep its text larger |

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
  the function unit; spa-example as the worked example; the four phases and what
  flows between them; who does what; the names; the differences that matter, what a release does, how a request
  is served, the side-by-side table and which to choose; every step's details (the function unit and site unit,
  the module-issued certificate and `dns_zones`, the hostname check, build contract, values blocks and the
  `site.hosts` rule, CI, ApplicationSet `retry.limit: 2`, the promotion config, the first promotion, step 8
  promote to staging); rollback through the Promotion Manager (the staging rollback log on slide 16), failed
  releases, `current.json`, retention; the optional API and test-environment sections; production and vanity
  names not yet covered; retiring the old deploy; the troubleshooting rows on slide 20. Its Mermaid diagrams are
  the specs for the archify diagrams
- The same draft at `881f45a` (read 2026-11-24), now the CI/CD half of a split how-to, moving to cicd-standards
  `docs/how-to/deliver-a-spa-as-a-site.md` after infrastructure-standards #39 merges: the link to *Create a site
  unit* for phase 1; "Who does what" (DevOps approves the function unit, a CODEOWNER, product team or DevOps, the
  site leaves; slides 2, 5, 6, 14, 21, 23); step 3's `cacheFor` table, wildcards, the always-`no-cache` files,
  `vendor/` and §15.2.1 (slides 11, 12, 15); step 4's `cacheFor` and the deprecated `inPlace.noCache` (slide 12);
  "Updating the site-release chart" and the troubleshooting rows for `cacheFor` (slides 20 and 23)
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
  [COREOPS-4789](https://lmsportal.atlassian.net/browse/COREOPS-4789) (`cacheFor`): cited on slides 3 and 21.
  COREOPS-4783 and 4784 (the library's site build) in slide 13's notes
- vector-shared-terraform-modules: tags `site-v2.0.0` (#46, 2026-11-22) and `site-function-v1.0.1` (#47,
  2026-11-21), checked with `git` on 2026-11-23; `modules/site-function/functions/viewer-request-in-place.js` and
  `viewer-request-versioned.js` (slide 8); `modules/site` `variables.tf` at `site-v2.0.0` (`function`,
  `dns_zones`, `retention`). `site-v1.0.0` and `site-v1.1.0` are v1 and not presented
- vector-shared-helm-charts `charts/site-release/README.md` on `main`; tags up to `site-release@v0.4.1`: exactly one
  of `site:` and `inPlace:`, pin an exact version; `templates/_release.tpl`: the Job is a hook with
  `hook-delete-policy: BeforeHookCreation`, so each sync replaces it (slide 15's notes)
- spa-example `main` at `2470067`: `helm/spa-example` (`Chart.yaml` on `site-release` 0.4.1,
  `envs/values-develop.yaml`, `envs/values-staging.yaml`, slide 12), `.github/workflows/ci.yml` (slide 13),
  `src/App.tsx` and `src/pages/About.tsx` (the footer and the About page, slides 15–16); tags `v1.0.0`–`v1.0.3`
- terragrunt-demo-infrastructure `main`: `platform/spa-example-site-function` and `application/spa-example-site`
  (PRs #20 and #21, merged 2026-11-22), the names on slide 4; #19 (mfe-example's unit, open, `site-v1.1.0`)
- poc-rendered-k8s-manifests commit `818f695` (2026-11-23): `chore(rollback): revert
  app-manifests/spa-example-appset/core-nonprod-east/staging/manifests.yaml to 1.0.2`, the Promotion Manager
  rollback (slide 17); `894b129` and `b39f2ab` (2026-11-23, after it): staging promoted to 1.0.3 and develop rolled
  back to 1.0.2, its render restored with `site-release-0.4.0` (slide 17's notes; the demo prerequisite)
- vector-shared-helm-charts `charts/site-release/templates/_helpers.tpl` and `tests/fixture/envs/values-in-place.yaml`
  at `site-release@v0.4.1`: the keys an `inPlace:` block accepts (`target`, `ssmPrefix`, `bucket`, `invalidate`,
  `invalidationTimeoutSeconds`, `sourcePath`, `hook`, `noCache`), for slide 12's in-place illustration
- mfe-example `main` at `7d71044`: the MFE shell on v1 (slide 3), #44 retired CircleCI (slide 21's notes)
- infrastructure-standards #39 (*Create a site unit*), #43 (§16 certificates), #44 (§17 DNS), all open on
  2026-11-23: slides 11 and 21
- PR and tag states checked with `gh` and `git` on 2026-11-23
- vector-shared-helm-charts #8 (`feat(site-release): cacheFor decides each file's Cache-Control (COREOPS-4789)`,
  merged 2026-11-24 00:29Z as `4d2815e`), tag `site-release@v0.5.0`: `templates/_helpers.tpl` (`cacheFor`
  required, its durations and refused globs, the accepted keys; `inPlace.noCache` still accepted) and
  `templates/_script.tpl` (the `Cache-Control` per duration, the `cache:` log line and the unmatched-glob line,
  the deprecation warning, `vendor/` a year, the upload only when the release folder isn't there), read
  2026-11-24: slides 12, 15, 20, 21
- spa-example #7 (`chore(spa-example): site-release 0.5.0, cacheFor gives a year only to assets/*`, merged
  2026-11-24 00:39Z), tag `v1.0.4`: `helm/spa-example/Chart.yaml` (site-release 0.5.0), `values.yaml`
  (`cacheFor: { "assets/*": 1y }`, the same in every environment; favicon.svg and favicon.ico no-cache) and
  `envs/values-develop.yaml`, read 2026-11-24 (slides 12, 15, 21)
- poc-rendered-k8s-manifests commit `120d807` (2026-11-24 00:40Z): `chore: promote
  app-manifests/spa-example-appset/core-nonprod-east/develop/manifests.yaml (image tag: 1.0.4)`, the Promotion
  Manager's auto-deploy of 1.0.4 to develop (slides 15, 18, 21)
- infrastructure-standards #39 (open), branch `docs/cloudfront-standard`, read 2026-11-24:
  `docs/how-to/site-unit.md` (*Create a site unit*: the ECR repository, both units, §8 every environment's leaf,
  the API, the publisher's IAM, §10 plan failures, "Order of the work, and who approves") and
  `docs/15-cloudfront.md` §15.2.1, a site's cache policies' minimum TTL (0 for `/config/*`, 1 second or less for
  the default behavior; the module's defaults meet both): slides 6, 11, 18, 20, 21
- vector-shared-terraform-modules #48 (merged), tag `site-v2.0.1`: a CHANGELOG-only fix (slide 21's notes)
- PR and tag states (#39, #43, #44 open; #8, #7, #48 merged) checked with `gh` on 2026-11-24

### Review
- `tmp/2026-12-shipping-a-spa-as-a-site-review.md` (not committed), 2026-11-17: repetition, cuts, order and
  jargon, per the presentation guide. Nothing to cut; slide 19 is the first to go if the demo runs long
- An audit of the deck against the 2026-11-23 sources (a Claude session report, not kept as a file), 2026-11-23:
  what was out of date per slide, the diagrams to redo, and the decisions below

### People consulted
- Noel Aguilar, DevOps (presenter), 2026-11-17: audience, 45 minutes, December 2026; one "coming next" slide
  for MFEs on the shared CDN; a live demo; a few short snippets only; rollback and failures, test environments,
  the API and gotchas included; teams start themselves in their own infrastructure repo;
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
- Noel, 2026-11-23: spa-example is the only worked example; the earlier in-place example app is not referenced, and
  in-place is shown only as an illustration with spa-example's names

- Noel Aguilar, 2026-11-24 (the brief for this update): what changed that day (site-release 0.5.0 and its
  `cacheFor` rules, spa-example 1.0.4 and the develop auto-deploy, the how-to split, §15.2.1, approvals per
  CODEOWNERS); the live state as develop 1.0.4 and staging 1.0.2 (develop serving 1.0.4 was being verified
  separately); the demo promotes 1.0.4 and adds a short `curl -I` beat; the backup slide keeps the 2026-11-23
  captures, labelled, with a placeholder for a re-capture with 1.0.4. The beat follows TRACKER's follow-up to
  check `assets/*` `immutable` and `favicon.svg` `no-cache` with `curl -I`

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background, taken unchanged from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx`
- `assets/vector-logo.png` and `assets/vector-logo-white.png`: the Vector Solutions logos, taken unchanged from `vector-template.pptx` (`ppt/media/image2.png` and `image7.png`). The white one is used on brand slides and in dark mode
- `assets/diagrams/*-light.svg`, `*-dark.svg`: exported from the archify candidates in `assets/diagrams/src/`
  (see Diagrams), 2026-11-17; `four-phases`, `site-unit`, `ci` and `shared-function` 2026-11-23; `four-phases`
  again 2026-11-24
- `assets/demo-spa-example-staging-1.0.2.png`: headless Chrome screenshot of https://spa-example.staging.vsp-nonprod.com/about
  on 2026-11-23 at 2× pixel density, cropped to the release paragraph and the footer "staging · release 1.0.2"
  (slide 16). Replaces `demo-mfe-example-1.9.0.png`
- Live checks on 2026-11-23: spa-example served 1.0.3 on develop and 1.0.2 on staging
  (`<meta name="release-version">`), staging's `/config/spa-example-config.json` names staging; mfe-example develop
  served 1.9.3; after 19:27Z the same day, develop served 1.0.2 and staging 1.0.3 (see
  the demo start state above)

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors, the rounded-diamond outline motif and the title background
- `~/OneDrive - Vector Solutions/Documents/presentations/vector-template.pptx` (Vector Solutions PowerPoint template): the footer on its slide master (logo, then the strip's gradient `#96D448` → `#293D9A` → `#5AB7E6`)

## Notes

- Diagram text is smaller than slide text. At 1600×900 the workflow diagrams (`four-phases`, `release`, `ci`,
  `cd`) show node labels at about 17px and sublabels about 13px; the architecture diagrams (`request`,
  `site-unit`, `shared-function`) at about 15px and 11–12px; edge labels are smaller in both. The diagrams are
  kept within the guide's 46% height limit; click one to see it full screen.
- In-place appears only as an illustration with spa-example's names (slides 9 and 12): spa-example is versioned,
  and no site runs in-place on v2 yet.
- vs-skills is no longer an example: it uses neither the module nor the chart (the how-to dropped it on 2026-11-23).
