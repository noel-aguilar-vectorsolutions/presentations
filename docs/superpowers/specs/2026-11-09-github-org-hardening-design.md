# GitHub org hardening: Q4 and Q1 — presentation design

**Date:** 2026-11-09
**Owner / presenter:** Noel Aguilar
**Deliverable:** a new presentation in this repo, `2026-11-github-org-hardening/`, built from `_template/`
following [`CLAUDE.md`](../../../CLAUDE.md) and the [presentation guide](../../presentation-guide.md).

## Intent

Present the security changes DevOps will make to the VectorLearning GitHub organization, split into
what happens **this quarter (Q4 2026)** and **next quarter (Q1 2027)**. The tone is **inform and
align**: here is what's wrong today, what we're changing and when, what it asks of teams, and how
we'll know it worked. It is not asking for a decision, except to name the one open item (approval
count on the org ruleset) if the presenter wants input.

## Audience

A mixed room of **engineering leads and leadership**. Leads care about what their teams must do and
when; leadership cares about the risk being reduced, the timeline and the cost. Most have seen, or
will see, the *Moving to GitHub Actions* deck, so they know the Actions migration is happening, but
not the org-level findings.

## Goals

After the session, someone in the room should:

1. Know **why now**: the Actions migration makes CI security an org-level concern, and the org's
   defaults have never been hardened.
2. Know the **Q4 changes** (epic COREOPS-4617) and roughly which month each lands in.
3. Know the **Q1 changes**, led by **2FA enforcement at the end of January 2027**, which removes
   members who haven't enrolled.
4. Know **what their teams must do**, and that most teams need to do nothing.
5. Know that it **costs nothing extra**: everything runs on the GitHub Team plan we already pay for.

## Non-goals

- How each setting works internally, or the API calls. The Jira stories hold that.
- The full audit findings list. The deck uses the headline numbers only.
- CI/CD process changes (paved road, versioning, release-please). Those belong to the
  *Moving to GitHub Actions* deck.
- Enterprise Cloud features (SSO, SCIM, audit log, secret scanning). They come up only as the Q1
  pricing decision.

## Anti-goals

- Reading like an audit report: a wall of findings with no plan attached.
- Sounding alarming, or blaming anyone. The gaps exist because GitHub's defaults are open, not
  because anyone got something wrong.
- Exact dates that aren't committed. Q4 items show a **month only**; 2FA is the only exact target.
- Inventing figures. Every number comes from the 2026-11-02 scan or the Jira stories.

## Constraints

- **15 minutes total, including Q&A.** About 12 minutes of slides and 3 of questions.
- Accurate as of **the week of 2026-11-09**. Checked on 2026-11-09: all 11 Q4 stories are still in
  Backlog and no org setting has changed since the 2026-11-02 scan, so its figures stand.
- Repo conventions from `CLAUDE.md`: scaffold with `./new-presentation.sh`; self-contained
  `index.html`; every source in the deck README; `slides.md` exported; Index row in the root README.

## Structure and timing

| # | Slide | ~Min |
|---|---|---|
| 1 | Title | 0.5 |
| 2 | **Why now**: Actions migration; ~800 active repos; GitHub's open defaults; the March 2025 `tj-actions` compromise as the example | 1.5 |
| 3 | **Where we are today**: six gaps, one number each | 2 |
| 4 | **The plan at a glance**: Q4 and Q1 on one timeline | 1.5 |
| 5 | **Q4: secure the CI supply chain**: token, pinning, allowlist, plus the two reports | 2 |
| 6 | **Q4: guardrails and cleanup**: org ruleset, Dependabot, AWS keys, unused features, public repos, App access | 1.5 |
| 7 | **Q1: identity and access**: 2FA (end of January), service accounts, owners, and the rest | 1.5 |
| 8 | **What teams need to do**, and how we'll measure progress | 1.5 |
| 9 | Questions | 3 |
| | **Total** | **15** |

## Content by slide

### 2. Why now
- CI is moving to GitHub Actions, so the org's Actions settings now protect every pipeline.
- Defaults were never hardened, and with ~800 active repos, per-repo setup has left uneven coverage.
- The `tj-actions/changed-files` compromise (March 2025): a moved tag ran attacker code in thousands
  of pipelines. Our current settings would have let it run here.
- Everything in this plan is on the **Team plan we already pay for**. No new licences.

### 3. Where we are today (2026-11-02 scan)
| Gap | Number |
|---|---|
| Actions on movable tags, any Marketplace action allowed | 196 references in 47 repos |
| Workflows get a write token by default; Actions can approve PRs | org default |
| Repos running Actions with no branch protection | 30 of 102 |
| Repos with Dependabot alerts on | 34 of 793 |
| Members without 2FA | 184 of 370, plus 9 of 12 outside collaborators |
| Unused static AWS credentials, unrotated since 2022–23 | 9 |

