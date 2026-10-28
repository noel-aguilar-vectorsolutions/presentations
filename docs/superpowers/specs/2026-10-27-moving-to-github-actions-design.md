# GitHub Actions Strategy — presentation design

**Date:** 2026-10-27
**Owner / presenter:** Noel Aguilar
**Deliverable:** a new presentation in this repo, `moving-to-github-actions/`, built from `_template/`
following the conventions in [`CLAUDE.md`](../../../CLAUDE.md).

## Intent

Vector is moving application CI from CircleCI to GitHub Actions (GHA). This deck is the first
step in bringing development teams along: it **introduces and sells** what is changing in their
application repositories and how they will work day to day. It is a presentation with live demos,
not a hands-on workshop.

The tone is persuasive, not just informational: DevOps is offering a **paved road** — a suite of
supported, opinionated patterns it maintains — and the deck should make the case that adopting it
is better for teams than rolling their own.

## Audience

Development teams and their team leads: the people building the applications, who will use GHA to
build them. They know CircleCI and their own team's branching/release habits; they have not read
`cicd-standards`. They care about what they have to do differently, not how DevOps built it.

## Goals

After the session, a developer or team lead should:

1. Understand **why** we're moving: cost; Claude Code leans toward GitHub Actions, so AI-assisted
   pipeline work goes more smoothly there; and one integrated place (GitHub) instead of two
   (GitHub + CircleCI).
2. Understand the **paved road**: DevOps-maintained reusable workflows and actions, supported tech
   stacks, single-repo and monorepo support; that it's opinionated in exchange for consistency and
   less sprawl; that teams *can* opt out but then manage everything themselves.
3. Know **what changes in their repo** (the before/after list below).
4. Know that **Conventional Commits now matter** — the PR title sets the version — and that Claude
   can write them easily.
5. Understand the **three versioning strategies**, how they differ, and roughly which fits their
   team. Teams currently cutting release branches by hand should leave knowing they move to
   release-please with release branches.
6. Understand the **benefits of release-please**, especially the generated `CHANGELOG.md`.
7. Understand that **CI builds, CD promotes**: GHA never deploys; the ArgoCD Promotion Manager does.
8. Know **how migration happens**: DevOps defines the pattern and migration mechanism, will help and
   in many cases do the migration; teams that want to migrate themselves are supported.

## Non-goals

