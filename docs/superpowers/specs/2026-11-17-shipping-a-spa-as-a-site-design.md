# Shipping a SPA as a site — presentation design

**Date:** 2026-11-17; updated 2026-11-23 for `modules/site` v2, spa-example and the presenter's 2026-11-23
decisions
**Owner / presenter:** Noel Aguilar
**Deliverable:** a new presentation in this repo, `2026-12-shipping-a-spa-as-a-site/`, built from
`_template/` following [`CLAUDE.md`](../../../CLAUDE.md) and the
[presentation guide](../../presentation-guide.md).

## Intent

Explain how SPAs and MFE host shells are now delivered as **sites**, and enable teams to do it.
A site is, per environment, the CloudFront distribution, bucket, DNS records and certificate that
`modules/site` v2 creates, plus the viewer-request function (and, for versioned, the KeyValueStore)
that `modules/site-function` creates once per account and every environment's distribution attaches.
The deck covers the **four phases** in order (infrastructure → app repository → CI → CD), what each
produces and who owns it, and the **two release methods**, in-place and versioned: how they differ
and which to choose.

The tone is **inform and enable**. It is not asking for a decision. It ends with where the how-to
and the rules live, so a team can start on its own.

## Audience

Product dev teams and leads who build SPAs and MFE host shells, plus DevOps engineers.

- **They know** CI/CD, GitHub Actions, ArgoCD and AWS in general.
- **They don't know** `modules/site`, `modules/site-function`, the `site-release` chart,
  KeyValueStore routing, or the new names: *site*, the `-site` ECR repository, the function unit,
  `<app>-site-publisher`.
- **They care about** what they have to do and in what order; which method to pick; how a release
  and a rollback behave in production; and who to ask for each step.

## Goals

After the session, someone in the room should know:

1. **What a site is**, and what is delivered as one today: an SPA, or an MFE host shell whose MFEs
   ship in the same release (mfe-example). A frontend that runs as a pod is not a site.
2. **The four phases in order**, what each produces, what flows from one to the next, and who owns
   each step (DevOps or the product team), including the two infrastructure units.
3. **The two methods** and how they differ: what a release does to the bucket, how a request is
   served, rollback, the build changes, the image tag, and what happens before the first release.
4. **Which method to pick** (versioned is preferred), and that the choice is **made once per site**:
   switching an existing site isn't supported; you create a new site with the other method.
5. **How rollback and failed releases behave** under each method, and that the Promotion Manager's
   Rollback is the way to roll back.
6. **How environments relate**: each is its own distribution, sharing the site's one function and
   store in the account.
7. **Where the how-to and the rules live**, and what is still being finalized or not yet covered.

## Non-goals

- Every step of the how-to. The deck shows the order, the outputs, the owners and the few lines of
  config where the method shows; the how-to has the rest.
- How `modules/site`, `modules/site-function` or the `site-release` chart work inside: function
  code, Job script, IAM policy documents.
- The strategy's option analysis (why not nginx pods, why not the shared CDN for everything) and its
  decision log.
- Vanity domains (`modules/product-domains`), CSP and response-headers policies, WAF. Quotas only as
  the reason for one function per site per account.
