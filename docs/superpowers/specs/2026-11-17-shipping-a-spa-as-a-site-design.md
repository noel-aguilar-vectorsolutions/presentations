# Shipping a SPA as a site — presentation design

**Date:** 2026-11-17
**Owner / presenter:** Noel Aguilar
**Deliverable:** a new presentation in this repo, `2026-12-shipping-a-spa-as-a-site/`, built from
`_template/` following [`CLAUDE.md`](../../../CLAUDE.md) and the
[presentation guide](../../presentation-guide.md).

## Intent

Explain how SPAs and MFE host shells are now delivered as **sites**, and enable teams to do it.
A site is the CloudFront distribution, bucket and viewer-request function that `modules/site`
creates for one app in one environment. The deck covers the **four phases** in order
(infrastructure → app repository → CI → CD), what each produces and who owns it, and the **two
release methods**, in-place and versioned: how they differ and which to choose.

The tone is **inform and enable**. It is not asking for a decision. It ends with where the how-to
and the rules live, so a team can start on its own.

## Audience

Product dev teams and leads who build SPAs and MFE host shells, plus DevOps engineers.

- **They know** CI/CD, GitHub Actions, ArgoCD and AWS in general.
- **They don't know** `modules/site`, the `site-release` chart, KeyValueStore routing, or the new
  names: *site*, the `-site` ECR repository, `<app>-site-publisher`.
- **They care about** what they have to do and in what order; which method to pick; how a release
  and a rollback behave in production; and who to ask for each step.

## Goals

After the session, someone in the room should know:

1. **What a site is**, and what is delivered as one today: an SPA, or an MFE host shell whose MFEs
   ship in the same release (mfe-example). A frontend that runs as a pod is not a site.
2. **The four phases in order**, what each produces, what flows from one to the next, and who owns
   each step (DevOps or the product team).
3. **The two methods** and how they differ: what a release does to the bucket, how a request is
   served, rollback, the build changes, the image tag, and what happens before the first release.
4. **Which method to pick**, and that the choice is **made once per site**: switching an existing
   site isn't supported; you'd stand up a new distribution.
5. **How rollback and failed releases behave** under each method.
6. **Where the how-to and the rules live**, and what is still being finalized.

## Non-goals

- Every step of the how-to. The deck shows the order, the outputs, the owners and the few lines of
  config where the method shows; the how-to has the rest.
- How `modules/site` or the `site-release` chart work inside: function code, Job script, IAM policy
  documents.
- The strategy's option analysis (why not nginx pods, why not the shared CDN for everything) and its
  decision log.
