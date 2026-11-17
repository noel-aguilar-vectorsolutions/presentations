# Branching and Versioning: choosing a strategy — presentation design

**Date:** 2026-11-17
**Owner / presenter:** Noel Aguilar
**Session:** 2026-11-18, 60 minutes
**Deliverable:** a new presentation in this repo, `2026-11-branching-and-versioning/`, built from
`_template/` following [`CLAUDE.md`](../../../CLAUDE.md) and the
[presentation guide](../../presentation-guide.md); and three demo repositories staged and rehearsed
once before the session.

## Intent

Help each project's tech lead **decide which versioning strategy fits their product**: Continuous
versioning, plain release-please, or release-please with release branches. The tone is **inform so
they can decide**: what each strategy is, how its git branches behave, what SemVer means under it,
what goes wrong, and which questions point to which strategy. Each strategy is shown working in a
live demo.

## Audience

Tech leads of the projects. They have seen *Moving to GitHub Actions* (2026-10-27), so they have
heard of the three strategies, squash merge and Conventional Commits at overview level. They have
**not** read the versioning standards in cicd-standards. They care about how their team will work
day to day, what happens when a release goes wrong, and what they have to decide.

## Goals

After the session, a tech lead should:

1. Remember the basics from the earlier deck and why they matter more than they looked: squash
   merge makes the PR title the commit, and the title sets the version.
2. Understand SemVer (`X.Y.Z`, what bumps what) and **how each strategy applies it differently**.
3. Be able to draw each strategy's branches: `main` only; `main` plus an on-demand `hotfix/X.Y.x`;
   `main` plus an automatic `release/X.Y.x` per minor version with forward-ports.
4. Know what happens in each strategy when **regression fails**, when **production needs a hotfix
   while `main` has unreleased work**, and when a **breaking change** ships.
5. Know what the **rulesets** protect and why **squash merge** is required.
6. Know the **gotchas** before they hit them.
7. Know the **four-part format is legacy** and on its way out.
8. Leave able to **pick a strategy** with the decision flow, and with a one-page cheat sheet.

## Non-goals

- Configuration walkthroughs. Files are named (`version-config.json`, `release-please-config.json`,
  the caller workflow, the ruleset templates) with one line on what each decides, never opened line
  by line.
- Setting up a repository. The how-tos in cicd-standards cover it; the deck links them.
- CD and the ArgoCD Promotion Manager beyond "cut is not released; promotion releases".
- Library internals (`compute-versions`, the re-tag, the version check) beyond what a lead sees.

## Anti-goals

- Reading like the standards: walls of MUST/SHOULD, every rule in a table.
- Picking a winner. None of the three is the default; the deck helps them choose.
- Repeating *Moving to GitHub Actions* slide for slide. The recap is a refresher that builds toward
  the new material, not a rerun.