- Production: not yet covered by the how-to; one status row.
- Frontends that run as pods. They're delivered like any EKS workload.
- Independently released MFEs on the shared CDN, beyond one "coming next" slide (Goal 1's boundary).

## Anti-goals

- **Reading like the how-to.** A wall of YAML and numbered steps. Snippets appear only where the
  method choice or the two units show.
- **Presenting anything unmerged or untried as done.** The how-to and infrastructure-standards #39,
  #43, #44 are "being finalized" unless merged by the presenting date; in-place and test
  environments on v2 are "not yet run"; production and vanity names "not yet covered".
- **Presenting the shared-CDN MFE model as how it works today.** It is coming, not built.
- **Restating facts differently from the sources.** Every number and name comes from the how-to, the
  modules, the chart or the standards (see "Facts the deck must state exactly").
- **Inventing timings.** Only quoted figures: about a minute for an in-place release; 6 to 31 s for
  spa-example's key to reach the Job's edge (others up to about a minute); a check of up to 180 s;
  about 12 minutes at most for a failed release with two retries.
- **Stale diagram labels** carried over from the 2026-11-06 archify diagrams (e.g. "Argo sync hook",
  `host_mode = site`), or a function per distribution.

## Constraints

- **45 minutes total, including Q&A**: about 38.5 minutes of slides and demo, 6.5 of questions.
- **Presented in December 2026.** The title slide says "December 2026", no day. Content is written
  as of **2026-11-23**, and every line in the status table below is re-checked before presenting.
- Repo conventions from `CLAUDE.md`: scaffold with `./new-presentation.sh`; self-contained
  `index.html`; every source in the deck README; `slides.md` exported; Index row in the root README;
  `_template/` untouched; no git commits or pushes without asking.

### Status as of 2026-11-23 (re-check before presenting)

| Item | Status on 2026-11-23 | How the deck says it |
|---|---|---|
| `modules/site` v2.0.0 + `modules/site-function` v1.0.1 | Tagged `site-v2.0.0` (#46, 2026-11-22) and `site-function-v1.0.1` (#47, 2026-11-21) | Available, both methods |
| `site-release` chart | `site-release@v0.4.1` | Available |
| spa-example on versioned, develop and staging (v2) | develop 1.0.3, staging 1.0.2, one function and store; staging promotion and Promotion Manager rollback verified, develop untouched | Live |
| SDS on in-place, test1 | `application/sds-site` on `site-v1.0.0` (test1 its only leaf); `src/helm/sds-site` on site-release 0.3.0; v2 under COREOPS-4776 | Live (v1) |
| In-place on v2; test environments on v2 | Not run yet | Not yet run |
| mfe-example (the MFE shell) | On `modules/site` v1 (`site-v1.1.0`, terragrunt-demo-infrastructure#19 open); v2 under COREOPS-4759 | Named once, on slide 3; notes only otherwise |
| The how-to | Refreshed 2026-11-23, waiting for approval; moves to cicd-standards `docs/how-to` (COREOPS-4543) | Being finalized |
| infrastructure-standards #39 (*Create a site unit*), #43 (§16), #44 (§17) | Open | Being finalized |
| Production; vanity names | Not covered by the how-to | Not yet covered |
| Jira | Epic COREOPS-4535; COREOPS-4543, 4759, 4776 | Cited on the status slide |

## Facts the deck must state exactly

From the how-to, `modules/site` `site-v2.0.0`, `modules/site-function` `site-function-v1.0.1`,
`site-release` 0.4.1 and proposed-standards:

- **Scope.** An SPA, or an MFE host shell whose MFEs ship in the same release (mfe-example), is
  delivered as a site. Independently released MFEs on the shared asset CDN
  (`mfes/<org>/<pkg>/vX.Y.Z/`) belong to a follow-on epic and aren't built yet.
- **Two units.** The function unit `platform/<app>-site-function` (leaves `nonprod`, `prod`) calls
  `modules/site-function`: the function, and for versioned the KeyValueStore, once per account,
  with the routing, API prefixes and redirect hosts; DevOps approves (`platform/`). The site unit
  `application/<app>-site`, a leaf per environment, calls `modules/site` v2 with the function from a
  `dependency`; the module issues the site's own certificate and writes records in `dns_zones`.
- **Why one function per account.** CloudFront Functions are a default quota of 100 per account,
  raisability unknown; CORE nonprod had 13 on 2026-11-19; one per distribution would cost a site
  five in nonprod.
- **Choose once.** `routing = "in-place" | "versioned"` on the function unit, required, no default.
  Switching an existing site isn't supported; create a new site with the other method.
- **The method is set twice and must match**: `routing` in the function unit, and exactly one values
  block in the chart, `site:` (versioned) or `inPlace:`. The render fails with neither, both, or an
  unknown key.
- **Versioned**: `X.Y.Z` versions; one KeyValueStore key per hostname; publish and rollback are one
  key write, no invalidation; `503 site not released` until the first release; retention keeps at
  least 10 non-live versions, never a live one; deletion is off by default. Each environment's
  `site.hosts` lists only its own hostnames (4.13).
- **In-place**: any tag; copy, then the `no-cache` entry files, then invalidate and wait, then sweep;
  `404` before the first release (not yet confirmed on v2). Reference app: SDS, on v1.
- **Worked examples** (presenter, 2026-11-23): **spa-example for versioned, SDS for in-place.** Every
  versioned value quoted on a slide comes from spa-example; every in-place one from SDS. vs-skills is
  not an example.
- **Rollback**: the Promotion Manager's Rollback (presenter, 2026-11-23), which restores that
  promotion's rendered manifests, `files:` included.
- **`site-release` 0.4.1** (spa-example; SDS 0.3.0), pinned exactly, with `Chart.lock` committed,
  from `oci://…/tooling/helm`.
- **Environments**: one distribution per environment, test environments included; they share the
  site's function and store in the account. Test hostnames as alias hosts on develop's distribution
  are the versioned-only alternative, for testing releases.
- **Names**: ECR `<product>/<app>-site` (`-site` = a data-only image, published, never run); function
  unit `platform/<app>-site-function`; site unit `application/<app>-site`; ServiceAccount
  `<app>-site-publisher`; SSM `/<product>/<env>/site[/<app>]`; chart `helm/<app>`; ApplicationSet
  `<app>-appset`; Argo app `<env>-<app>`.

## Structure and timing

| # | Section | Slide | ~Min |
|---|---|---|---|
| 1 | Opening | Title | 0.5 |
| 2 | | What you'll leave with: the order of the work, who owns it, which method, where the how-to is | 1 |
| 3 | What a site is | **A site is a hostname-rooted static origin**: the two modules; what's delivered as one, what isn't | 2 |
| 4 | | **The names**: one noun all the way through, with spa-example's and SDS's real values | 1.5 |
| 5 | The four phases | **Four phases, in order**: diagram (a) | 2 |
| 6 | | **Who does what**: each phase's output, owner and repo | 1.5 |
| 7 | Two methods | **What a release does**: diagram (c), in-place vs versioned | 2.5 |
| 8 | | **How a request is served**: diagram (d) | 1.5 |
| 9 | | **Side by side**: the comparison table | 1.5 |
| 10 | | **Which to choose, once**: versioned preferred | 1.5 |
| 11 | Phase by phase | **Phase 1, infrastructure**: diagram (b), the two units, why one function per account | 2.5 |
| 12 | | **Phase 2, the app repository**: the build fits the method; the two values blocks | 3 |
| 13 | | **Phase 3, CI**: diagram (e) | 1.5 |
| 14 | | **Phase 4, CD**: diagram (f) | 2 |
| 15 | Demo | **Live: promote forward, then roll back**, on spa-example staging | 5 |
| 16 | | Backup: the same in screenshots (used only if the demo fails) | 0 |
| 17 | After the first release | **Rollback and failed releases** | 2 |
| 18 | | **Each environment is its own distribution**: diagram (g) | 1.5 |
| 19 | | **An API through the site** (`/api/*`) | 1 |
| 20 | | **Top gotchas** | 1.5 |
| 21 | Where things stand | **Status, and where the how-to and rules live** | 2 |
| 22 | | **Coming next: MFEs on the shared CDN** | 1 |
| 23 | | Questions | 6.5 |
| | | **Total** | **45** |

About 23 slides. Section dividers are optional; if used, their time comes out of their section.

## Content by slide

### 2. What you'll leave with
- The order of the work and what each phase hands to the next.
- Who owns each step: DevOps does two steps and approves the units.
- Which method fits your app, and why you choose once.
- Where the how-to and the rules are.

### 3. A site is a hostname-rooted static origin
- **A site** = per environment, a CloudFront distribution and S3 bucket with DNS, its own
  certificate and the publisher's identity (`modules/site`); once per account, the viewer-request
  function (+ KeyValueStore for versioned, `modules/site-function`), attached by every environment's
  distribution. It doesn't care what the files are.
- **Delivered as a site today**: an SPA; an MFE host shell whose MFEs ship in the same release
  (mfe-example, the one place it's named on a slide; on v1 until COREOPS-4759).
- **Not a site**: a frontend that runs as a pod (delivered like any EKS workload); independently
  released MFEs (coming, slide 22).
- Vocabulary in one line each: *frontend*, *SPA*, *MFE*, *site*.

### 4. The names
Table: the pattern, then spa-example's value (versioned, develop) and SDS's (in-place, test1), for the
ECR repository, function unit, site unit, hostname, SSM prefix, publisher ServiceAccount and chart.
SDS has no function unit while on v1. Speaker notes: the function and store name, the ECR vs
Terraform product, `dev` vs `develop`, SDS's differences. Callout: **`-site` means a data-only image,
published and never run**.

### 5. Four phases, in order
Diagram (a). Phase 1 creates the function (once per account), the site (per environment) and the ECR
repository; their outputs fill in the chart in phase 2. Phase 3 turns the build into **one release
image**. Phase 4 renders the chart with that image and runs a Job that publishes the files.

### 6. Who does what
| Phase | Produces | Who | Where |
|---|---|---|---|
| 1. Infrastructure | Once per account: the function (+ store). Per environment: the site, SSM parameters, publisher role and ServiceAccount. The ECR repository | Product team, DevOps approves (both units); DevOps (ECR) | `<product>-infrastructure` (`platform/`, `application/`); lvsf-infrastructure |
| 2. App repository | A build that fits the method; `Dockerfile`; `helm/<app>/` | Product team | the app's repo |
| 3. CI | The release image in ECR, built once per version | Product team | `.github/workflows/` |
| 4. CD | ArgoCD registration; each promotion publishes | DevOps (registration); product team (promotions) | argo-app-of-apps; Promotion Manager UI |

### 7. What a release does
Diagram (c), two lanes, in-place (copy, entry files, invalidate, sweep) and versioned (upload, per-host
config, key write, check, revert on failure). Caption: spa-example's 6–31 s at the Job's edge.

### 8. How a request is served
Diagram (d). In-place serves `/index.html` from the bucket root. Versioned looks up the `Host` in the
KeyValueStore and rewrites into `/releases/<pkg>/<version>/`; a key per host is how one function and
store serve every environment.

### 9. Side by side
`.dense` table: going live, rolling back (Promotion Manager rollback), release check, hostnames,
runtime config, build and tag, old releases, before the first release, function unit `routing` and
chart block, examples (SDS on v1; spa-example on v2).

### 10. Which to choose, once
- **In-place**: a plain build; no instant rollback needed.
- **Versioned, preferred**: rollback is one key write, the release check reverts itself, a release
  per hostname, old releases kept, and it's the method proven on v2.
- Callout: **choose once**; switching means a new site with the other method.

### 11. Phase 1, infrastructure
- Diagram (b): the function unit (function, store) and the site unit (DNS, CloudFront with its own
  certificate, bucket, SSM, publisher; versioned-only `/config/*` and SSM).
- Snippet: the function unit's `routing` with `site-function-v1.0.1`; the site leaf's `function` from
  the dependency and `dns_zones`, with `site-v2.0.0`.
- Caption: why one function per account (100 by default, 13 in use, five per site otherwise).

### 12. Phase 2, the app repository
- No environment values in the image; browser config in `files:`, public.
- Versioned: `/releases/<pkg>/<version>/` from `RELEASE_VERSION`. In-place: a plain build.
- The chart pins `site-release` exactly, `Chart.lock` committed.
- Versioned: `site.hosts` lists only the environment's own hostnames.
- Snippets: spa-example's develop `site:` block and SDS's test1 `inPlace:` block.

### 13. Phase 3, CI
Diagram (e): push to `main`, version → build → check → `docker build` → tag in ECR? No: push; yes,
same commit: skip; yes, another commit: fail. spa-example's `ci.yml` is the versioned reference.

### 14. Phase 4, CD
Diagram (f). Register once (ApplicationSet with `retry.limit: 2` + promotion config); promote the
first release by hand; each higher environment adds a site leaf, values and a promotion entry.

### 15. Live: promote forward, then roll back
On spa-example staging (staging 1.0.2, develop 1.0.3 on 2026-11-23; the version is in the footer):
promote 1.0.3 to staging (one key write, the folder already there), then the Promotion Manager's
Rollback to 1.0.2; develop's footer stays on 1.0.3. Speaker notes carry the click path, the expected
wait and the fallback.

### 16. Backup
Staging's About page on 1.0.2 (2026-11-23), the how-to's staging rollback log, and two placeholders
for rehearsal screenshots (the Promotion Manager, the Argo app and its Job).

### 17. Rollback and failed releases
- **Rollback**: the Promotion Manager's Rollback; versioned only moves that environment's key;
  in-place is a full release of the earlier image.
- **Failures**: versioned reverts its keys within 180 s; in-place steps are safe to repeat.
- **Both**: ArgoCD retries twice, about 12 minutes at most.

### 18. Each environment is its own distribution
Diagram (g): spa-example's develop and staging distributions on one function and store, keys
develop 1.0.3 and staging 1.0.2; prod separate and not yet covered. A test environment is one more
site leaf. Alternative, versioned only: test hostnames as alias hosts on develop's distribution.

### 19. An API through the site
The `/api` prefix in the function unit, `api` in each site leaf; the API's site VirtualService; the
origin-verify check (R206.1); promote the API; the config's base URL `/api`. spa-example on develop
and staging; SDS on test1.

### 20. Top gotchas
Version range; the values block; branch images; `503` before the first release; the function unit
not applied; a values file listing another environment's host; retries.

### 21. Status, and where the how-to and rules live
The status table above, in the deck's words. Where to go: the how-to (moving to cicd-standards),
*Create a site unit* with §16 and §17, the `site-release` README; Jira COREOPS-4535, 4543, 4759,
4776. **How to start**: write the function unit and the site unit in your own infrastructure repo;
DevOps approves, creates the ECR repository and registers with ArgoCD; retire an old deploy once the
site serves the same environment.

### 22. Coming next: MFEs on the shared CDN
Independently released MFEs, published once to `mfes/<org>/<pkg>/vX.Y.Z/` on the shared asset CDN
and pinned by the host's import map. A follow-on epic; **not built yet**.

## Diagrams

Made with the archify skill; the how-to's Mermaid diagrams are the specs. Every label is checked
against the how-to before it's used.

| | Diagram | Starting point |
|---|---|---|
| (a) | The four phases, with the function unit | how-to "The four phases" |
| (b) | What the two units create; versioned-only parts set apart | how-to step 2, "What the two units create" |
| (c) | What a release does, in-place vs versioned | how-to "What a release does" |
| (d) | How a request is served under each method | how-to "How a request is served" |
| (e) | CI flow | how-to step 5 |
| (f) | CD flow: Promotion Manager → manifests repo → ArgoCD → publisher Job | how-to phase 4 |
| (g) | One function per site per account: develop and staging on one function and store | how-to step 8; TRACKER live facts |

Embedding: exported SVG in `assets/diagrams/`, light and dark variants switched with `<picture>`;
print uses the light one. Each diagram stays within the guide's 46% height limit. The archify specs
(`*.candidate.json`) are saved next to the exports and listed in the deck README.

## Left to the builder

Visual design within the template; exact wording; section dividers or kickers; whether slide 9 is
trimmed to fit; the screenshot set on the backup slide (taken in rehearsal); whether to commit the
~800 KB archify HTML outputs alongside the specs (default: specs and exports only).

## Sources

The deck README's Sources section is the complete list. The main ones:

- How-to (primary, the spine): `site-platform-strategy/deployment/docs/how-to-deliver-a-spa-as-a-site.md`
  (draft, rewritten and verified 2026-11-23)
- Plan: `site-platform-strategy/deployment/docs/plan-site-v2-and-site-example.md` §1–§2
- Strategy: `site-platform-strategy/site-hosting-strategy.md` §0, §4.0–4.2, §4.4.2–4.4.3, §4.5, §4.9
- Proposed standards: `site-platform-strategy/proposed-standards.md` (4.13; §7; §8 for the MFE slide)
- Tracker: `site-platform-strategy/TRACKER.md`, session log to 2026-11-23
- vector-shared-terraform-modules tags `site-v2.0.0`, `site-function-v1.0.1`; vector-shared-helm-charts
  `site-release@v0.4.1`
- spa-example `main`; terragrunt-demo-infrastructure #20 and #21; poc-rendered-k8s-manifests `818f695`
- SDS: sds-infrastructure `application/sds-site` and sds `src/helm/sds-site`
- infrastructure-standards #39, #43, #44
- Live checks and `gh` states on 2026-11-23

## Decisions (presenter)

2026-11-17:

1. **Date**: "December 2026", no day.
2. **How teams start**: they do it themselves, in their own infra repo (slide 21). No help channel.
3. **keystone-cx-tools**: left out.
4. **Slug**: `2026-12-shipping-a-spa-as-a-site`.

2026-11-23 (replacing the 2026-11-17 choices of mfe-example as the versioned example, a demo on
mfe-example develop, and "versioned preferred because alias hosts keep the function count down"):

5. **Worked examples**: spa-example (v2, develop and staging) for versioned, SDS for in-place;
   mfe-example named once, as an MFE shell, on v1 until COREOPS-4759.
6. **Demo**: on spa-example staging, promote 1.0.3, then the Promotion Manager's Rollback to 1.0.2;
   show develop unchanged.
7. **Versioned stays preferred**, for rollback, the self-reverting check, releases per hostname, old
   releases kept and being proven on v2; the quota explains one function per site per account on
   slide 11.
8. **Rollback**: the Promotion Manager's Rollback is the recommendation.

## Open questions

None.
