# GitHub Org Hardening: Q4 and Q1

**Created:** 2026-11-09
**Audience:** engineering leads and leadership: what's changing in the VectorLearning GitHub org, when, and what it asks of teams
**Status:** Draft, for the presenter's review. Built 2026-11-09; people, teams and access section added 2026-11-11, joining-and-leaving slide 2026-11-12; not yet rehearsed
**Design:** [`docs/superpowers/specs/2026-11-09-github-org-hardening-design.md`](../docs/superpowers/specs/2026-11-09-github-org-hardening-design.md)

## Summary

The organization-level security changes DevOps is making in GitHub as CI moves to GitHub Actions, split into
Q4 2026 (epic COREOPS-4617: secure the CI supply chain, add an org-wide baseline, clean up) and Q1 2027
(planned, no epic yet: 2FA enforcement at the end of January, then owners, dormant repos and the rest). It
shows today's gaps with one number each, the month-by-month plan, what teams need to do, and how progress is
measured.

A separate section after the plan (slides 9–14) covers **people, teams and access**: a different stream
from the hardening work, shown as *proposed*, with no epic or dates. It covers the username standard, team
structure, team versus direct repo access, unused teams and outside collaborators, and proposes an access
model in which nobody gets repo admin by default, the three steps to get there, and an Okta-signed front door
that ties every GitHub account to an Okta identity so leavers are removed (SCIM-like, without SSO).

Press **N** while presenting to show the speaker notes, each with a time estimate.

## Running time

Estimates from the speaker notes. The original target was 15 minutes, including questions. The people,
teams and access section adds about 7 minutes, which takes the session to about 22. It was left over target
on purpose (2026-11-11); if it needs trimming, slide 6 can drop to 30 seconds first.

| Section | Slides | ~Min |
|---|---|---:|
| Title | 1 | 0.5 |
| Why now | 2 | 1.5 |
| Where we are today | 3 | 2 |
| The plan at a glance (Q4 / Q1 timeline) | 4 | 1.5 |
| Q4: secure the CI supply chain | 5 | 2 |
| Q4: guardrails and cleanup | 6 | 1.5 |
| Q1: identity and access (planned) | 7 | 1.5 |
| What teams need to do, and how we'll measure it | 8 | 1.5 |
| *People, teams and access* (separate stream): divider | 9 | 0.25 |
| People, teams and access: where we are | 10 | 1.5 |
| People, teams and access: what we propose | 11 | 1.5 |
| People, teams and access: nobody gets repo admin, by default | 12 | 1.5 |
| People, teams and access: getting there | 13 | 1.25 |
| People, teams and access: joining and leaving, tied to Okta | 14 | 1.25 |
| Questions | 15 | 3 |
| **Total** | | **22** |

## Sources

Every source of information used in this presentation goes here.

