# Branching and Versioning: Choosing a Strategy

**Created:** 2026-11-17
**Date:** 2026-11-18
**Audience:** Project tech leads
**Status:** Draft
**Presenter:** Noel Aguilar

## Summary

A 60-minute session to help each project's tech lead choose a versioning strategy for their product:
Continuous versioning, plain release-please, or release-please with release branches. It refreshes
the basics from *Moving to GitHub Actions* (squash merge, PR titles, cut is not released), shows how
each strategy applies SemVer and how its branches behave, walks three scenarios (a failed
regression, an urgent hotfix, a breaking change), covers the rulesets, the gotchas and the legacy
four-part format, and ends with a decision flow and a printable cheat sheet. Each strategy is shown
in a live demo, with a backup slide.

## Running time

| # | Section | Slides | Minutes |
|---|---|---|---|
| 1 | Title, agenda, and why the choice matters | 1–3 | 2 |
| 2 | Recap from *Moving to GitHub Actions*, and Conventional Commits | 4–8 | 5.25 |
| 3 | SemVer, and how each strategy applies it | 9–11 | 3.75 |
| 4 | Continuous versioning (opener), then demo 1 (+ backup) | 12–17 | 4 + 5.5 |
| 5 | Plain release-please (opener), then demo 2 (+ backup) | 18–23 | 4 + 5.5 |
| 6 | release-please with release branches (opener), then demo 3 (+ backup) | 24–30 | 4 + 5.5 |
| 7 | Side by side, monorepos, three scenarios, and the decision flow | 31–36 | 7 |
| 8 | Rulesets and squash merge | 37–39 | 2.75 |
| 9 | Gotchas | 40–42 | 3.5 |
| 10 | The legacy four-part format | 43 | 1.5 |
| 11 | Cheat sheet, where to read more | 44–45 | 1.75 |
| — | Questions | 46 | 4 |
| | **Total** | **46** | **60** |

The backup slides (17, 23, 30) carry 0 minutes: they are shown only if a live demo fails, in its
5.5 minutes. The review (below) freed 2 minutes, given to the three demos (+0.5 each) and
Q&A (+0.5).

## Sources

Every source of information used in this presentation goes here.

### Documents & links
- [Design spec](../docs/superpowers/specs/2026-11-17-branching-and-versioning-design.md) (2026-11-17): the content, order and timing of every section
- [Presentation guide](../docs/presentation-guide.md): the build process, design and components
- Review, `tmp/2026-11-branching-and-versioning-review.md` (2026-11-17, not committed): 45 findings checked against cicd-standards; the applied ones are listed in its "Applied" section