### 4. The plan at a glance
A two-lane timeline: **Q4 2026** (Nov, Dec) and **Q1 2027** (Jan, Feb, Mar), with the 2FA enforcement
milestone at the end of January marked.

**Proposed month placement (presenter to confirm, open question 1):**

| Month | Item |
|---|---|
| November | Publish the two team reports (token, pinning); deactivate the AWS keys; org ruleset in evaluate mode; Dependabot org-wide; SHA pinning on for already-compliant repos; public-repo creation restricted; unused wikis/issues/projects off |
| December | `GITHUB_TOKEN` read-only; approved-actions allowlist; org ruleset active; SHA pinning org-wide; AWS keys deleted; GitHub App access narrowed |
| January | 2FA announcement and enrolment drive; service accounts moved off passwords; **2FA enforced end of January** |
| February–March | Reduce org owners; harden the Claude review workflow; archive dormant repos; Enterprise Cloud pricing decision |

### 5. Q4: secure the CI supply chain
- **Pin every action to a commit SHA**, then require it. Report to teams first; already-compliant
  repos are locked in straight away; org-wide once the report reaches zero.
- **Only approved actions run**: VectorLearning's own, GitHub's, and 22 named third-party actions,
  which is everything in use today. New ones by request.
- **`GITHUB_TOKEN` read-only by default**; Actions can't approve PRs. Only 3 workflows need a
  one-line change.

### 6. Q4: guardrails and cleanup
- **Org ruleset**: every repo's default branch requires a PR. Two weeks in evaluate mode first. Repos
  can add stricter rules on top.
- **Dependabot** on for all repos (34 → 793), with a named triage owner.
- **Static AWS keys** deactivated, then deleted.
- **Unused** wikis, issues and projects off (in-use ones untouched); **public repos** by owners only;
  **GitHub Apps** with access to every repo narrowed after review with their owners.

### 7. Q1: identity and access
- **2FA enforced at the end of January 2027.** Enforcement *removes* anyone not enrolled: 184 members
  and 9 outside collaborators today. A January announcement and enrolment drive comes first.
- **4 service accounts** (Jenkins, CircleCI and CI bot accounts, and the Convergence integration)
  move off password auth first, or their pipelines break at enforcement.
- **Org owners** reduced from 17 to 4–6.
- **Claude review workflow** hardened in the 16 repos that use it.
- **78 repos** untouched for 2+ years archived, with owners consulted.
- **Runner groups** locked down before the first self-hosted runner (none exist today).
- **Enterprise Cloud pricing** decision: the only route to SSO, SCIM, the audit log and secret
  scanning.

### 8. What teams need to do, and how we'll measure it
- **Most teams: nothing.**
- 3 repos add a `permissions:` line; 47 repos pin their actions (report gives the exact SHA);
  3 repos replace retiring actions by 2027-01-31; anyone whose automation pushes straight to `main`
  tells us during the evaluate window; **everyone enables 2FA before the end of January**.
- Measures: unpinned refs 196 → 0; unprotected Actions repos 30 → 0; Dependabot 34 → 793 repos;
  members without 2FA 184 → 0; static AWS credentials 9 → 0.

## Left to the builder

Visual design within the template; the timeline as an inline SVG (`dg-*`) or cards; exact wording;
whether slides 5 and 6 use `.cards` or a table.

## Sources

- GitHub org security review: `~/workspaces/cowork/github-security-review` (report, remediation
  backlog, `coreops-4617-tickets.md`, `coreops-4617-announcement.md`, snapshot `data/2026-11-02`)
- Published review: https://claude.ai/artifact/U1BikdRZ9RVYXc5c5TCXmN (private)
- Jira epic [COREOPS-4617](https://lmsportal.atlassian.net/browse/COREOPS-4617) and stories
  COREOPS-4619 to COREOPS-4629 (status checked 2026-11-09: all Backlog)
- Live org settings checked with `gh api` on 2026-11-09 (unchanged since the scan)
- *Moving to GitHub Actions* deck, slide 14 (the earlier hardening timeline)
- GitHub changelog: organization rulesets on Team (2025-06-16); SHA pinning in the Actions policy
  (2025-08-15)

## Open questions

1. **Month placement** in the slide 4 table: is that the order you want to commit to?
2. **Org ruleset approvals**: 0 or 1? The slide can say "PR required" either way, but leadership may ask.
3. **The earlier deck's slide 14 now disagrees with this plan.** It says 11 Nov for the token, pinning
   and ruleset, and Dependabot per repo as it migrates. Should it be updated to match, separately?
4. **Q1 items aren't in Jira yet.** Should the Q1 slide show them as "planned" (no tickets), or will
   you create a Q1 epic before presenting?
