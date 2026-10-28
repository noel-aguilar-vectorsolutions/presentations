# Moving to GitHub Actions

**Created:** 2026-10-27
**Audience:** development teams and team leads who build applications and will use GitHub Actions to build them
**Status:** Draft. Built with every section in; trim after a timed run-through
**Design:** [`docs/superpowers/specs/2026-10-27-github-actions-strategy-design.md`](../docs/superpowers/specs/2026-10-27-github-actions-strategy-design.md)

## Summary

Introduces, and sells, the move from CircleCI to GitHub Actions: why we're moving, the DevOps-maintained
paved road, what changes in each application repo (rulesets, squash merges, the release App,
SemVer, image tags, Dependabot, curated and SHA-pinned actions), the GitHub hardening developers
will notice, Conventional Commits, the three versioning strategies, release-please and its
changelog, and the CI-builds/CD-promotes split. Includes two live demos with backup slides.

Press **N** while presenting to show the speaker notes, each with a time estimate.

## Running time

Estimates from the speaker notes. The target is 60 minutes.

| Section | Slides | ~Min |
|---|---|---:|
| Title + agenda | 1–2 | 1 |
| Why we're moving | 3–4 | 3.5 |
| The paved road | 5–8 | 6 |
| What changes in your repo (incl. why squash, one PR one change, rules, where the version lives) | 9–16 | 11.5 |
| GitHub hardening that affects you | 17–18 | 4 |
| Conventional Commits | 19–20 | 4 |
| Versioning: three strategies | 21–24 | 7 |
| cicd-standards and the config files for each strategy | 25–26 | 3.5 |
| Demo 1: Continuous versioning (+ backup) | 27–28 | 7 |
| Why release-please + release branches | 29–30 | 3 |
| Demo 2: release-please with release branches (+ changelog, backup) | 31–33 | 9 |
| CI builds, CD promotes | 34–35 | 3 |
| What's next | 36 | 2 |
| What's coming: v1.0.0, Claude Code skill, pilot projects | 37 | 1.5 |
| Q&A | 38 | 2 |
| **Total** | | **~68** |

## Sources

### Documents & links
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/): commit and PR title format

