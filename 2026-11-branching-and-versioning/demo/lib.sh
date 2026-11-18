# shellcheck shell=bash
# Shared helpers for the stage-demoN.sh scripts. Sourced, never run.
#
# Every helper takes the repository as owner/name and talks to GitHub through
# gh, so the scripts need only `gh auth status` to be green and an SSH key that
# can push to the demo repositories.

ATTRIBUTION_COMMIT='Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>'
ATTRIBUTION_PR='🤖 Generated with [Claude Code](https://claude.com/claude-code)'

# How long to wait for a pull request's checks or a workflow run, in seconds.
WAIT_LIMIT="${WAIT_LIMIT:-2700}"
POLL="${POLL:-20}"

log() { printf '%s  %s\n' "$(date '+%H:%M:%S')" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

# A UTC stamp that names this staging run's branches and changes.
stamp() { date -u '+%Y%m%d-%H%M%S'; }

# clone_repo owner/name -> sets REPO_DIR to a fresh clone in a temp folder,
# removed when the script exits. Not in $(...): the cleanup list must survive.
clone_repo() {
  local repo=$1 dir
  dir=$(mktemp -d "${TMPDIR:-/tmp}/stage-demo.XXXXXX")
  STAGE_TMP_DIRS+=("$dir")
  git clone --quiet "git@github.com:${repo}.git" "$dir/repo"
  git -C "$dir/repo" config user.name "$(git config --global user.name || echo 'Demo stager')"
  git -C "$dir/repo" config user.email "$(git config --global user.email || echo 'noreply@example.com')"
  # shellcheck disable=SC2034 # read by the sourcing script
  REPO_DIR="$dir/repo"
}
STAGE_TMP_DIRS=()
cleanup_tmp() { local d; for d in ${STAGE_TMP_DIRS[@]+"${STAGE_TMP_DIRS[@]}"}; do rm -rf "$d"; done; }
trap cleanup_tmp EXIT

# commit_and_push dir branch title -> commits everything staged in dir, pushes branch.
commit_and_push() {
  local dir=$1 branch=$2 title=$3
  git -C "$dir" commit --quiet -m "$title" -m "$ATTRIBUTION_COMMIT"
  git -C "$dir" push --quiet -u origin "$branch" 2>/dev/null
}

# open_pr repo base head title body -> prints the PR number.
open_pr() {
  local repo=$1 base=$2 head=$3 title=$4 body=$5 url
  url=$(gh pr create -R "$repo" --base "$base" --head "$head" --title "$title" \
    --body "$(printf '%s\n\n%s' "$body" "$ATTRIBUTION_PR")")
  log "opened $url"
  printf '%s\n' "${url##*/}"
}

# wait_for_checks repo pr context... -> waits until each named required check
# reports on the PR's current head, then until every check finishes, and fails
# when a required one did not pass. A check that runs only after other jobs
# (CI / CI result) is not listed until it starts, so `gh pr checks --watch`
# alone could return early.
wait_for_checks() {
  local repo=$1 pr=$2; shift 2
  local start=$SECONDS json missing ctx state
  log "waiting for the checks of $repo#$pr: $*"
  while :; do
    json=$(gh pr checks "$pr" -R "$repo" --json name,state,bucket 2>/dev/null || true)
    [[ -n "$json" ]] || json='[]'
    missing=()
    for ctx in "$@"; do
      state=$(jq -r --arg n "$ctx" 'map(select(.name == $n)) | .[0].bucket // "missing"' <<<"$json")
      case "$state" in
        pass) ;;
        fail|cancel) die "$repo#$pr: required check '$ctx' is $state" ;;
        *) missing+=("$ctx:$state") ;;
      esac
    done
    ((${#missing[@]} == 0)) && break
    ((SECONDS - start > WAIT_LIMIT)) && die "$repo#$pr: timed out waiting for ${missing[*]}"
    sleep "$POLL"
  done
  # Everything else (SCA, Helm) finishes too, so the page looks settled.
  gh pr checks "$pr" -R "$repo" --watch --interval "$POLL" >/dev/null 2>&1 || true
  log "$repo#$pr: required checks passed after $((SECONDS - start))s"
}

# wait_clean repo pr -> waits until GitHub has computed the merge state, and
# fails unless it is CLEAN (mergeable now, up to date, every rule met).
wait_clean() {
  local repo=$1 pr=$2 state start=$SECONDS
  while :; do
    state=$(gh pr view "$pr" -R "$repo" --json mergeStateStatus -q .mergeStateStatus)
    if [[ "$state" == CLEAN ]]; then log "$repo#$pr is CLEAN"; return 0; fi
    # GitHub recomputes the state lazily, so give it two minutes to settle.
    if ((SECONDS - start > 120)); then die "$repo#$pr mergeStateStatus is $state, not CLEAN"; fi
    sleep 5
  done
}

# merge_pr repo pr [extra gh pr merge args...] -> squash-merges, prints the merge commit SHA.
merge_pr() {
  local repo=$1 pr=$2; shift 2
  gh pr merge "$pr" -R "$repo" --squash "$@" >/dev/null
  local sha='' start=$SECONDS
  while [[ -z "$sha" ]]; do
    sha=$(gh pr view "$pr" -R "$repo" --json mergeCommit -q '.mergeCommit.oid // ""')
    [[ -n "$sha" ]] && break
    ((SECONDS - start > 120)) && die "$repo#$pr: no merge commit after merging"
    sleep 3
  done
  log "merged $repo#$pr as ${sha:0:7}"
  printf '%s\n' "$sha"
}

# wait_run repo workflow-file sha -> waits for that workflow's push run of the
# commit to appear and finish, and fails when it did not succeed.
wait_run() {
  local repo=$1 wf=$2 sha=$3 id='' start=$SECONDS
  while [[ -z "$id" ]]; do
    id=$(gh run list -R "$repo" --workflow "$wf" --commit "$sha" --event push --limit 1 \
      --json databaseId -q '.[0].databaseId // ""')
    [[ -n "$id" ]] && break
    ((SECONDS - start > 300)) && die "$repo: no $wf run for ${sha:0:7}"
    sleep 5
  done
  log "watching $wf run $id (https://github.com/$repo/actions/runs/$id)"
  gh run watch "$id" -R "$repo" --exit-status --interval "$POLL" >/dev/null 2>&1 \
    || die "$repo: $wf run $id did not succeed"
  printf '%s\n' "$id"
}

# open_pr_by_head repo head-branch -> prints the open PR number from that branch, or nothing.
open_pr_by_head() {
  gh pr list -R "$1" --head "$2" --state open --json number -q '.[0].number // ""'
}

# epoch 2026-11-18T00:18:06Z -> seconds since 1970 (BSD or GNU date).
epoch() { date -u -j -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s 2>/dev/null || date -u -d "$1" +%s; }

# version_from_title "chore(main): release echo 4.6.0" -> 4.6.0
version_from_title() { awk '{print $NF}' <<<"$1"; }