- Claims the demos or the standards don't support. Where the standards say something is unproven
  (multi-module release branches, a `linked-versions` group's own PRs), the deck says so.
- A demo that stalls the session: every demo has a backup slide.

## Constraints

- **60 minutes total**, including three 5-minute live demos and Q&A.
- Accurate as of **2026-11-18**, against cicd-standards `main` (`72b4b84`) and github-actions
  `main` (`28a60e8`, release `v0.2.3`).
- Repo conventions: scaffold with `./new-presentation.sh`; self-contained `index.html`; inline SVG
  diagrams with the template's `dg-*` classes; speaker notes with `⏱` on every slide; every source
  in the deck README; `slides.md` exported; Index row in the root README.
- **One day to build.** The deck and the demo setup run as two tracks in parallel.

## Approaches

| Approach | Trade-off | Decision |
|---|---|---|
| Deck and demos in parallel | Demo screenshots arrive late for the backup slides, so those slides are filled last | **Chosen** |
| Deck first, then demos | Rehearsal squeezed into the night before | Rejected |
| Demos first, then deck | Deck review squeezed | Rejected |

For the release-branches demo, a new repository, `release-please-branches-demo` (created by the
presenter), rather than switching `release-please-demo` or `release-please-monorepo-demo`, so the
plain and release-branches demos stand side by side and nothing is toggled.

## Structure and timing

| # | Section | Min |
|---|---|---|
| 1 | Title, agenda, and why the choice matters | 2 |
| 2 | Recap from *Moving to GitHub Actions* | 5 |
| 3 | SemVer, and how each strategy applies it | 4 |
| 4 | Continuous versioning: how it works, then **Demo 1** | 4 + 5 |
| 5 | Plain release-please: how it works, then **Demo 2** | 4 + 5 |
| 6 | release-please with release branches: how it works, then **Demo 3** | 4 + 5 |
| 7 | Side by side, and three scenarios | 6 |
| 8 | Rulesets and squash merge: what they protect | 3 |
| 9 | Gotchas | 4 |
| 10 | The legacy four-part format (deprecated) | 1.5 |
| 11 | Decision flow, cheat sheet, where to read more | 3 |
| — | Q&A | 4.5 |
| | **Total** | **60** |

About 30 slides, plus three demo slides and three backup slides.

## Content by section

### 1. Why the choice matters
- A repository uses exactly one strategy, for all its modules, and rarely changes it once started.
- The choice depends on how the team works, mostly: **do you keep merging to `main` while a version
  is in regression?** and **must you hotfix production without shipping unreleased work?**
- Agenda.

### 2. Recap (about 5 minutes)
- **Squash merge**: one PR becomes one commit on `main`, and its title is the commit message.
- **The title sets the version**: four recommended types, `feat` (minor), `fix` (patch), `docs` and
  `chore` (no release under release-please), `!` or `BREAKING CHANGE:` for a breaking change. CVE
  bumps are `fix(deps):`, routine bumps `chore(deps):`.
- **A wrong title can't be fixed** once it is a commit on a protected branch; the PR-title check is
  the only cheap place to catch it.
- **Cut is not released**: a version is cut when its tag is created and released when the Promotion
  Manager promotes it to production. A cut version that never ships is normal.
- **Branch names and image tags**: `feat/DAR-102-search` builds image `feat-DAR-102-search-107`
  (`<branch>-<run>`); no moving tags (`latest`, `main`); version tags are `vX.Y.Z` in git and
  `X.Y.Z` on images.
- **Not merged = not shipped**: anything merged to `main` is in the next version. Unready work stays
  unmerged or behind a feature flag. A merged change only comes out with a `revert:` PR.

### 3. SemVer, and how each strategy applies it
- `MAJOR.MINOR.PATCH`: breaking, feature, fix. One version, one tag, never moved.
- How the same PR titles turn into versions under each strategy (the core table of the deck):

| Title | Continuous versioning | Plain release-please | Release branches (`main`) | Release branch |
|---|---|---|---|---|
| `fix:` | patch | patch | minor (`always-bump-minor`) | patch (`always-bump-patch`) |
| `feat:` | minor | minor | minor | patch, with a warning on the PR (revert it by default, or keep it on purpose) |
| `feat!:` | major | major (unless the team sets `always-bump-minor`) | needs `Release-As: X.0.0`; the version check fails without it | still a patch, with a stronger warning; majors come from `main` |
| `chore:` / `docs:` | **patch**, if it changes the module's files | **no release** | no release | no release |
| When it's cut | every merge to `main` that builds | when someone merges the release PR | when someone merges the release PR | when someone merges that branch's release PR |

- Under Continuous versioning a patch means "a build shipped", not "a bug was fixed".
- Under release-please the type decides **whether** a change releases at all; `Release-As` forces a
  version (for example to release a `chore:` on its own).
- Monorepo: one version line per module, tags `<component>@vX.Y.Z`.

### 4. Continuous versioning
- Git diagram: `main` only, a tag on every merge that changes a module; topic branches build
  `<branch>-<run>` images and never get a version.
- No release PR, no changelog, no GitHub Release; git tags are the record of versions.
- Only changed modules build; a docs-only change builds nothing.
- Hotfix while `main` has unreleased work: **not covered**. The fix ships with everything merged.
- Fits: a team that ships each change as it lands; a service monorepo whose modules share files or
  code (`extra-paths`).
- Files, one line each: `version-config.json` (modules, format), `build-config.json` (what to build).
- **Demo 1** (`poc_echo_server_dotnet`, last tag `v1.3.0`): a `feat:` PR is staged with its branch
  build green, image `feat-…-<run>`. Live: squash-merge; the `main` build computes `1.4.0`, pushes
  image `1.4.0`, tags `v1.4.0`. While it runs, show the `versions` job's reasoning.

### 5. Plain release-please
- Git diagram: `main` only; release PR collects merges; merging it tags `vX.Y.Z`; an optional
  `hotfix/X.Y.x` branch cut from the production tag **only when** `main` has moved on, with a
  forward-port back to `main`.
- `main` builds `main-<run>` images; merging the release PR tags the commit and **re-tags the
  tested image** with the version, no rebuild.
- `CHANGELOG.md` and a GitHub Release are generated from the PR titles.
- Regression fails: fix on `main`, and **hold other merges** to keep the next version small.
- Fits: a team that ships several changes together, on a schedule or after regression, and can hold
  merges during regression.
- Files, one line each: `release-please-config.json`, `.release-please-manifest.json`, the caller
  `release-please.yml` (which reusable workflow decides the strategy).
- **Demo 2** (`release-please-demo`, last release `echo@v4.5.0`, component tags): a `feat:` and a
  `fix:` already merged, so the release PR proposes `4.6.0` with its changelog. Live: read the
  release PR, merge it; show tag `echo@v4.6.0`, the GitHub Release, the re-tag job adding `4.6.0` to
  the image `main` already built. Point at the existing `hotfix/4.4.x` as what a hotfix looks like.

### 6. release-please with release branches
- Git diagram: `main` plus `release/X.Y.x` created **automatically** for every `X.Y.0`; a fix on the
  release branch releases a patch and is **forward-ported automatically** (the release App opens the
  PR to `main` and to each newer release branch; the developer merges it). The release branch is
  never merged back.
- One release branch per minor version; several can be live at once (production on `1.0.2` while
  `1.1.0` is in regression).
- `main` never releases a patch (`always-bump-minor`); a major needs `Release-As`, enforced by the
  release PR version check.
- Regression fails: fix on `release/X.Y.x` while `main` keeps moving.
- Fits: a team that keeps merging during regression, or must hotfix production without shipping
  unreleased work. Teams that cut release branches by hand today move here.
- Correction to the October deck: forward-ports are **automatic** now (the forward-port job in
  `app-release-please-release-branches.yml`), except a change to a workflow file, which is labelled
  `forward-port-needed` and ported by hand.
- **Demo 3** (`release-please-branches-demo`): staged before the session, `v1.0.0` cut (which created
  `release/1.0.x`), a `feat:` merged to `main` and unreleased, a `fix:` merged to `release/1.0.x`,
  and its `1.0.1` release PR open. Live: merge the `1.0.1` release PR; show tag `v1.0.1`, the
  re-tagged image, and the forward-port PR to `main` opening by itself, while `main`'s release PR
  still proposes `1.1.0`. Briefly open the repository's rulesets page.

### 7. Side by side, and three scenarios
- One comparison table, limited to the rows a lead decides on: when a version is cut, batching,
  changelog, regression fails, hotfix while `main` has unreleased work, `main` releases patches,
  majors, monorepo fit, merge method.
- Three scenarios, each a small git diagram per strategy:
  1. **Regression fails** on the version in staging.
  2. **Urgent hotfix** while `main` has unreleased work.
  3. **A breaking change** ships.

### 8. Rulesets and squash merge
- **Squash only** (repository setting): one PR, one commit, one title, so the version is computed
  from titles people reviewed. Continuous versioning's SemVer format fails the build on a merge
  commit; release-please requires squash.
- **Branch ruleset** on `main`, `release/**`, `hotfix/**`: PR required, PR-title check, build, and
  the release PR version check required; up to date before merging; no direct or force pushes.
- **Branch creation**: only the release App creates `release/**`; the App or a Technical Owner
  creates `hotfix/**`; only Technical Owners delete them.
- **Tag rulesets** on `v*` and `*@v*`: only the release App creates version tags; nobody updates or
  deletes them. release-please finds its last release by its tag, so a moved tag breaks the next
  version. (Continuous versioning creates tags with `GITHUB_TOKEN`, so there only update and delete
  are blocked.)
- **Code owner approval** on every PR, the release PR included, so the release App can't open and
  merge a PR with no person involved.
- Templates live in cicd-standards `templates/`; the setup how-tos apply them.

### 9. Gotchas
- **Up to date before merging** applies to every PR, not only the release PR: after any merge, other
  open PRs need **Update branch**.
- **Update branch on a release PR** only after merges that release nothing (`docs:`, `chore:`).
  After a `feat:`/`fix:`, wait a minute for release-please to rewrite it. Never **Update with
  rebase** on a release PR.
- **A release PR blocked with every check green**: the version check was cancelled; re-run it
  (COREOPS-4698).
- **`always-bump-minor` hides majors**: a `feat!:` ships as a minor without `Release-As`; the version
  check catches it on `main`.
- **A `fix:` that only touches docs or workflow files** releases a version no build made an image for,
  and the re-tag fails. Title such changes `docs:` or `chore:`.
- **Every live release or hotfix branch keeps its own caller workflow**: a library pin bump is a PR
  into each.
- **A workflow-file change is forward-ported by hand** (`forward-port-needed` label).
- **The hotfix button can't branch from an older tag** whose workflow files differ; a Technical
  Owner creates it by hand.
- **GitHub's "Latest" release** is the one created last, which can be a patch on an older line; use
  the environment's version, not Latest.
- **The running image doesn't know its version** under release-please (it was built before the
  version existed); inject it at deploy time if the app reports one.
