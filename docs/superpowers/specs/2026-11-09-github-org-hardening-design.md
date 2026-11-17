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

---

## Addendum (2026-11-11): people, teams and access, a separate stream

**Decision (presenter, 2026-11-11):** the user, team and repo-access findings are a **separate
stream**, not part of the Q4/Q1 hardening plan. They get their own section **after** the hardening
slides and before Questions. Nothing in slides 1–8 changes to absorb them. If the stream later joins
the plan, slides 4, 7 and 8 get adjusted then.

### Intent

Show the room the second problem: who has access, and how access is granted. Then show the
direction DevOps proposes. Tone stays **inform**, but this part is explicitly **proposed**: no
epic, no dates, no commitments. That keeps it apart from the Q4 work (ticketed) and the Q1 work
(planned).

### Structure and timing

| # | Slide | ~Min |
|---|---|---|
| 9 | Section divider: *People, teams and access*, a separate stream, proposed | 0.25 |
| 10 | **Where we are today**: six numbers, one each, in the style of slide 3 | 1.5 |
| 11 | **What we propose**: six moves, in the style of slide 6, marked *proposed* | 1.5 |
| 12 | **The access model: nobody gets repo admin, by default**: who gets which role, and what becomes a request | 1.5 |
| 13 | **Getting there**: three steps, with the repo-creation App as the dependency | 1.25 |
| 14 | **Joining and leaving, tied to Okta** (added 2026-11-12): the front door as a SCIM-like substitute on Team | 1.25 |
| 15 | Questions (unchanged) | 3 |

The section adds **about 7 minutes**, so the session runs **about 22 minutes**. Left over target on purpose:
the presenter will trim later if needed. Slide 6 to 30 seconds, per the review, is the obvious first cut.

### Content

**Slide 10: where we are** (`analysis/people-2026-11-11`, collected 2026-11-11 as the read-only
`vectorlearning-org-reader` GitHub App):

| Number | What it says |
|---|---|
| 102 of 362 | human accounts don't follow the username standard; 20 look like personal accounts, including one org owner |
| 303 of 370 | members get access through one team, `vector-engineering` (read on ~290 active repos, write on 64) |
| 38% | of repo access goes to individuals, not teams; two-thirds of those grants are admin |
| 117 | active repos with no team or person granted; only org owners can reach them |
| 21 of 175 | teams are unused: no members, or no access to anything active |
| 12 | outside collaborators; half look like our own staff added to a single repo |

**Slide 11: what we propose:**

- **Standard accounts:** about 80 rename in place, keeping their history; 20 personal accounts are
  replaced; contractors are marked `-ctr`.
- **One team pattern:** per product, a dev team with write, and a maintainers team under it. Every
  team has a named owner, and **every repo has a CODEOWNERS file naming its team**. Today 175 of 776
  active repos have one.
- **Access through teams:** "194 times, someone was added to a repo individually with access their team
  already gives them." Those go first and change nothing. The rest move into product teams.
- **Repos start with an owner:** the requester asks through a self-service front door, and an App creates
  each repo with its teams, CODEOWNERS and the baseline. Nobody creates repos by hand, DevOps included
  (presenter, 2026-11-12).
- **Clean up:** unused teams removed; ownerless repos get an owning team, or are archived.
- **Outside collaborators sponsored:** staff become members; the rest get a named sponsor and an end
  date; a monthly read-only check flags new ones.

**Slide 12: the access model.** Added 2026-11-11 at the presenter's request ("call out that nobody gets
repo admin"), then refined the same day:

| Who | On repos |
|---|---|
| Org owners (about 10, after Q1) | Admin on every repo, through the org role |
| All engineers | Read, through the org-wide engineering team (kept read-only) |
| A product's dev team | Write |
| Its maintainers team (child of dev) | Maintain |
| A product's admins team | Admin, **only on repos that deploy from GitHub, and only if needed** |
| GitOps and infrastructure repos | Every merge approved by the owning team and DevOps (CODEOWNERS) |
| Individuals | Nothing directly |

- **No org-admin team,** now or later.
- **Admin-only, done on request:** granting access; branch protection and rulesets; deployment
  environments and their secrets; webhooks and deploy keys; visibility, archiving, deleting,
  transferring.
- **Maintainers keep:** merging, releases, most settings, Actions secrets and deploys. Write is
  enough for repo secrets and for running deploys.
- **Deploys:** most go through **GitOps**, not Actions (Lambdas later through ACK). Only the
  **Windows, GovCloud and Azure** deploys run from Actions. DevOps sets up their environments while
  migrating them.
- **Admins teams** have one to three named people, admin only on the deploying repos, created on
  request with a recorded reason, and reviewed each quarter. The monthly check flags admin outside
  them.