### Internal (Confluence / Jira / repos)
- [Git Branching @ Vector](https://lmsportal.atlassian.net/wiki/spaces/PE/pages/26994278421/Git+Branching+Vector) (Confluence, PE space): the old branching standard (continuous vs versioned release cycles, manual `release/` branches, branch naming, Conventional Commits), used for the before/after branching slide
- [`VectorLearning/cicd-standards`](https://github.com/VectorLearning/cicd-standards), read locally at commit `143ca3d`:
  - `README.md`: CI/CD definitions, the delivery model, build once and promote many, production promotion by PR to `rendered-k8s-manifests`, scope (EKS only for now)
  - `docs/ci/versioning.md`: the three strategies, how to choose, cut vs released, PR title rules, image tag rules, version format
  - `docs/ci/versioning-continuous.md`: the Continuous versioning flow, what moves the version, where the version lives, the four-part format and `run-number-offset`
  - `docs/ci/versioning-release-please.md`: "Which release type should I use?" (services use `simple`, libraries use their stack's type; slide 15); plain release-please vs release branches, release branch rules, forward-ports, hotfix branches, known limitations (no live test yet, no monorepos)
  - `docs/ci/release-github-app.md`: the `vectorlearning-release` App compared with PATs, its permissions and limits
  - `templates/continuous-versioning/ci.yml`, `build-config.json`, `version-config.json`, `rulesets/`: the `ci.yml` snippet, ruleset contents, and the config-files slide
  - `templates/release-please/` (at `origin/main` `09324e0`): `release-please-config.json`, `release-please-config.release-branch.json`, repository settings and rulesets, for the config-files slide
  - The repo's overall layout (`docs/ci`, `templates`, `docs/how-to`, `docs/reference`), for the "where the rules live" slide
- [`VectorLearning/github-actions`](https://github.com/VectorLearning/github-actions), read locally at commit `469b65b`:
  - `README.md`: action domains and reusable workflows
  - `decisions/0001-actions-library-structure-and-versioning.md`: the case for consolidating rather than transcribing the orbs; the 2026-09-26 amendment on SHA pinning
- [`VectorLearning/vsp-ci`](https://github.com/VectorLearning/vsp-ci) at `origin/main` `77a8171` (2026-09-25): `src/commands/` has 35 commands, mostly .NET, one Python unit-test command and none for Node or Java. Three image-scan commands, one deprecated (`docker-scan-image`, Rapid7 end-of-life). Used for slide 4
- [`VectorLearning/dynamo-config`](https://github.com/VectorLearning/dynamo-config) at `origin/main` `66b7b25`: last changed 2022-06-20 (slide 4). `src/scripts/bump-version.sh`, `push-version-bumps.sh` and `docs/dynamo-config-schema.md`: reads the version from `dynamo-config.yml` or a `version-source` file (`.csproj`, `package.json`, `Chart.yaml`), and commits the bump to the branch as "Version auto-update by CircleCi [ci skip]" (slide 15)
- `infrastructure-ci-orb` is deliberately excluded from slide 4: it's for infrastructure, not application CI
  - `.github/workflows/README.md`: only the `dotnet` stack is implemented in the build path
  - Tests at `origin/main` `5527dcd`: all 12 actions under `actions/` have test suites, and each of the 5 reusable workflows has a `.bats` suite, run by `ci-self-test.yml`. Used for slide 5
  - `.github/workflows/pr-title-lint.yml`: the allowed PR title types; the pinned `amannn/action-semantic-pull-request` example
- `~/workspaces/cowork/github-security-review` (local, private):
  - `github-org-security-review.md` (snapshot 2026-09-25): the Actions baseline (allowed actions, SHA pinning, `GITHUB_TOKEN` defaults, Team plan limits)
  - `remediation-backlog.md`: GHSEC-01, 03/10, 04, 05, 06, 08, 09, 11, 12, 15, 17, the source of the hardening slide
- Jira, referenced in the notes: COREOPS-4428 (release-please demo repo), COREOPS-4416 (forward-port action)

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors were sampled from its background images and logo (deep blue `#1A439B`, `#2C61AD`, cyan `#2581C4`, teal `#439AB8`, green `#81C089`, slate text). The rounded-diamond outline motif and the title background also come from it

### People consulted
- Noel Aguilar, DevOps: reasons for the move (cost: about 80% of the CircleCI cost is for active users, which GitHub Actions doesn't charge for; Claude Code; one place), the paved-road framing, before/after changes (`cibot`, rulesets, squash, Dependabot, four-part versions), curated actions, SPAs and Lambdas moving to the Promotion Manager, the migration approach, demo choices

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background (gradient with the photo diamond), taken unchanged (2400×1350) from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx` (see below)
- `assets/`: demo backup screenshots still to be captured (see the placeholders on slides 28 and 33)

## Notes

Decided by Noel Aguilar (2026-10-27):

- Demo 1: Continuous versioning, .NET, on `poc_echo_server_dotnet`. Demo 2: release-please with release branches, Python, on `release-please-demo`
- Lambdas move to AWS ACK, with manifests in `rendered-k8s-manifests`, promoted by the Promotion Manager. SPAs are similar, with the strategy being finalized. Both get a later session with a demo
- 2FA enforcement is planned for the end of January 2027 (as of 2026-10-28)
- All CI bot accounts (`cibot` and any others) are retired by the end of January 2027 (slides 14 and 17)
- Every hardening item on slide 17 is confirmed, with dates (2026-10-28): OIDC to AWS on Nov 2; `GITHUB_TOKEN` read-only, Actions can't approve PRs, SHA pinning, approved actions only and org-wide branch protection on Nov 11; Dependabot as each repo migrates; tidy-ups in December; 2FA at the end of January 2027
- Actions are pinned by SHA. Standard reusable workflows are referenced as `@v<major>`, and teams may pin an exact version instead
- release-please will support monorepos
- `github-actions` v1.0.0 (first official release) ships by mid-November 2026
- A Claude Code skill to help set up repos is being built
- DevOps is looking for a couple of test projects to migrate first

Proposed (not yet in the standards):

- Delete branches automatically after merge (`delete_branch_on_merge`), to keep the branch list clean as Dependabot opens PRs. It isn't in the `repository-settings.json` templates yet. Shown on slide 13 with a "proposed" label

Open items before presenting:

- **`release-please-demo`** is empty on GitHub (2026-10-27). Set it up before the session, or present slides 31–33 as a walkthrough
- **Out of step with the standards:** the `ci.yml` template and github-actions ADR-0001 (2026-09-26 amendment) still pin `app-ci.yml` by SHA, and `versioning-release-please.md` still says monorepos aren't covered. The deck follows the decisions above
- Support channel or contact for slide 36
