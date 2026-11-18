# Demos: staging, live steps, re-staging

Three live demos, one per strategy. Each has a stage script here that leaves its repository one
click away from the result the slide shows. Tags can't be deleted, so a rehearsal uses up the staged
state: run the stage script again afterwards.

## Expected live versions (staged 2026-11-17)

Checked `CLEAN` at 2026-11-17 19:50 (ET). Don't merge anything else into these repositories before
the session.

| Demo | Merge live | Last version | Expected live |
|---|---|---|---|
| 1 | [`poc_echo_server_dotnet#59`](https://github.com/VectorLearning/poc_echo_server_dotnet/pull/59) `feat(echo): stamp the demo build 20261118-001425`; branch image `noel/echo.api:feat-demo-20261118-001425-145` | `v1.4.0` (the rehearsal's) | **`v1.5.0`**, image `noel/echo.api:1.5.0` |
| 2 | [`release-please-demo#250`](https://github.com/VectorLearning/release-please-demo/pull/250) `chore(main): release echo 4.7.0` (feat #249, fix #251) | `echo@v4.6.0` (the rehearsal's) | **`echo@v4.7.0`**, Release, `noel/echo.*:4.7.0` re-tagged from `main-<run>` |
| 3 | [`release-please-branches-demo#10`](https://github.com/VectorLearning/release-please-branches-demo/pull/10) `chore(release/1.0.x): release 1.0.2` (fix #9) | `v1.0.1` (the rehearsal's) | **`v1.0.2`**, Release, `noel/rpb-echo.*:1.0.2` re-tagged from `release-1.0.x-<run>` |

Demo 3 also shows, already open: the port of fix #9 to `main`,
[#11](https://github.com/VectorLearning/release-please-branches-demo/pull/11) (opened 19 s after #9
merged), and `main`'s release PR
[#4](https://github.com/VectorLearning/release-please-branches-demo/pull/4) proposing **`1.1.0`**
(features #3 and #8, and the rehearsal's port #6 of fix #5).

Note: the spec's numbers (`1.4.0`, `4.6.0`, `1.0.1`) were the rehearsal's; the live run is one higher.

## Prerequisites

- `gh auth status` green for an account that can push to and merge in the three repositories.
- An SSH key that can push to `git@github.com:VectorLearning/<repo>.git`.
- `jq`, `git`, bash. No AWS login: the workflows reach ECR through OIDC.

## The scripts

| Script | Repository | Stages | Takes |
|---|---|---|---|
| `stage-demo1.sh` | `poc_echo_server_dotnet` | One `feat(echo)` PR on `feat/demo-<stamp>`, branch build green, **not merged**. Closes an earlier staged `feat/demo-*` PR first. | ~8 min |
| `stage-demo2.sh` | `release-please-demo` | One `feat(echo)` and one `fix(echo)` PR **merged** to `main`, `main`'s builds finished, the release PR updated and `CLEAN`. | ~25 min |
| `stage-demo3.sh` | `release-please-branches-demo` | Merges any open `forward-port/…` PR into `main`; one `feat(echo)` **merged** to `main` (unreleased); one `fix(echo)` **merged** into the newest `release/X.Y.x`; that branch's release PR `CLEAN`. | ~30 min |
| `capture-live.sh N <PR> [label]` | any | After a merge: waits for the tag, Release, branch and run, prints the seconds after the merge each appeared, saves `captures/demoN-<label>-*`. | until the run ends |
| `lib.sh` | | Shared helpers, sourced. | |

Each stage script ends by printing the PR to merge live and the version it will produce, and fails
unless that PR's `mergeStateStatus` is `CLEAN` (checks green, up to date with its base). Run the
three in parallel: they touch different repositories.

```sh
cd 2026-11-branching-and-versioning/demo
./stage-demo1.sh & ./stage-demo2.sh & ./stage-demo3.sh & wait
```

Don't merge anything else into these repositories between staging and the session: a merge to
`main` puts the staged PR behind (strict required checks), and it has to be updated and re-checked.

## Live steps and what appears

Times are from the rehearsal, counted from the click on **Squash and merge**.

### Demo 1, Continuous versioning (`poc_echo_server_dotnet`)

1. Open the staged PR. Show its checks green and, in the run, the branch image
   `noel/echo.api:feat-demo-<stamp>-<run>`: a topic branch never gets a version.
2. **Squash and merge.** Open **Actions → build-test-publish** on `main` (it starts within ~6 s).
3. While it runs, open **CI / Plan builds**: the `versions` step's output shows the module changed
   and `"version": "<next minor>"`, `"tag": "v<next minor>"`, `"create-tag": true`.
4. Build ~1.5 min, Unit and Integration Test ~2.5 min, Publish images at ~+4.5 min,
   **Tag release commit** at **~+5 min**: the job log says `Created tag 'vX.Y.0' on <sha>`.
   Then **Code → Tags** shows it. No release PR, no changelog, no GitHub Release.

**Takes ~5 min end to end**, the whole demo slot. Merge first, then talk over the run; or show the
rehearsal's run (captures) if time is short.

### Demo 2, plain release-please (`release-please-demo`)

1. Open the release PR: title `chore(main): release echo X.Y.Z`, body = the changelog with the
   staged `feat` and `fix`. Point at `.release-please-manifest.json` and `CHANGELOG.md` in
   **Files changed**.
2. **Squash and merge.** Open **Actions → release-please** on `main` (starts ~+11 s).
3. **Tag `echo@vX.Y.Z` and the GitHub Release at ~+25 s** (Code → Tags, Releases).
4. The **retag** job ends at **~+46 s**; its log: `module '.' was built at <sha>, 1 commit(s) before
   the release commit`, `its images are tagged main-<run>`, then
   `tagged noel/echo.api:X.Y.Z on sha256:…`: the tested image, no rebuild.
5. Point at the existing `hotfix/4.4.x` branch as what a hotfix looks like.

### Demo 3, release-please with release branches (`release-please-branches-demo`)

Before merging, show what's staged: `main`'s release PR (`release 1.1.0`, the unreleased `feat`),
the fix PR merged into `release/1.0.x`, and **the forward-port PR to `main` already open**. It
opened **~17 s after the fix merged** (as the release App, `forward-port/release-1.0.x/<pr>/main`,
same title, a review request to the author, and a comment on the fix listing every target).
Ports open when a change merges to the release branch, not when the release PR merges.

1. Open the release branch's release PR: title `chore(release/1.0.x): release 1.0.N`, base
   `release/1.0.x`.
2. **Squash and merge.** Open **Actions → release-please** on `release/1.0.x` (starts ~+11 s).
3. **Tag `v1.0.N` and the GitHub Release at ~+19 s.**
4. The **retag** job ends at **~+42 s**: `its images are tagged release-1.0.x-<run>`, then
   `tagged noel/rpb-echo.api:1.0.N`. No `release-branch` job runs (only an `X.Y.0` creates one).
   The `forward-port` job runs too and skips the release PR's merge ("Releases are not ported").
5. Show `main`'s release PR still proposing `1.1.0`: `main` and the release line move separately.
6. Open **Settings → Rules → Rulesets**: seven rulesets, among them *Release branch creation*
   (only the release App may create `release/**`) and *release-please: version tags* (no update or
   deletion of `v*` tags).

**Things that look like errors but aren't**

- `main`'s release PR shows `release-please / release-pr-version-check` **green** in the staged
  state, though the port is open: it last ran before the port existed. Its next update (any merge
  to `main`) fails it under the *missing-ports rule* until the port is merged. Worth a sentence;
  don't push anything to `main` during the demo.
- Skipped jobs (`release-pr-version-check`, `release-branch-change-type`, `release-branch`) are
  normal on a push.
- Annotations `Retention days cannot be greater than the maximum…` (demo 1) and `ASP0014` are
  harmless warnings.

## After the session (or a rehearsal)

- Demo 3: merge the forward-port PR into `main` (or let `stage-demo3.sh` do it at its start).
- Run the three stage scripts again to re-stage; they print the next expected versions. Update the
  speaker notes' numbers from that output.

## Rehearsal (2026-11-17)

| Demo | Merged | Result | Timings after the merge | Captures |
|---|---|---|---|---|
| 1 | `poc_echo_server_dotnet#58` (`feat`) | `v1.4.0`, `noel/echo.api:1.4.0` | run +6 s; tag +300 s; run done +314 s | `captures/demo1-rehearsal-*` |
| 2 | `release-please-demo#247` (`release echo 4.6.0`) | `echo@v4.6.0`, Release, `noel/echo.*:4.6.0` re-tagged from `main-600` | run +11 s; tag and Release +25 s; retag done +46 s; run done +52 s | `captures/demo2-rehearsal-*` |
| 3 | `release-please-branches-demo#7` (`release 1.0.1`) | `v1.0.1`, Release, `noel/rpb-echo.*:1.0.1` re-tagged from `release-1.0.x-11`; port #6 (opened +17 s after fix #5 merged) | run +11 s; tag and Release +19 s; retag done +42 s; run done +47 s | `captures/demo3-rehearsal-*`, `demo3-setup-*` |

The backup slides use these, one version lower than the live run.

Capture files per demo: `-stage.txt` (stage script output), `-pr.json` (the merged PR, body =
changelog for 2 and 3), `-timings.txt`, `-run-jobs.txt` (jobs, conclusions, times),
`-run-notices.txt` (annotations, incl. the re-tag lines), `-image-tags.txt`, `-tags.txt`,
`-release.json` (2, 3), demo 1's `-versions-reasoning.txt` (the computed version), demo 3's
`-open-prs.json` (port and `main`'s release PR after the merge), `-before-*` (state before the
merge) and `-fix-pr-forward-port-comment.txt` (the App's comment on the fix). `*-live-stage.txt`
is the output of the staging for the session.
