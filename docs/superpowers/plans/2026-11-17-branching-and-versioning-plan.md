# Branching and Versioning deck and demos — Implementation Plan

> **For agentic workers:** Two tracks run in parallel. Track D (demos) runs as one background agent; track P (deck) runs in the main session. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** a 60-minute deck, `2026-11-branching-and-versioning/`, and three demo repositories staged, rehearsed once, and re-staged for the 2026-11-18 session.

**Architecture:** the deck is the template's self-contained `index.html` with inline SVG git diagrams. Each demo has an idempotent-ish stage script in the deck's `demo/` folder, so it can be re-staged after any rehearsal; the rehearsal's outputs (`gh` JSON and text) are saved under `demo/captures/` and feed the backup slides.

**Tech Stack:** HTML/CSS/SVG (template), bash + `gh` + `git` for the demos, headless Chrome via `check-presentation.sh`.

**Spec:** `docs/superpowers/specs/2026-11-17-branching-and-versioning-design.md`

## Global Constraints

- Deck slug `2026-11-branching-and-versioning`; title "Branching and Versioning: Choosing a Strategy".
- 60 minutes; demo sections 5 minutes each; ⏱ on every slide's notes; running-time table in the deck README totalling 60.
- Colours only through template tokens; text never below `.55em`; deck-only CSS at the end under `/* Additions for this deck */`.
- Slides name versions relatively ("the next minor"); speaker notes carry the exact expected numbers.
- Every source recorded in the deck README in the same change; `slides.md` regenerated with `./export-markdown.py`.
- Demo repos: merge freely; never delete tags; never move a version tag; PR titles are Conventional Commits; every commit and PR ends with the attribution lines.
- Library pin for the new demo: `VectorLearning/github-actions/...@3328b1e052a80b9371a19d7bb0088a8b32ce1687 # v0.2.0`, the same as the other demos and the cicd-standards templates.

## Review Focus

1. A release PR left behind `main` (up-to-date rule) during the live demo: stage scripts finish with the release PR mergeable (`mergeStateStatus == CLEAN`), checked.
2. The first release of the new repo proposing `0.1.0` instead of `1.0.0`: the seed's first `feat:` carries `Release-As: 1.0.0`.
3. A re-tag failing because the image wasn't built: the staged merges change files under `src/Services/Echo`, never only docs.
4. Image-name clashes: new repo images are `rpb-echo.*`, checked in `build-config.json` before the first push.
5. Diagrams unreadable in dark mode or at 1440×900: `check-presentation.sh` at both sizes, both themes.

---

## Track D — demos (background agent)

### Task D1: Seed and configure `release-please-branches-demo`