- **GitOps and infrastructure repos:** a merge is a deploy. Today `argo-app-of-apps` and
  `rendered-k8s-manifests` require a PR, 1 approval and code-owner review, but about 312 people can
  write to them. `argo-app-of-apps-dev` requires no PR. Of 35 `*-infrastructure` repos, 32 require
  at least 1 approval and 31 code-owner review.
- **No in-between role on Team:** custom repository roles need Enterprise Cloud.

**Slide 13: getting there:**

1. **Admin moves into teams:** personal grants fold into each product's teams. The maintainers team
   keeps **admin** for now, so nothing breaks. It is named `-maintainers` from day one, so only its
   permission changes later.
2. **Build the request paths:** one front door, an internal app behind AVA with Okta sign-in, for new
   repos and access changes. It opens PRs to `github-org-config`; after review, a repo-creation App (a
   separate App with write access) makes the change. Every repo gets a CODEOWNERS file: the App adds one
   to new repos, and existing repos get one by PR.
3. **Drop to maintain:** repo creation is turned off for members and only the App creates repos; maintainers drop to maintain; an admins team only
   where a deploy needs one.

Callout: *the repo-creation App is the dependency; step 3 waits until it works.* The interim risk,
admins adding outside collaborators, is covered by the monthly check. The Q4 org ruleset still binds
repo admins.

**Slide 14: joining and leaving, tied to Okta** (added 2026-11-12, presenter's request):

- Left: one way in (join through the front door; it checks the username standard and records which Okta
  person owns which GitHub account), one way out (Okta deactivation removes the GitHub account), and a
  daily check both ways (GitHub accounts with no Okta owner; Okta owners no longer active).
- Right: a comparison with SSO + SCIM on Enterprise Cloud. Tied to Okta ✓ / ✓; removed when someone leaves:
  immediately / within a day; Okta needed to sign in to GitHub ✓ / ✗; extra licence: yes / none.
- Callout: leaving Okta means leaving GitHub, within a day rather than the moment the account is deactivated.
- Notes explain SCIM in a sentence, state the gap honestly (tokens and SSH keys work until removal), and name
  the two conditions: backfill existing members, and the front door is the only way in.
- Framing: **not SSO**. It's the SCIM half (lifecycle), not the SSO half (sign-in). Don't call it SSO on a slide.

### Anti-goals for this section

- **No named individuals on slides.** Logins appear in the review, not the deck. Use counts only.
- **No blame.** These gaps grew from open defaults and from creators becoming admins, not from
  anyone's mistake.
- **No dates or tickets.** Everything is *proposed*.

### Sources (addendum)

- CODEOWNERS coverage (175 of 776 active repos; 140 name only teams, 14 teams and people, 21 only people):
  batched GraphQL for `.github/CODEOWNERS`, `CODEOWNERS` and `docs/CODEOWNERS` on every active repo, as
  the App, 2026-11-11. Result in `analysis/people-2026-11-11/codeowners.json`
- GitOps and IaC protection and writer counts: `rules/branches/<b>` and `branches/<b>/protection` per repo,
  plus team and direct grants from `analysis/people-2026-11-11`, as the App, 2026-11-11. GitOps repos
  identified from Argo and ACK manifests in the local clones (`~/workspaces/org-repos/VectorLearning`)
- Which workflows use deployment environments (3 of 102 Actions repos): `data/2026-11-11/workflows.json`,
  parsed as YAML
- Deploy approach (GitOps for most; Actions only for Windows, GovCloud and Azure; Lambdas later through
  ACK): Noel Aguilar, 2026-11-11

- GitHub docs, [repository roles for an organization](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/repository-roles-for-an-organization):
  Maintain ✗ / Admin ✓ for managing access, branch protection and rulesets, visibility, archiving,
  deleting or transferring, webhooks and deploy keys. Write and above can manage Actions secrets
- GitHub docs, [using secrets in GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
  (repo secrets need `write`; environment secrets need `admin`) and
  [managing environments](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment)
  (configuring an environment needs `admin`)
- GitHub docs, [about custom repository roles](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-repository-roles/about-custom-repository-roles):
  Enterprise Cloud only

- Self-service requests proposal (front door behind AVA, registry, offboarding): `~/workspaces/cowork/github-security-review/self-service-github-requests-proposal.md`
- Security review finding 3 (no central deprovisioning, High) and SCIM `404` on Team: `github-org-security-review.md`
- People, teams and access review: `~/workspaces/cowork/github-security-review/analysis/people-and-teams-review.md`
- Data: `analysis/people-2026-11-11/` (`summary.json`), collected 2026-11-11 with
  `scripts/collect_people.py` and `scripts/analyze_people.py`, as the `vectorlearning-org-reader` App

### Open questions (addendum)

5. **Same session or its own?** At about 22 minutes, keep it here, trim slide 6, or present the stream
   separately?
6. **Ownership:** who owns the people stream: DevOps alone, or with engineering managers? Renames and
   team moves need managers' help.
