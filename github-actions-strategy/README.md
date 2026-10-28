# Moving to GitHub Actions

**Created:** 2026-10-27
**Audience:** development teams and team leads who build applications and will use GitHub Actions to build them
**Status:** Draft. Trimmed for repetition on 2026-10-28 (39 → 31 slides, ~69 → ~59 min); Demo 1 backup slide dropped and a Dependabot slide added the same day (31 slides, ~60.5 min); still to time in a run-through
**Design:** [`docs/superpowers/specs/2026-10-27-github-actions-strategy-design.md`](../docs/superpowers/specs/2026-10-27-github-actions-strategy-design.md)

## Summary

Introduces, and sells, the move from CircleCI to GitHub Actions: why we're moving, the DevOps-maintained
paved road, what changes in each application repo (rulesets, squash merges, the release App,
SemVer, image tags, curated and SHA-pinned actions), the GitHub hardening developers
will notice, what Dependabot is and why it helps, Conventional Commits, the three versioning strategies, release-please and its
changelog, and the CI-builds/CD-promotes split. Includes two live demos; Demo 2 has a backup slide.

Press **N** while presenting to show the speaker notes, each with a time estimate. Click a screenshot (slides 15 and 27) to see it full size; click again or press Esc to close it.

## Running time

Estimates from the speaker notes. The target is 60 minutes.

| Section | Slides | ~Min |
|---|---|---:|
| Title + agenda | 1–2 | 1 |
| Why we're moving | 3–4 | 3.5 |
| The paved road (incl. migration timeline) | 5–8 | 6.5 |
| What changes in your repo (before/after, branching, one PR one change, rules, no bot commits) | 9–13 | 7.5 |
| GitHub hardening that affects you, Dependabot | 14–15 | 4 |
| Conventional Commits (incl. why squash) | 16–17 | 4.5 |
| Versioning: three strategies | 18–20 | 5.5 |
| The config files for each strategy | 21 | 2 |
| Demo 1: Continuous versioning | 22 | 7 |
| Why release-please + release branches | 23–24 | 2.5 |
| Demo 2: release-please with release branches (+ changelog, backup) | 25–27 | 9 |
| CI builds, CD promotes | 28 | 2 |
| What's next | 29 | 2 |
| What's coming: v1.0.0, Claude Code skill, SBOM, pilot projects | 30 | 1.5 |
| Q&A | 31 | 2 |
| **Total** | | **~60.5** |

## Sources

### Documents & links
- Deck review, `tmp/github-actions-strategy-review.md` (local, not committed; 2026-10-28, at commit `578e21f`): section 1 (repetition) applied. Slides 17, 19, 25 and 26 dropped; 8+9, 12+20, 15+16 and 35+36 merged; repeated points cut, with the detail kept in speaker notes
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/): commit and PR title format