- Vanity domains (`modules/product-domains`), CSP and response-headers policies, WAF, quotas.
- Frontends that run as pods. They're delivered like any EKS workload.
- Independently released MFEs on the shared CDN, beyond one "coming next" slide (Goal 1's boundary).

## Anti-goals

- **Reading like the how-to.** A wall of YAML and numbered steps. Snippets appear only where the
  method choice shows.
- **Presenting anything unmerged as done.** `modules/site` v1.1.0 (versioned) and the how-to are
  "being finalized" unless they've merged by the presenting date.
- **Presenting the shared-CDN MFE model as how it works today.** It is coming, not built.
- **Restating facts differently from the sources.** Every number and name comes from the how-to, the
  module, the chart or the standards (see "Facts the deck must state exactly").
- **Inventing timings.** Only quoted figures: about a minute for an in-place release; 30–40 s for a
  key to reach the edge (measured on develop); a check of up to 180 s; about 12 minutes at most for a
  failed release with two retries.
- **Stale diagram labels** carried over from the 2026-11-06 archify diagrams (e.g. "Argo sync hook",
  `host_mode = site`).

## Constraints

- **45 minutes total, including Q&A**: about 38 minutes of slides and demo, 7 of questions.
- **Presented in December 2026.** The title slide says "December 2026", no day. Content is written
  as of **2026-11-17**, and every line in the status table below is re-checked before presenting.
- Repo conventions from `CLAUDE.md`: scaffold with `./new-presentation.sh`; self-contained
  `index.html`; every source in the deck README; `slides.md` exported; Index row in the root README;
  `_template/` untouched; no git commits or pushes without asking.

### Status as of 2026-11-17 (re-check before presenting)

| Item | Status on 2026-11-17 | How the deck says it |
|---|---|---|
| `modules/site` v1.0.0 (in-place) | Merged, tagged `site-v1.0.0` (vector-shared-terraform-modules#42, 2026-11-16) | Available |
| `modules/site` v1.1.0 (versioned) | Branch `feat/COREOPS-4536-site-versioned-routing` at `6b60d6c`; no PR, no tag | Being finalized |
| `site-release` chart | 0.3.1 published and tagged (`site-release@v0.3.1`) | Available |
| mfe-example on versioned, develop | 1.9.0 live through the KeyValueStore; the footer shows the version | Live on develop |
| mfe-example#40 (version in the footer) | **Merged** 2026-11-17 00:40Z (the brief said open) | Live |
| SDS on in-place, test1 | `application/sds-site` on `site-v1.0.0`, `routing = "in-place"` (sds-infrastructure#4, #6, merged); `src/helm/sds-site` on site-release 0.3.0, `inPlace:`. test1 serves 200, `/config.json` `no-cache` | Live on test1 |
| mfe-example's site unit (terragrunt-demo-infrastructure#19) | Open; applied from the branch, `modules/site` pinned by commit | Not stated on a slide; noted in speaker notes |
| The how-to | Draft in site-platform-strategy; moves to architecture-standards `docs/how-to` after approval | Being finalized; link to where it will live |
| Site-unit how-to (infrastructure-standards#39) | Open | Being finalized |
| `*.test1-3` SANs on the nonprod us-east-1 cert | Not there yet | Test environments as alias hosts: being finalized |
| Jira | Epic COREOPS-4535, story COREOPS-4536 (In Development) | Cited on the status slide |

## Facts the deck must state exactly

From the how-to, `modules/site` (v1.1.0 branch), `site-release` 0.3.1 and proposed-standards 7.6:

- **Scope.** An SPA, or an MFE host shell whose MFEs ship in the same release (mfe-example), is
  delivered as a site. Independently released MFEs on the shared asset CDN
  (`mfes/<org>/<pkg>/vX.Y.Z/`) belong to a follow-on epic and aren't built yet.
- **Choose once.** `routing = "in-place" | "versioned"` on `modules/site`, required, no default.
  Switching an existing site isn't supported; you'd stand up a new distribution.
- **The method is set twice and must match**: `routing` in the unit, and exactly one values block in
  the chart, `site:` (versioned) or `inPlace:`. The render fails with neither, both, or an unknown key.
- **Versioned**: `X.Y.Z` versions; one KeyValueStore key per hostname; publish and rollback are one
  key write, no invalidation; `503 site not released` until the first release; retention keeps at
  least 10 non-live versions, never a live one; deletion is off by default.
- **In-place**: any tag; copy, then the `no-cache` entry files, then invalidate and wait, then sweep;
  `404` before the first release. Reference apps: vs-skills and SDS (the how-to's wording).
- **Worked examples** (presenter, 2026-11-17): **SDS for in-place, mfe-example for versioned.** Every
  in-place value quoted on a slide comes from SDS; every versioned one from mfe-example. vs-skills
  appears only where the how-to's wording names it, and in speaker notes.
- **`site-release` 0.3.1**, pinned exactly, with `Chart.lock` committed, from `oci://…/tooling/helm`.
- **Test environments** (test1–3) are alias hosts on develop's distribution (versioned). The nonprod
  us-east-1 cert doesn't cover `*.test1-3` yet.
- **Names**: ECR `<product>/<app>-site` (`-site` = a data-only image, published, never run); unit
  `application/<app>-site`; ServiceAccount `<app>-site-publisher`; SSM `/<product>/<env>/site/<app>`;
  chart `helm/<app>`; ApplicationSet `<app>-appset`; Argo app `<env>-<app>`.

## Structure and timing

| # | Section | Slide | ~Min |
|---|---|---|---|
| 1 | Opening | Title | 0.5 |
| 2 | | What you'll leave with: the order of the work, who owns it, which method, where the how-to is | 1 |
| 3 | What a site is | **A site is a hostname-rooted static origin**: what's delivered as one, what isn't | 2 |
| 4 | | **The names**: one noun all the way through, with mfe-example's real values | 1.5 |
| 5 | The four phases | **Four phases, in order**: diagram (a) | 2 |
| 6 | | **Who does what**: each phase's output, owner and repo | 1.5 |
| 7 | Two methods | **What a release does**: diagram (c), in-place vs versioned | 2.5 |
| 8 | | **How a request is served**: diagram (d) | 1.5 |
| 9 | | **Side by side**: the comparison table | 1.5 |
| 10 | | **Which to choose, once** | 1.5 |
| 11 | Phase by phase | **Phase 1, infrastructure**: diagram (b) and the `routing` line | 2.5 |
| 12 | | **Phase 2, the app repository**: the build fits the method; the two values blocks | 3 |
| 13 | | **Phase 3, CI**: diagram (e) | 1.5 |
| 14 | | **Phase 4, CD**: diagram (f) | 2 |
| 15 | Demo | **Live: roll back, then forward**, on mfe-example develop | 5 |
| 16 | | Backup: the same in screenshots (used only if the demo fails) | 0 |
| 17 | After the first release | **Rollback and failed releases** | 2 |
| 18 | | **Test environments as alias hosts** (versioned) | 1 |
| 19 | | **An API through the site** (`/api/*`) | 1 |
| 20 | | **Top gotchas** | 1.5 |
| 21 | Where things stand | **Status, and where the how-to and rules live** | 2 |
| 22 | | **Coming next: MFEs on the shared CDN** | 1 |
| 23 | | Questions | 7 |
| | | **Total** | **45** |

About 23 slides. Section dividers are optional; if used, their time comes out of their section.

## Content by slide

### 2. What you'll leave with
- The order of the work and what each phase hands to the next.
- Who owns each step.
- Which method fits your app, and why you choose once.
- Where the how-to and the rules are.

### 3. A site is a hostname-rooted static origin
- **A site** = CloudFront distribution + S3 bucket + viewer-request function (+ DNS, + the
  publisher's identity), created by `modules/site` for **one app in one environment**. It doesn't
  care what the files are.
- **Delivered as a site today**: an SPA; an MFE host shell whose MFEs ship in the same release
  (mfe-example).
- **Not a site**: a frontend that runs as a pod (delivered like any EKS workload); independently
  released MFEs (coming, slide 22).
- Vocabulary in one line each: *frontend* (what a team builds), *SPA* (owns a hostname), *MFE*
  (loaded into a site), *site* (where it's published).

### 4. The names
Table: the pattern, then mfe-example's value (versioned) and SDS's (in-place), for the ECR
repository, unit, `pkg` (versioned only), hostname, SSM prefix, publisher ServiceAccount and chart:

| What | Pattern | mfe-example (develop) | SDS (test1) |
|---|---|---|---|
| ECR repository | `<product>/<app>-site` | `examples/mfe-example-site` | `sds/sds-site` |
| Unit | `application/<app>-site` | `application/mfe-example-site` | `application/sds-site` |
| Hostname | `<app>.<env>.vsp-<account>.com` | `mfe-example.develop.vsp-nonprod.com` | `test1.vectorsds-nonprod.com` (product domain) |
| SSM prefix | `/<product>/<env>/site/<app>` | `/terragrunt-demo/dev/site/mfe-example` | `/sds/test1/site` |
| ServiceAccount | `<app>-site-publisher` | `mfe-example-site-publisher` | `sds-site-publisher` |
| Chart | `helm/<app>` | `helm/mfe-example` | `src/helm/sds-site` |

Speaker notes explain SDS's differences: it is the product's only site, so the app and product names
coincide and the SSM prefix has no `<app>` level; its hostname is on the product's own domain. Callout:
**`-site` means a data-only image, published and never run**; a frontend that runs as a pod doesn't
carry `-site`.

### 5. Four phases, in order
Diagram (a). Phase 1 creates the site and the ECR repository; its outputs (SSM prefix, ServiceAccount,
hostnames, `release_name`) fill in the chart in phase 2. Phase 3 turns the build into **one release
image**. Phase 4 renders the chart with that image and runs a Job that publishes the files. The image
is **never run as a service**; the Job copies the files out of it.

### 6. Who does what
| Phase | Produces | Who | Where |
|---|---|---|---|
| 1. Infrastructure | The site, SSM parameters, publisher role and ServiceAccount; the ECR repository | DevOps (ECR); product team, DevOps approves (unit) | lvsf-infrastructure; `<product>-infrastructure` |
| 2. App repository | A build that fits the method; `Dockerfile`; `helm/<app>/` | Product team | the app's repo |
| 3. CI | The release image in ECR, built once per version | Product team | `.github/workflows/` |
| 4. CD | ArgoCD registration; each promotion publishes | DevOps (registration); product team (promotions) | argo-app-of-apps; Promotion Manager UI |

### 7. What a release does
Diagram (c), two lanes:
- **In-place**: copy the new build (nothing deleted yet) → `index.html` and `files:` entries
  `no-cache` → invalidate `/*` and wait → sweep files the new build no longer has. About a minute.
  Every hostname serves the one build.
- **Versioned**: upload `releases/<pkg>/<version>/` (skipped if already there) → write per-host
  config → write the KeyValueStore key per hostname → check the page names the new version (up to
  180 s) → on failure, put the old keys back and fail. No invalidation.

### 8. How a request is served
Diagram (d). In both, a path whose last segment has no `.` is a client-side route and gets the page.
In-place serves `/index.html` from the bucket root. Versioned looks up the `Host` in the
KeyValueStore and rewrites into `/releases/<pkg>/<version>/`, so two hostnames on one distribution
can serve two releases.

### 9. Side by side
`.dense` table, rows: going live, rolling back, release check, hostnames, runtime config, build
changes, image tag, old releases, `modules/site` (version and `routing` value), chart block, before
the first release, examples.

### 10. Which to choose, once
- **In-place**: a plain build; no instant rollback needed; or a build that can't put the version in
  its URLs.
- **Versioned**: instant rollback, a release per hostname, or test environments sharing develop's
  distribution.
- Callout: **choose once**. Switching an existing site isn't supported; you'd stand up a new
  distribution (the bucket layout, the function and the publisher's permissions all differ).

### 11. Phase 1, infrastructure
- ECR `<product>/<app>-site` (DevOps, lvsf-infrastructure). An in-place app that ships its bundle in
  its API image (vs-skills) doesn't need one.
- The site unit `application/<app>-site` calls `modules/site`. Snippet: the `source … ?ref=site-v1.1.0`
  and `routing = "versioned"   # or "in-place"; required, no default` lines.
- Diagram (b): what the unit creates, with the **versioned-only** parts set apart (KeyValueStore,
  `/config/*` behavior, SSM `kvs_arn` and `retention`).
- Check: every hostname answers `404` (in-place) or `503 site not released` (versioned).

### 12. Phase 2, the app repository
- **The image holds no environment values.** Browser-read config goes in the chart's `files:`, and
  it's public: never a secret.
- **In-place**: a plain build with `index.html` at the top.
- **Versioned**: host-relative URLs, `/releases/<pkg>/<version>/…`, written by the build from
  `RELEASE_VERSION`; app code never derives URLs from its own version.
- **The chart**: `helm/<app>/` on `site-release` 0.3.1, pinned exactly, `Chart.lock` committed.
- Snippet, two columns: the `site:` block from mfe-example (`pkg`, `hosts`, `ssmPrefix`) and the
  `inPlace:` block from SDS (`target: "."`, `sourcePath: /release/site`, `ssmPrefix: /sds/test1/site`,
  `noCache: [sw.js]`, with `files: config.json` served at `/config.json`). **Exactly one**, matching
  `routing`.

### 13. Phase 3, CI
Diagram (e): push to `main` → compute the version → tag already in ECR? skip → build (versioned:
`RELEASE_VERSION` set) → check the entry files → image with files under `/release` → ECR. Points:
**build once**, every environment releases the same image; versioned takes only `X.Y.Z`, in-place
any tag (SDS releases build tags such as `main-<run>`); never push over an existing tag.
mfe-example's `ci.yml` is the versioned reference, SDS's `ci.yml` the in-place one.

### 14. Phase 4, CD
Diagram (f): Promotion Manager renders `helm/<app>` with the image tag → commits the env's manifests
to the rendered-manifests repo → ArgoCD syncs `<env>-<app>` → the Sync hook runs the publisher Job →
the Job publishes. Register once (ApplicationSet + promotion config, one argo-app-of-apps PR, DevOps):
auto-deploy on the lowest environment only, `retry.limit: 2`. **Promote the first release by hand.**

### 15. Live: roll back, then forward
On mfe-example develop (https://mfe-example.develop.vsp-nonprod.com/; the version is in the footer).
Precondition: a release newer than 1.9.0 is live on develop (any merge to mfe-example `main`
auto-deploys one).

1. Show the footer on the current version (e.g. 1.10.0).
2. Promotion Manager: promote 1.9.0 to develop. That's the rollback.
3. ArgoCD: `develop-mfe-example` syncs and runs `develop-mfe-example-site-release`.
4. Job log: the upload is skipped (the folder is there), the key changes, `still waiting` every 15 s,
   then `serves 1.9.0`.
5. Reload: the footer shows 1.9.0.
6. Promote the newer version again; the footer moves forward.

Speaker notes carry the click path, the expected wait (30–40 s for the key to reach the edge), and
the fallback: switch to slide 16, and if a sync hangs, terminate the operation in ArgoCD.

### 16. Backup
Screenshots from a rehearsal: the footer before and after, the Promotion Manager promotion, the Argo
sync and the Job log lines.

### 17. Rollback and failed releases
- **Rollback**: promote the earlier version. Versioned: the Job finds the folder and only switches
  the key. In-place: a full release with the earlier image (copy, invalidate, sweep).
- **A failed versioned release**: if a host doesn't serve the new version within 180 s, the Job puts
  every key back and fails. Users see the old version; nothing to clean up.
- **A failed in-place release**: every step is safe to repeat; if the invalidation times out, the
  next sync finishes the release.
- **Both**: ArgoCD retries twice, about 12 minutes at most; a newer release waits, and releases in
  between are skipped. Terminate the operation to stop sooner.

### 18. Test environments as alias hosts (versioned)
test1–3 are extra hostnames on develop's distribution, each with its own key, so test1 can stay on an
older release while develop moves on, and retention never deletes a version any host points at.
**Being finalized**: the nonprod cert doesn't cover `*.test1-3` yet. Use your own distribution if a
test environment must test infrastructure changes or needs its own WAF, headers, logs or IAM.

### 19. An API through the site
Same for both methods: `/api/*` on the site's own hostname, so no CORS. The unit's `api` input adds
the behavior; the API's chart adds a site VirtualService; the API checks requests came through
CloudFront (architecture-standards §206); the site's config sets `API_URL: /api`. mfe-example's
`/api/hello` reaches the echo server this way; SDS sends `/api` and `/admin` to its API on test1.

### 20. Top gotchas
- Pin `site-release` exactly and commit `Chart.lock` (a range needs `ecr:ListImages`, which the
  Promotion Manager can't do); use `oci://`, never `file://`.
- Exactly one values block, matching `routing`.
- Versioned: promote only `X.Y.Z` images built with `RELEASE_VERSION`.
- `503 site not released` before the first release is expected; promote one by hand.
- ApplicationSet `retry.limit: 2`; the Promotion Manager must be able to push to the manifests repo.

### 21. Status, and where the how-to and rules live
The status table above, re-checked for the date, in the deck's words ("available", "live on
develop", "being finalized"). Then where to go: the how-to (draft now; architecture-standards
`docs/how-to` after approval), the site-unit how-to (infrastructure-standards), the `site-release`
README, the proposed standards until they're published; Jira COREOPS-4535 / COREOPS-4536.

**How to start** (presenter, 2026-11-17): teams do this themselves, starting with the site unit in
their own `<product>-infrastructure` repo, with the how-to as the guide. The two DevOps steps stay as
the how-to has them (the ECR repository and the ArgoCD registration), and DevOps approves the unit.
No intake channel or contact person on the slide.

### 22. Coming next: MFEs on the shared CDN
Independently released MFEs, published once to `mfes/<org>/<pkg>/vX.Y.Z/` on the shared asset CDN
and pinned by the host's import map. A follow-on epic; **not built yet**. Until then, a shell whose
MFEs ship together is delivered as a site, like mfe-example.

## Diagrams

Made with the archify skill; the how-to's Mermaid diagrams are the specs. Every label is checked
against the how-to before it's used.

| | Diagram | Starting point |
|---|---|---|
| (a) | The four phases and what flows between them | how-to "The four phases" (new) |
| (b) | What the site unit creates; versioned-only parts set apart | how-to step 2; `site-topology` candidate.json |
| (c) | What a release does, in-place vs versioned | how-to "What a release does"; `site-publish` candidate.json |
| (d) | How a request is served under each method | how-to "How a request is served"; `site-request` candidate.json |
| (e) | CI flow | how-to step 5 (new) |
| (f) | CD flow: Promotion Manager → manifests repo → ArgoCD → publisher Job | how-to phase 4 |
| (opt) | test1 as an alias host on develop's distribution | `site-alias` candidate.json; else inline `dg-*` |

Embedding: exported SVG (or PNG) in `assets/diagrams/`, with light and dark variants if the export
doesn't follow the theme, switched the way the template switches themes; print uses the light one.
No archify HTML in iframes. Each diagram stays within the guide's 46% height limit; a diagram that
can't is split or simplified. The archify specs (`*.candidate.json`) are saved next to the exports and
listed in the deck README's Sources.

## Left to the builder

Visual design within the template; exact wording; section dividers or kickers; whether slide 9 is
trimmed to fit; how slide 7 lays out its two lanes (one diagram or two); the screenshot set on the
backup slide (taken in rehearsal); whether to commit the ~800 KB archify HTML outputs alongside the
specs (default: specs and exports only).

## Sources

- How-to (primary, the spine): `site-platform-strategy/deployment/docs/how-to-deliver-a-spa-as-a-site.md`
  (draft)
- Strategy: `site-platform-strategy/site-hosting-strategy.md` §4.0, §4.1–4.2, §4.4.3, §4.5, §4.9
- Proposed standards: `site-platform-strategy/proposed-standards.md` (§7, incl. 7.6 retention floor
  10; §8 for the MFE slide)
- Tracker: `site-platform-strategy/TRACKER.md`, session log to 2026-11-16
- vector-shared-terraform-modules `modules/site`: `site-v1.0.0`; branch
  `feat/COREOPS-4536-site-versioned-routing` (`6b60d6c`, v1.1.0): `variables.tf` (`routing`,
  `retention`), `functions/viewer-request-in-place.js` / `-versioned.js`, README
- vector-shared-helm-charts `charts/site-release/README.md` (0.3.1)
- mfe-example `main` (`51f4c18`): `helm/mfe-example` (0.4.0 on site-release 0.3.1), `Dockerfile`,
  `.github/workflows/ci.yml`, `projects/shell/webpack.config.js`; PRs #39, #40
- terragrunt-demo-infrastructure `application/mfe-example-site` (PR #19, open)
- SDS, the in-place example: sds-infrastructure `application/sds-site` (`unit_tf/main.tf`,
  `environments/test1/terragrunt.hcl`; PRs #4 and #6, merged) and sds `src/helm/sds-site`
  (`Chart.yaml`, `values.yaml`, `envs/values-test1.yaml`), `.github/workflows/ci.yml`; live check of
  `https://test1.vectorsds-nonprod.com/` and `/config.json` on 2026-11-17
- infrastructure-standards#39 (site-unit how-to, open)
- Archify diagrams (2026-11-06): `site-platform-strategy/diagrams/archify/` `site-topology`,
  `site-request`, `site-publish`, `site-alias`
- Live checks on 2026-11-17: `https://mfe-example.develop.vsp-nonprod.com/` serves 1.9.0
  (`<meta name="release-version" content="1.9.0">`); `gh` for PR states; git tags
- Jira: epic COREOPS-4535, story COREOPS-4536

## Decisions (presenter, 2026-11-17)

1. **Date**: "December 2026", no day.
2. **How teams start**: they do it themselves, in their own infra repo (slide 21). No help channel.
3. **Worked examples**: SDS for in-place, mfe-example for versioned.
4. **Demo prerequisites**, as planned: a release newer than 1.9.0 live on develop before the
   session; the presenter promotes in the Promotion Manager.
5. **keystone-cx-tools**: left out.
6. **Slug**: `2026-12-shipping-a-spa-as-a-site`.

## Open questions

None.