**Files (in `~/workspaces/VectorLearning/release-please-branches-demo`, a fresh clone):** the tree of `release-please-demo@origin/main` minus `.git`, with:
- `build-config.json`: images renamed `rpb-echo.api`, `rpb-echo.backgroundtasks`, `rpb-echo.migrations`, `rpb-echo.integrationtests` (push false); `image-namespace` stays `noel`.
- `release-please-config.json`: `release-type: simple`, `include-component-in-tag: false`, no `tag-separator`, `exclude-paths: ["src/helm", "docs", ".github"]`, `versioning: always-bump-minor`, package `"."` with no component. `release-please-config.release-branch.json` deleted unless the reusable workflow reads it (check the workflow's header for the file name it writes on the release branch).
- `.release-please-manifest.json`: `{".": "0.0.0"}`; `CHANGELOG.md` removed.
- `.github/workflows/release-please.yml`: cicd-standards `templates/workflows/release-please-release-branches.yml` verbatim.
- `ci.yml`, `pr-title.yml`: from `release-please-demo`, unchanged.
- `README.md`: short, says it is the release-branches demo for the 2026-11-18 session.

- [ ] Push the seed as one commit to `main`: `chore: seed the release-branches demo from release-please-demo` (empty repo, no rulesets yet).
- [ ] Apply settings from cicd-standards `templates/release-please/repository-settings.json` (`gh api -X PATCH repos/VectorLearning/release-please-branches-demo --input …`). Verify: squash only.
- [ ] Copy the seven rulesets from `release-please-demo` (`gh api repos/VectorLearning/release-please-demo/rulesets/<id>` for ids 26330691, 26330690, 26330689, 26330688, 26330670, 26330683, 26330681), dropping read-only fields (`id`, `source`, `source_type`, `node_id`, `_links`, `created_at`, `updated_at`, `current_user_can_bypass`), POST each to the new repo. Verify: 7 rulesets, same names.
- [ ] Verify the seed push's CI run is green and pushed `noel/rpb-echo.api:main-<run>`. If AWS login fails, stop and report.
- [ ] First release: PR `feat(echo): say which demo answers (…)` changing `src/Services/Echo`, description footer `Release-As: 1.0.0`; merge when green; release PR proposes `1.0.0`; merge it. Verify: tag `v1.0.0`, GitHub Release, image `rpb-echo.api:1.0.0`, branch `release/1.0.x` exists.

### Task D2: Stage scripts, one per demo

**Files:** `~/workspaces/cowork/presentations/2026-11-branching-and-versioning/demo/stage-demo1.sh`, `stage-demo2.sh`, `stage-demo3.sh`, `README.md`.

Each script: `set -euo pipefail`, works from a temp clone, makes a uniquely named change (timestamp in a string in `src/Services/Echo/...`), opens PRs with `gh pr create`, waits with `gh pr checks --watch`, merges with `gh pr merge --squash`, and ends by printing what is staged and checking the PR the presenter will merge is mergeable.

- `stage-demo1.sh` (`poc_echo_server_dotnet`): opens one `feat(echo): …` PR on a branch `feat/demo-<stamp>`, waits for its build; does not merge. Prints the PR URL and the expected version (`git describe`-free: latest `v*` tag's minor + 1).
- `stage-demo2.sh` (`release-please-demo`): merges one `feat(echo): …` and one `fix(echo): …` PR to `main`, waits for release-please to update its release PR, prints its URL and proposed version.
- `stage-demo3.sh` (`release-please-branches-demo`): merges one `feat(echo): …` to `main` (unreleased), then one `fix(echo): …` PR into the newest `release/X.Y.x`, waits for that branch's release PR, prints both release PR URLs and versions.

- [ ] Write the three scripts and `demo/README.md` (what each stages, live steps, expected results, how to re-stage).
- [ ] `shellcheck demo/*.sh` clean.

### Task D3: Rehearse each demo once, capture, re-stage

- [ ] For each demo: run its stage script, then do the live step (D1: merge the PR; D2: merge the release PR; D3: merge the release branch's release PR), and time from merge to the visible result (tag, release, re-tag, forward-port PR).
- [ ] Save captures to `demo/captures/demoN-*.{json,txt}`: PR title/body, release PR body (changelog), run job list with conclusions, tags, the forward-port PR (demo 3), image tags (`aws` not used: read from the run's summary/log via `gh run view --log`).
- [ ] For demo 3, merge the forward-port PR into `main` after capturing it, so the next stage starts clean.
- [ ] Re-stage all three for the session; record the expected live versions in `demo/README.md`.
- [ ] Commit `demo/` on the deck branch: `feat(2026-11-branching-and-versioning): add the demo stage scripts and rehearsal captures`.

## Track P — deck (main session)

### Task P1: Scaffold
- [ ] `./new-presentation.sh 2026-11-branching-and-versioning "Branching and Versioning: Choosing a Strategy"`; fill README header; add the Index row.

### Task P2: Build slides, sections 1–11 per the spec
- [ ] Title, agenda, why it matters; recap (5 min); SemVer table; per strategy: how-it-works slide with git diagram, demo slide, backup slide; side by side; three scenarios (diagram per strategy); rulesets and squash; gotchas (two slides); legacy; decision flow; cheat sheet; links; Questions.
- [ ] Speaker notes with ⏱ on every slide, demo click-by-click.
- [ ] Sources in the deck README; running-time table.

### Task P3: Check, review, export
- [ ] `./check-presentation.sh <slug>` and `<slug> 1440x900`; fix overflow; look at light and dark.
- [ ] Review to `tmp/<slug>-review.md` (repetition, timing sum = 60, order, jargon); apply.
- [ ] Fill backup slides from `demo/captures/` once D3 is done.
- [ ] `./export-markdown.py <slug>`; commit; push; open PR `feat(2026-11-branching-and-versioning): add the Branching and Versioning deck`.