- **Revert**: under Continuous versioning a revert is a new version (patch); a revert never
  removes the original from release-please's changelog.
- **A `feat:` merged into a release branch ships in a patch**: the workflow warns on the PR but
  doesn't block it; the Technical Owner reverts it (default) or keeps it on purpose.
- **Monorepos under release-please**: modules can't share code directly unless they're in one
  `linked-versions` group; a change only to shared code releases nothing. That shape fits
  Continuous versioning.

### 10. The legacy four-part format
- `X.Y.Z.N` (for example `1.4.0.7284`), from dynamo-config; merge commits allowed; not SemVer (npm
  can't publish it); the build number comes from the run number plus `run-number-offset`, so
  renaming `ci.yml` breaks it.
- Legacy, not recommended, to be deprecated; no new repository uses it. Moving to SemVer: squash
  only, `version-format: semver`, `initial-version` above the last `X.Y.Z` (after `v1.4.2.2087`,
  `1.4.3` or `1.5.0`).
- Shown, not demoed: `poc_echo_server_dotnet_legacy`'s tags (`v1.3.1.2019`).

### 11. Decision flow, cheat sheet, where to read more
- Decision flow, as a diagram:
  1. Do you ship each change as it lands? → Continuous versioning.
  2. Do you batch changes and test them before release? → release-please.
  3. Must you keep merging to `main` while a version is in regression, or hotfix production without
     shipping unreleased work, often? → release branches. Otherwise → plain release-please.
  4. Monorepo with shared code between independently released modules? → Continuous versioning.
- Cheat sheet: one slide, printable, summarizing branches, when a version is cut, how titles bump,
  fixes and hotfixes, per strategy.
- Links: cicd-standards `docs/ci/versioning.md`, the two strategy documents, the fixes-and-hotfixes
  how-to, the scenario references; github-actions workflows README.

## Demo preparation (track 1)

All three are staged before the session, rehearsed once, and screenshotted at each step for the
backup slides.

| Demo | Repository | Staged beforehand | Live action |
|---|---|---|---|
| 1 | `poc_echo_server_dotnet` | `feat:` PR with green branch build; nothing else unreleased on `main` | Squash-merge; watch `v1.4.0` |
| 2 | `release-please-demo` | `feat:` and `fix:` merged; release PR proposing `4.6.0` | Merge release PR; tag, Release, re-tag |
| 3 | `release-please-branches-demo` | Seeded, settings and rulesets applied, release App installed; `v1.0.0` cut, `release/1.0.x` exists; `feat:` on `main` unreleased; `fix:` on `release/1.0.x`; `1.0.1` release PR open | Merge `1.0.1` release PR; tag, re-tag, forward-port PR opens |

`release-please-branches-demo` setup:
- Seeded from `release-please-demo`'s tree (the .NET echo service), with a fresh history.
- Plain `vX.Y.Z` tags (`include-component-in-tag: false`), so it contrasts with demo 2's
  `echo@vX.Y.Z`; `main` on `always-bump-minor`; the release-branch config on `always-bump-patch`.
- Images under namespace `noel`, renamed `rpb-echo.*` so their `main-<run>` tags can't clash with
  `release-please-demo`'s.
- Repository settings and rulesets from cicd-standards `templates/release-please/`, with one
  approver's adjustments as on the other demo repos (approvals 0, code owner review off).
- Release App: github-org-config#19, then the presenter runs `ghorg apps sync-repos
  vectorlearning-release`, dry run then `--apply`.

## Left to the builder

- Visual design within the template; slide wording within each section's time.
- The git diagrams (inline SVG, `dg-*` classes), drawn consistently across the strategies so the
  differences stand out.
- Speaker notes with click-by-click steps on demo slides.
- Backup slides filled with screenshots from the rehearsal.

## Sources

- `~/workspaces/VectorLearning/cicd-standards` @ `72b4b84`: `docs/ci/versioning.md`,
  `versioning-continuous.md`, `versioning-release-please.md`, `release-github-app.md`,
  `docs/how-to/release-please-fixes-and-hotfixes.md`, `set-up-*.md`,
  `docs/reference/versioning-*-scenarios.md`, `templates/`.
- `~/workspaces/VectorLearning/github-actions` @ `28a60e8`: `.github/workflows/app-release-please*.yml`
  (forward-port job), ADR-0001, ADR-0002.
- The earlier deck: `moving-to-github-actions/` (what the audience already saw).
- Demo repositories: `poc_echo_server_dotnet`, `poc_echo_server_dotnet_legacy`,
  `release-please-demo`, `release-please-branches-demo`.
- Noel Aguilar (presenter): audience, length, demo choices, emphasis on rulesets, squash merge and
  the recap.

## Builder's calls (from the builder check)

1. **Rehearsal uses up the staged state.** Tags can't be deleted, so each demo is rehearsed end to
   end once, then staged again for the session. Slides name versions relatively ("the next minor",
   "the next patch"); the speaker notes carry the exact numbers expected live, updated after
   re-staging. Backup screenshots come from the rehearsal, one version lower than the live run,
   and the notes say so.
2. **Order for demo 3:** seed history pushed first, then repository settings and rulesets (as on
   `release-please-monorepo-demo`), then the first build once the release App is synced. The
   release App's access lists for `GH_APP_CLIENT_ID_RELEASE` and `GH_APP_PRIVATE_KEY_RELEASE` are
   set by the same `sync-repos --apply`. The OIDC role's trust admitted the other demo repos
   without changes; the first push confirms it for this one.
3. **Claims are checked against cicd-standards** by the presenter's session while writing the spec
   (the bump table, rulesets and gotchas); the builder doesn't re-verify each one.
4. **`poc_echo_server_dotnet` PR #16** (a CircleCI-era `feat:` that changes only `src/Common`, which
   is no module) is left alone; demo 1 uses a new `feat:` PR that changes `src/Services/Echo`.

## Open questions

- None blocking.