- A hands-on workshop or a workflow-YAML tutorial.
- Deep CD/ArgoCD internals beyond "CI stops at the image; the Promotion Manager promotes it".
- A CircleCI shutdown date (none is set; don't invent one).
- The org-level security audit itself (the deck uses its conclusions, not its findings list).

## Anti-goals (would make it a failure even if technically correct)

- Reading like a standards document — walls of MUST/SHOULD, tables of every rule. The standards
  exist; the deck points to them.
- Sounding like a mandate with no upside. Every "you must now…" should be paired with what the team
  gets for it.
- Inventing figures (e.g. cost savings) that no source supports.
- Demos with no fallback: a failed live demo must not stall the session.

## Constraints

- **60 minutes total**, including demos and Q&A.
- Repo conventions (from `CLAUDE.md`): created with `./new-presentation.sh moving-to-github-actions
  "<Title>"`; self-contained `index.html` (inline CSS/JS, no build step); images in `assets/`;
  CDN libraries only with a pinned version; `README.md` in the folder lists **every source**; add a
  row to the root `README.md` Index table; don't modify `_template/`.
- Slide markup: `<section class="slide">` in `<main class="deck">`; speaker notes in
  `<aside class="notes">`; utility classes `.title-slide`, `.two-col`, `.muted`, `.big`.
- Accuracy: content must match `cicd-standards` (Draft standards) and `github-actions` as of
  2026-10-27. Where a standard is Draft or Planned, the deck may say "being finalized".

## Structure and timing (decided)

| # | Section | ~Min |
|---|---|---|
| 1 | Title + **Why we're changing** — cost; Claude Code leans toward GHA; one place instead of two; consolidate rather than transcribe (CircleCI orbs grew apart and duplicate each other) | 4 |
| 2 | **The paved road** — what DevOps provides, opinionated ⇒ consistent, avoid sprawl, opt-out ⇒ self-managed, single + monorepo, how migration happens | 6 |
| 3 | **What changes in your repo** — before/after overview, then one slide per change | 8 |
| 3b | **GitHub hardening that affects you** — org-level security changes developers will feel | 4 |
| 4 | **Conventional Commits now drive versioning** — and Claude can write them | 4 |
| 5 | **Three ways to version** — comparison, how to choose, four-part → SemVer, manual release branches → release-please with release branches | 7 |
| 6 | **Demo 1: Continuous versioning** | 7 |
| 7 | **Why release-please** — the benefits | 3 |
| 8 | **Demo 2: release-please with release branches + CHANGELOG** | 9 |
| 9 | **CI builds, CD promotes** — no more CircleCI approval jobs | 3 |
| 10 | **What's next / getting help** | 2 |
| — | Q&A | 3 |

## Content by section

### 1. Why we're changing
Decided reasons (from the presenter): **cost**; **Claude Code tends to lean toward GitHub Actions**;
**cleaner integration in one place** rather than split between GitHub and CircleCI. Supporting point
from `github-actions` ADR-0001: the migration is the moment to **consolidate rather than transcribe**
— the CircleCI orbs overlap (e.g. `detect-changed-modules` in two orbs, image scanning implemented
three times) and are .NET-deep, Node-shallow.

### 2. The paved road
- Lives in `VectorLearning/github-actions`, maintained by DevOps.
- Reusable workflows: `app-ci` (the standard CI — plans changed modules, builds, tests, scans,
  publishes, validates charts, reports one `CI result`), `app-build-publish`, `app-sast`,
  `helm-validate`, `pr-title-lint`; release-please workflows to come.
- Actions grouped by domain: `docker`, `test`, `security`, `release`, `packages`, `helm`, `git`,
  `build` (plus `aws`, `iac`).
- A repo's `ci.yml` is a short caller of `app-ci`; `build-config.json` says what to build.
- Supported stacks: .NET, Node, Python, Java/Maven (per `app-sast`'s current coverage).
- Single-repo and monorepo both supported (a *module* = a folder versioned as one unit).
- **The trade:** opinionated, but consistent across every team, far less for each team to maintain,
  and no sprawl. Teams may opt out of the paved road; then they manage their pipeline themselves.
- **Migration:** DevOps defines the pattern and migration mechanism, helps, and in many cases does
  the migration; teams that want to self-migrate are supported.

### 3. What changes in your repo
One overview slide (before/after), then one slide each:

| | Before (CircleCI era) | After (GitHub Actions) |
|---|---|---|
| Branch protection | Each team had different rulesets | One **standardized** set of rulesets (from templates): `main`, `release/**`, `hotfix/**`, `v*` tags |
| Merging | Merge commits | **Squash only** — the PR title becomes the commit |
| Bot identity | `cibot` machine account committed to `main` and tagged | `vectorlearning-release` **GitHub App**: 1-hour tokens, tags and release PRs only, **no commits on `main`** |
| Version format | Four-part `X.Y.Z.N` | **SemVer `X.Y.Z`** (four-part is a legacy bridge only, not for new repos) |
| Dependencies | No Dependabot | **Dependabot** enabled |
| Actions | Anything | **Curated allowlist** of general-purpose actions; other third-party actions need security approval; actions **pinned by SHA** (detail in 3b) |
| Image tags | Moving `latest` / `main` tags | `<branch>-<run>` or the version; **no moving tags** |
| Deploys | CircleCI approval jobs (SPAs/MFEs, Lambdas) | GHA builds and packages only; **Promotion Manager** promotes |
| Branching | Git Branching @ Vector (manual `release/1.0.0`, merged back to `main`) | Feature naming unchanged; `release/X.Y.x` created automatically by release-please and **forward-ported** to `main`; new `hotfix/X.Y.x` (plain release-please) |

Branching detail — keep from the old standard: `<category>/<JIRA>-<description>` developer
branches (`feat/`, `fix/`, `chore/`), which now also become the image tag (`feat-DAR-102-107`).
Change: release branches are automatic, per minor version, and fixes forward-port instead of the
release branch merging back.

### 3b. GitHub hardening that affects you
The presenter asked to include the GitHub hardening work because it has developer impact. Framed
as "what you'll notice and what to do", not as audit findings. Candidates from the remediation
backlog (`github-security-review/remediation-backlog.md`), each with its developer impact:

| Backlog | Change | What a developer notices |
|---|---|---|
| GHSEC-03 / 10 | **2FA enforced org-wide** | Members without 2FA are removed from the org at enforcement — enroll before the deadline |
| GHSEC-01 | `GITHUB_TOKEN` defaults to **read-only**; Actions can't approve PRs | Workflows that write must declare `permissions:` explicitly |
| GHSEC-05 | **SHA pinning required** org-wide | `uses: owner/action@v4` fails; must be `@<full-sha> # v4`, Dependabot bumps it |
| GHSEC-06 | **Allowed actions: selected** (curated allowlist) | Non-allowlisted third-party actions fail; request security approval |
| GHSEC-08 | **Org-level branch-protection ruleset** | Baseline protection on every repo, on top of the standard repo rulesets |
| GHSEC-04 | **Dependabot** alerts + security updates | Dependabot PRs appear and need triage |
| GHSEC-12 | **OIDC to AWS**, static AWS keys deleted | No AWS keys in secrets; workflows assume a role via OIDC |
| GHSEC-09 | `claude-review.yml` pattern hardened | Claude review workflows change shape |
| GHSEC-15 | Public repo creation restricted to owners | Can't create public repos yourself |
| GHSEC-11 / 17 | Wikis disabled; stale repos archived | Use docs in repo / Confluence; old repos become read-only |

Which of these go in the deck is an open question (below). The curated-actions and SHA-pinning
points move here from section 3's table (section 3 keeps a one-line pointer).

### 4. Conventional Commits
- Were "always use them" in the old branching page; now they **set the version**: `fix:` → patch,
  `feat:` → minor, `!` / `BREAKING CHANGE` → major.
- What matters is the **PR title** (squash merge makes it the commit); a required check
  (`PR / Lint PR title`) enforces it, because a wrong title on a protected branch can't be fixed
  and means a wrong version.
- **Claude can do this easily** — show asking Claude Code to write the PR title/commit message.

### 5. Three ways to version
Side-by-side comparison of **Continuous versioning**, **plain release-please**, **release-please with
release branches** — keep to the rows a team lead decides on: when a version is cut, batching,
changelog, what happens when regression fails, hotfix while `main` has unreleased work, and "pick
this if…". All three: cut ≠ released (released = promoted to production); none is the default.
Plus: moving off four-part `X.Y.Z.N`; teams that cut release branches by hand today → release-please
with release branches.

### 6. Demo 1 — Continuous versioning
Show a merge to `main` cutting a version (git tag + image tagged with the version), and a branch
build tagged `<branch>-<run>`.

### 7. Why release-please
Version computed from PR titles, not chosen by a person; the release PR previews exactly what ships;
`CHANGELOG.md` and GitHub Release generated automatically; the tested image is re-tagged, not
rebuilt; no bot commits on `main` (a human approves the release PR).

### 8. Demo 2 — release-please with release branches
Show the release PR with its generated `CHANGELOG.md`, merging it to cut the version, the
`release/X.Y.x` branch being created automatically, and (if time) a fix on the release branch being
forward-ported.

### 9. CI builds, CD promotes
SPAs/MFEs and Lambdas used CircleCI's approval feature to deploy — no longer. They move to a GitOps
approach and use the ArgoCD Promotion Manager extension, like EKS services. GHA builds and packages,
never promotes. Part of the reason: GitHub's deployment approvals (environment protection
reviewers) need Enterprise and we're on the Team plan. Production promotion is a PR to
`rendered-k8s-manifests`, approved by the CODEOWNERS reviewer. Build once, promote many.

### 10. What's next
How migration happens (DevOps-led or self-serve, supported), where the standards and how-tos live
(`cicd-standards`, `github-actions`), who to ask.

## Left to the builder

- Visual design, within the template.
- Exact slide count and wording within each section's time budget.
- Diagrams (e.g. the three strategies as branch timelines; CI → ECR → Promotion Manager → namespaces).
- Speaker notes: talking points for every slide, click-by-click steps on demo slides.
- Demo fallback: a slide per demo with screenshots/recorded steps (builder captures or leaves
  clearly marked placeholders in `assets/`).
- README sources: all items listed below.

## Sources

- `~/workspaces/VectorLearning/cicd-standards` — README, `docs/ci/versioning.md`,
  `versioning-continuous.md`, `versioning-release-please.md`, `release-github-app.md`, how-tos,
  `templates/`.
- `~/workspaces/VectorLearning/github-actions` — README, ADR-0001 (incl. 2026-09-26 amendments).
- `~/workspaces/cowork/github-security-review` — `github-org-security-review.md` (Actions baseline)
  and `remediation-backlog.md` (GHSEC items for section 3b).
- Confluence: [Git Branching @ Vector](https://lmsportal.atlassian.net/wiki/spaces/PE/pages/26994278421/Git+Branching+Vector).
- Noel Aguilar (presenter) — reasons for the move, paved-road framing, before/after changes, demo
  choices, CD change for SPAs/Lambdas.

## Scope decision

Presenter (2026-10-27): **keep every section in**, build it, measure how long it runs, then the
presenter decides what to cut. So every slide's speaker notes carry a time estimate, and the deck
README carries a running-time table by section.

## Builder's calls (pending presenter review)

Raised by the builder check; settled conservatively so no slide claims more than the sources show.

1. **Demo 2 (release-please with release branches)** — not yet live-tested (COREOPS-4428 demo repo
   pending). Built as a guided walkthrough with screenshot placeholders in `assets/`, and speaker
   notes for running it live if the demo repo exists by the session. Section 7 claims are stated as
   the design, marked "being finalized" where unverified.
2. **Stacks** — "**.NET today**; Node, Python and Java on the roadmap" (`app-ci` implements only
   `dotnet`; `app-sast` scans all four).
3. **SPAs/MFEs and Lambdas** — stated as the presenter described it (GitOps + Promotion Manager),
   with "delivery standard being written" since `cicd-standards` hasn't covered them yet.
4. **Hardening** — all section-3b items included, phrased as "rolling out"; **no 2FA date** ("date
   to be announced").
5. **Pinning** — the deck says: third-party and composite actions **must** be SHA-pinned (the org
   policy enforces it); Vector's **reusable workflows are exempt** from the policy. The `ci.yml`
   snippet is shown as the template has it. (Avoids contradicting either the presenter or the
   template; presenter to confirm the recommendation.)
6. **Monorepos** — Continuous versioning supports them today; release-please is single-module
   for now, monorepo support to come.

## Open questions

- **Which hardening items to include, and their status.** Section 3b lists candidates from the
  remediation backlog. Which are committed (vs. proposed), and is there a 2FA deadline to announce?

- **SHA pinning of the standard workflows.** Presenter said standard CI workflows won't be
  SHA-pinned. GitHub's SHA-pinning policy exempts reusable workflows, so tags are *allowed* — but
  ADR-0001's 2026-09-26 amendment makes SHA the default for callers of reusable workflows too
  (canary repos excepted), and the `cicd-standards` `ci.yml` template pins `app-ci.yml` by SHA.
  Which does the deck say?