### Internal (Confluence / Jira / repos)
- [Git Branching @ Vector](https://lmsportal.atlassian.net/wiki/spaces/PE/pages/26994278421/Git+Branching+Vector) (Confluence, PE space): the old branching standard (continuous vs versioned release cycles, manual `release/` branches, branch naming, Conventional Commits), used for the before/after branching slide
- [`VectorLearning/cicd-standards`](https://github.com/VectorLearning/cicd-standards), read locally at commit `143ca3d`:
  - `README.md`: CI/CD definitions, the delivery model, build once and promote many, production promotion by PR to `rendered-k8s-manifests`, scope (EKS only for now)
  - `docs/ci/versioning.md`: the three strategies, how to choose, cut vs released, PR title rules, image tag rules, version format
  - `docs/ci/versioning-continuous.md`: the Continuous versioning flow, what moves the version, where the version lives, the four-part format and `run-number-offset`
  - `docs/ci/versioning-release-please.md`: "Which release type should I use?" (services use `simple`, libraries use their stack's type; slide 21's notes); plain release-please vs release branches, release branch rules, forward-ports, hotfix branches, known limitations (no live test yet, no monorepos)
  - At `origin/main` `607bfff`: `docs/ci/versioning.md` "How are builds tagged?" and `docs/ci/versioning-release-please.md` "How are images tagged?" / "What happens when the release PR merges?": under release-please every build, `main` included, is tagged `<branch>-<run>` (`main-412`), and the SemVer tag is added to that image only when the release PR merges (slides 19, 24 and 25)
  - `docs/ci/release-github-app.md`: the `vectorlearning-release` App compared with PATs, its permissions and limits
  - `templates/continuous-versioning/ci.yml`, `build-config.json`, `version-config.json`, `rulesets/`: the `ci.yml` snippet, ruleset contents, and the config-files slide
  - `templates/release-please/` (at `origin/main` `09324e0`): `release-please-config.json`, `release-please-config.release-branch.json`, repository settings and rulesets, for the config-files slide
  - The repo's overall layout (`docs/ci`, `templates`, `docs/how-to`, `docs/reference`), for the notes on slide 29
- [`VectorLearning/github-actions`](https://github.com/VectorLearning/github-actions), read locally at commit `469b65b`:
  - `README.md`: action domains and reusable workflows
  - `decisions/0001-actions-library-structure-and-versioning.md`: the case for consolidating rather than transcribing the orbs; the 2026-09-26 amendment on SHA pinning
  - At `origin/main` `eba83df` (2026-10-28): `docs/migration/dotnet-service-playbook.md` (each migrated repo gets a `.github/dependabot.yml`; the playbook covers only the `github-actions` ecosystem so far) and `.github/dependabot.yml` (weekly, grouped, 7-day cooldown), for slide 15
- [`VectorLearning/poc_echo_server_dotnet`](https://github.com/VectorLearning/poc_echo_server_dotnet) (the pilot repo), read with `gh` on 2026-10-28: `.github/dependabot.yml` (`ci(deps)` titles, weekly, minor and patch grouped, 7-day cooldown with the org library exempt) and its Dependabot PRs
- [`VectorLearning/vsp-ci`](https://github.com/VectorLearning/vsp-ci) at `origin/main` `77a8171` (2026-09-25): `src/commands/` has 35 commands, mostly .NET, one Python unit-test command and none for Node or Java. Three image-scan commands, one deprecated (`docker-scan-image`, Rapid7 end-of-life). Used for slide 4
- [`VectorLearning/dynamo-config`](https://github.com/VectorLearning/dynamo-config) at `origin/main` `66b7b25`: last changed 2022-06-20 (slide 4). `src/scripts/bump-version.sh`, `push-version-bumps.sh` and `docs/dynamo-config-schema.md`: reads the version from `dynamo-config.yml` or a `version-source` file (`.csproj`, `package.json`, `Chart.yaml`), and commits the bump to the branch as "Version auto-update by CircleCi [ci skip]" (slide 13)
- `infrastructure-ci-orb` is deliberately excluded from slide 4: it's for infrastructure, not application CI
  - `.github/workflows/README.md`: only the `dotnet` stack is implemented in the build path
  - Tests at `origin/main` `5527dcd`: all 12 actions under `actions/` have test suites, and each of the 5 reusable workflows has a `.bats` suite, run by `ci-self-test.yml`. Used for slide 5
  - `actions/docker/build-images/action.yml` at `origin/main`: builds with `sbom: false` today, so SBOM generation is still to come (slide 30)
  - `.github/workflows/pr-title-lint.yml`: the allowed PR title types; the pinned `amannn/action-semantic-pull-request` example
- `~/workspaces/cowork/github-security-review` (local, private):
  - `github-org-security-review.md` (snapshot 2026-09-25): the Actions baseline (allowed actions, SHA pinning, `GITHUB_TOKEN` defaults, Team plan limits)
  - `remediation-backlog.md`: GHSEC-01, 03/10, 04, 05, 06, 08, 09, 11, 12, 15, 17, the source of the hardening slide; GHSEC-04 (Dependabot alerts, security updates and dependency graph, free on the Team plan) and GHSEC-05 (Dependabot for the `github-actions` ecosystem) for slide 15
- Jira, referenced in the notes: COREOPS-4428 (release-please demo repo), COREOPS-4416 (forward-port action)

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors were sampled from its background images and logo (deep blue `#1A439B`, `#2C61AD`, cyan `#2581C4`, teal `#439AB8`, green `#81C089`, slate text). The rounded-diamond outline motif and the title background also come from it
- `~/OneDrive - Vector Solutions/Documents/presentations/vector-template.pptx` (Vector Solutions PowerPoint template, read 2026-10-28): the footer on its slide master (slide 5's layout). The color logo (`ppt/media/image2.png`), the white logo (`image7.png`, used on the title slide) and the strip's gradient (`image3.emf`: `#96D448` → `#293D9A` at 66% → `#5AB7E6`). Positions taken from the master: logo at the bottom left, 14.6% of the slide's width; the strip to its right; the slide number at the right

### People consulted
- Noel Aguilar, DevOps: reasons for the move (cost: about 80% of the CircleCI cost is for active users, which GitHub Actions doesn't charge for; Claude Code; one place), the paved-road framing, before/after changes (`cibot`, rulesets, squash, Dependabot, four-part versions), curated actions, SPAs and Lambdas moving to the Promotion Manager, the migration approach, demo choices

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background (gradient with the photo diamond), taken unchanged (2400×1350) from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx` (see below)
- `assets/vector-logo.png` (350×79) and `assets/vector-logo-white.png` (2602×589): the Vector Solutions logos, taken unchanged from `vector-template.pptx` (`ppt/media/image2.png` and `image7.png`). The white one is used on the dark slides and in dark mode
- `assets/dependabot-pr.png`: screenshot of a Dependabot PR (`ci(deps)`, bumping `actions/setup-node`) in a repo's PR list, taken by Noel Aguilar on 2026-10-28, for slide 15
- `assets/demo2-release-pr.png`, `demo2-github-release.png`, `demo2-changelog.png`: Demo 2 backup screenshots for slide 27, provided by Noel Aguilar on 2026-10-28 (a release-please release PR; the GitHub Releases page and `CHANGELOG.md` of a monorepo on release-please, showing `@argocd-promotion-manager` packages)

## Notes

Decided by Noel Aguilar (2026-10-27):

- Demo 1: Continuous versioning, .NET, on `poc_echo_server_dotnet`. Demo 2: release-please with release branches, Python, on `release-please-demo`
- Lambdas move to AWS ACK, with manifests in `rendered-k8s-manifests`, promoted by the Promotion Manager. SPAs are similar, with the strategy being finalized. Both get a later session with a demo
- 2FA enforcement is planned for the end of January 2027 (as of 2026-10-28)
- All CI bot accounts (`cibot` and any others) are retired by April 1, 2027 (slides 13 and 14; changed from the end of January on 2026-10-28)
- Every hardening item on slide 14 is confirmed, with dates (2026-10-28): OIDC to AWS on Nov 2; `GITHUB_TOKEN` read-only, Actions can't approve PRs, SHA pinning, approved actions only and org-wide branch protection on Nov 11 (branch protection is in the notes of slides 12 and 14, since teams have nothing to do); Dependabot as each repo migrates; tidy-ups in December; 2FA at the end of January 2027
- Actions are pinned by SHA. Standard reusable workflows are referenced as `@v<major>`, and teams may pin an exact version instead
- release-please will support monorepos
- `github-actions` v1.0.0 (first official release) ships by mid-November 2026
- A Claude Code skill to help set up repos is being built
- DevOps is looking for a couple of test projects to migrate first
- Every repo is migrated off CircleCI by April 1, 2027 (slides 8 and 30; decided 2026-10-28)
- Migration waves (slide 8, 2026-10-28): new apps deployed to EKS and new containerized Lambdas start on GitHub Actions once `github-actions` v1.0.0 ships; existing apps deployed to EKS migrate from mid-November to the end of January; SPAs, Lambdas and other projects from January to the end of March. Teams must not migrate ahead of their wave, because the workflows for their stack may not be ready
- Dependabot version updates cover each repo's package ecosystem (NuGet, npm, pip, …) as well as `github-actions` (Noel Aguilar, 2026-10-28; slide 15). The playbook and the pilot have only `github-actions` so far
- SBOM generation is coming to the standard workflows; no date yet (slide 30)

Proposed (not yet in the standards):

- Delete branches automatically after merge (`delete_branch_on_merge`), to keep the branch list clean as Dependabot opens PRs. It isn't in the `repository-settings.json` templates yet. Shown on slide 12 with a "proposed" label

Open items before presenting:

- **`release-please-demo`** is empty on GitHub (2026-10-27). Set it up before the session, or present slides 25–27 as a walkthrough
- **Out of step with the standards:** the `ci.yml` template and github-actions ADR-0001 (2026-09-26 amendment) still pin `app-ci.yml` by SHA, and `versioning-release-please.md` still says monorepos aren't covered. The deck follows the decisions above
- Support channel or contact for slide 29