### Internal (Confluence / Jira / repos)
- [`VectorLearning/cicd-standards`](https://github.com/VectorLearning/cicd-standards) at `72b4b84`:
  - `docs/ci/versioning.md`: the three strategies, choosing between them, PR title types, cut versus released, build and version tags, monorepo fit
  - `docs/ci/versioning-continuous.md`: how Continuous versioning works, what moves the version, known limitations (no changelog, no hotfix while `main` has unreleased work, tag creation not restricted), the four-part format and moving to SemVer
  - `docs/ci/versioning-release-please.md`: plain release-please and hotfix branches, release branches, `always-bump-minor` and `always-bump-patch`, forward-ports, the release PR version check, the re-tag, rulesets and repository settings, breaking changes and `Release-As`, known limitations (the gotchas)
  - `docs/how-to/release-please-fixes-and-hotfixes.md`: the steps for failed regressions, hotfixes, forward-ports, releasing a `docs:` or `chore:` change, and a release PR blocked with every check green (COREOPS-4698)
- [`VectorLearning/github-actions`](https://github.com/VectorLearning/github-actions) at `28a60e8` (release `v0.2.3`): `.github/workflows/app-release-please.yml` and `app-release-please-release-branches.yml` (the `forward-port`, `release-pr-version-check`, `release-branch-change-type`, `release-branch`, `hotfix-branch` and `retag` jobs), and `app-ci.yml` (the Plan builds job)
- Demo repositories, checked 2026-11-17 for their tags, branches and config:
  - [`poc_echo_server_dotnet`](https://github.com/VectorLearning/poc_echo_server_dotnet): last tag `v1.3.0`, `version-config.json`, the `build-test-publish` workflow
  - [`release-please-demo`](https://github.com/VectorLearning/release-please-demo): last release `echo@v4.5.0`, component tags, `hotfix/4.4.x` (cut from `echo@v4.4.1`, a `main` release; it released one hotfix, `echo@v4.4.2`, ported to `main` by #241)
  - [`release-please-branches-demo`](https://github.com/VectorLearning/release-please-branches-demo): staged for demo 3 (see the spec's demo preparation)
  - [`poc_echo_server_dotnet_legacy`](https://github.com/VectorLearning/poc_echo_server_dotnet_legacy): four-part tags such as `v1.3.1.2019`
- Demo captures, `demo/captures/` (rehearsal of 2026-11-17, see `demo/README.md`): the backup slides (16, 21, 27) and the demo slides' timings are built from them, one version earlier than live. The PRs used:
  - Demo 1, `poc_echo_server_dotnet`: rehearsal [#58](https://github.com/VectorLearning/poc_echo_server_dotnet/pull/58) (`v1.4.0`, tag at +300 s); live [#59](https://github.com/VectorLearning/poc_echo_server_dotnet/pull/59) (expected `v1.5.0`)
  - Demo 2, `release-please-demo`: rehearsal release PR [#247](https://github.com/VectorLearning/release-please-demo/pull/247) (`echo@v4.6.0`, from feat #246 and fix #248; tag and Release at +25 s, re-tag of `main-600` done at +46 s); live release PR [#250](https://github.com/VectorLearning/release-please-demo/pull/250) (expected `echo@v4.7.0`, from feat #249 and fix #251)
  - Demo 3, `release-please-branches-demo`: rehearsal release PR [#7](https://github.com/VectorLearning/release-please-branches-demo/pull/7) (`v1.0.1`, from fix #5; tag and Release at +19 s, re-tag of `release-1.0.x-11` done at +42 s) and its port [#6](https://github.com/VectorLearning/release-please-branches-demo/pull/6) (opened 17 s after #5 merged); live release PR [#10](https://github.com/VectorLearning/release-please-branches-demo/pull/10) (expected `v1.0.2`, from fix #9), its port [#11](https://github.com/VectorLearning/release-please-branches-demo/pull/11) (already open, opened 19 s after #9 merged), and `main`'s release PR [#4](https://github.com/VectorLearning/release-please-branches-demo/pull/4) (`release 1.1.0`)
- [Moving to GitHub Actions](../moving-to-github-actions/) (2026-10-27): what the audience already saw; the reference for markup, tone and speaker notes. This deck corrects its forward-port slide: forward-ports are now opened automatically

### People consulted
- Noel Aguilar, presenter: audience, length, demo choices, and the emphasis on rulesets, squash merge and the recap

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors, the rounded-diamond outline motif and the title background
- `~/OneDrive - Vector Solutions/Documents/presentations/vector-template.pptx` (Vector Solutions PowerPoint template): the footer on its slide master (logo, then the strip's gradient `#96D448` → `#293D9A` → `#5AB7E6`)

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background, taken unchanged from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx`
- `assets/vector-logo.png` and `assets/vector-logo-white.png`: the Vector Solutions logos, taken unchanged from `vector-template.pptx` (`ppt/media/image2.png` and `image7.png`). The white one is used on brand slides and in dark mode

## Notes

- The backup slides (`<!-- BACKUP:demoN -->`) carry the rehearsal of 2026-11-17, rebuilt as HTML from `demo/captures/`.
- The demo slides' speaker notes carry the live PR numbers and expected versions staged on 2026-11-17 (`demo/README.md`). If the demos are re-staged, update the notes from the stage scripts' output.