### Documents & links
- [GitHub changelog, 2025-06-16: Organization rulesets now available for GitHub Team plans](https://github.blog/changelog/2025-06-16-organization-rulesets-now-available-for-github-team-plans/): that the org ruleset (slide 6) is available on our plan
- [GitHub changelog, 2025-08-15: Actions policy supports blocking and SHA pinning](https://github.blog/changelog/2025-08-15-github-actions-policy-now-supports-blocking-and-sha-pinning-actions/): that SHA pinning can be required org-wide, covers GitHub's own actions, and exempts reusable workflows (slide 5 notes)
- The `tj-actions/changed-files` compromise, March 2025 (slide 2): as described in the security review and the Jira stories

- GitHub docs on [repository roles](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization), [Actions secrets](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions), [environments](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment) and [custom repository roles](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/about-custom-repository-roles), checked 2026-11-11: what maintain can't do that admin can, and that repo secrets need only write (slide 12)

### Internal (Confluence / Jira / repos)
- [COREOPS-4617](https://lmsportal.atlassian.net/browse/COREOPS-4617) and its stories COREOPS-4619 to COREOPS-4629: the Q4 scope, the staging (reports first, then enforcement), and the details in slides 5, 6 and 8. Status checked 2026-11-09: all 11 in Backlog
- `~/workspaces/cowork/github-security-review`: the GitHub org security review
  - `data/2026-11-09/` (scan of 2026-11-09, the same scan the team reports were built from): the figures on slides 3, 5, 7 and 8 (190 refs / 46 repos, 43 workflow files without `permissions:`, 29 of 101 Actions repos unprotected, 184 of 370 and 9 of 12 without 2FA, 9 AWS secrets, 16 owners, 78 dormant repos, 16 Claude review repos, 771 active repos). The deck first used `data/2026-11-02/`; moved to the 9 November scan on 2026-11-09 when the reports were published
  - `remediation-backlog.md`: the Q1 items (GHSEC-03, 09, 10, 13, 17, 19, 20; GHSEC-18, Enterprise Cloud pricing, removed 2026-11-09 at the presenter's request: not being pursued) and their descriptions
  - `coreops-4617-tickets.md`: the allowlist (22 actions, retiring four by 2027-01-31), and the 3 workflows needing `permissions:`
  - `coreops-4617-announcement.md`: the "what teams need to do" list on slide 8
- `~/workspaces/cowork/github-security-review/analysis/people-and-teams-review.md` and `analysis/people-2026-11-11/summary.json` in the same repo: every figure on slides 10 and 11 (102 of 362 accounts off the username standard, 20 personal-style; `vector-engineering` with 303 members, read on 292 active repos and write on 64, 55 contractors; 38% of 2,740 grants on active repos direct to users, 66% of those admin; 117 owner-only repos; 21 of 175 unused teams; 12 outside collaborators, 6 staff-like; 82 renamable accounts; 194 duplicate direct grants; 30 teams without a maintainer). Collected 2026-11-11 with `scripts/collect_people.py` and `scripts/analyze_people.py`, as the read-only `vectorlearning-org-reader` GitHub App
- CODEOWNERS coverage, 175 of 776 active repos (slides 11 and 13): batched GraphQL on every active repo as the App, 2026-11-11, saved as `analysis/people-2026-11-11/codeowners.json` in the security-review repo
- GitOps and IaC repos (slide 12 notes: about 312 writers on `argo-app-of-apps` and `rendered-k8s-manifests`, code-owner review required; 32 of 35 `*-infrastructure` repos require approval): branch rules and grants per repo, as the App, 2026-11-11
- `~/workspaces/cowork/github-security-review/self-service-github-requests-proposal.md`: the front door behind AWS Verified Access (AVA) with Okta sign-in, requests as PRs to `github-org-config`, the GitHub-to-Okta registry, and offboarding by daily check then Okta hook (slides 13 and 14)
- Security review `github-org-security-review.md`, finding 3 (no central deprovisioning, High) and the plan-gating table (SCIM `404` on Team): slide 14
- Deployment environments in use (3 of 102 Actions repos): `data/2026-11-11/workflows.json`, parsed as YAML
- Live org settings, checked with `gh api` on 2026-11-09: unchanged since the 2026-11-02 scan (Actions policy, workflow token, rulesets, 2FA, secrets)
- Wikis and issues to turn off (568 and 607, slide 6): `git ls-remote` on each wiki and a GraphQL issue count for all 771 active repos, 2026-11-09. In use: 6 wikis with content, 25 repos with issues
- Branch protection across all active repos (425 of 754 with a default branch have none; 429 don't require a PR; 17 empty repos): `gh api` on each repo's default branch (`branches/<b>/protection` and `rules/branches/<b>`), graded with the same rules as `scripts/check_protection.py`, 2026-11-09. Agrees with the scan's 29 of 101 for repos running Actions
- The VIDP secrets' dates (production 2022-08-23, staging rewritten 2023-02-28, develop 2023-03-16): `gh api orgs/VectorLearning/actions/secrets`, 2026-11-09. These are when the GitHub copies last changed; whether the keys were rotated in AWS isn't visible from GitHub
- Dependabot coverage (34 of 771): `gh api repos/VectorLearning/<repo>/vulnerability-alerts` for every active repo, 2026-11-09
- Team reports, linked on slides 5, 8 and 9:
  - [GitHub Actions: workflows that need a permissions block](https://lmsportal.atlassian.net/wiki/spaces/~712020beddc23505a94612b7dad1d37db24a00/pages/29594746887/GitHub+Actions+workflows+that+need+a+permissions+block) (COREOPS-4620): 43 files in 25 repos, 3 that must change
  - [GitHub Actions: action references to pin to a commit SHA](https://lmsportal.atlassian.net/wiki/spaces/~712020beddc23505a94612b7dad1d37db24a00/pages/29595041793/GitHub+Actions+action+references+to+pin+to+a+commit+SHA) (COREOPS-4622): 190 references in 66 files across 46 repos
- [Moving to GitHub Actions](../moving-to-github-actions/), slide 14: the earlier hardening timeline, including the end-of-January 2FA target

### People consulted
- Noel Aguilar, DevOps: audience (leads and leadership), month-level dates only, the App review and org-wide pinning both in Q4, 2FA at the end of January, Q1 shown as planned. On 2026-11-11: people, teams and access is a separate stream, in its own section after the plan, not folded into Q4 or Q1. Then: two team tiers per product (dev with write; maintainers with maintain), no org-admin team, and "nobody gets repo admin" called out on its own slide; an admins team per product only where a deploy needs it; most deploys go through GitOps (Actions only for Windows, GovCloud and Azure; Lambdas later through ACK); repo creation through an App DevOps builds; every repo gets a CODEOWNERS file. On 2026-11-12: say plainly that members lose repo creation, and add the Okta front door as the way people join and leave (slide 14)

### Design
- `~/OneDrive - Vector Solutions/Documents/presentations/offsites/2026-08-nj-rubric-update.pptx` (Noel Aguilar, 2026-08 offsite deck): the brand colors, the rounded-diamond outline motif and the title background
- `~/OneDrive - Vector Solutions/Documents/presentations/vector-template.pptx` (Vector Solutions PowerPoint template): the footer on its slide master (logo, then the strip's gradient `#96D448` → `#293D9A` → `#5AB7E6`)

### Data & assets
- `assets/brand-title.jpg`: the title and Questions background, taken unchanged from `ppt/media/image1.jpeg` in `2026-08-nj-rubric-update.pptx`
- `assets/vector-logo.png` and `assets/vector-logo-white.png`: the Vector Solutions logos, taken unchanged from `vector-template.pptx` (`ppt/media/image2.png` and `image7.png`). The white one is used on brand slides and in dark mode

## Notes

- **Slide 4 is by quarter only** (changed 2026-11-09 at the presenter's request). Slides 5 and 6 still give a proposed month per item, and slide 8 mentions "the December cut-over"; those months aren't committed.
- **People, teams and access (slides 9–14) is a separate stream, "proposed"**: not in the Q4 or Q1 plan, no epic, no dates. Slides 4, 7 and 8 deliberately don't mention it. Open: keep it in this session, or present it separately.
- **Q1 is "planned"**: no epic exists yet. The items come from the security review's backlog.
- **Org ruleset approvals (0 or 1)** are still undecided; the slides only say "PR required".
- **Evaluate mode on Team is unconfirmed** (GitHub's docs disagree), so slide 6 says "trial"; the notes give the pilot-repo fallback.
- **The Moving to GitHub Actions deck's slide 14 disagrees with this plan**: it says 11 Nov for the token, pinning and ruleset, and Dependabot per repo as repos migrate. Not changed here.
