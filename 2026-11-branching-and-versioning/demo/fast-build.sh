#!/usr/bin/env bash
# Trim a demo repository's build for the live session, or restore it after.
# Usage: fast-build.sh trim|restore <owner/repo> [staged PR numbers to update...]
#
# trim:    build-config.json builds only Echo.Api and runs no tests
#          (unit-test-projects [] and no integration-test-compose-file), so a
#          main build takes about 2 minutes instead of 5. The PR only touches
#          build-config.json: it cuts no version and releases nothing.
# restore: puts back the build-config.json the trim PR replaced, by reverting
#          the trim PR's merge commit.
# Then each staged PR given is brought up to date with main (Update branch),
# and its checks are waited for, so it is mergeable again.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
source "$here/lib.sh"

mode=${1:-}; REPO=${2:-}; shift 2 || true
[[ "$mode" == trim || "$mode" == restore ]] && [[ -n "$REPO" ]] || die "usage: $0 trim|restore owner/repo [pr...]"

checks=("PR / Lint PR title" "CI / CI result")
[[ "$REPO" == */release-please-* ]] && checks+=("release-please / release-pr-version-check")

clone_repo "$REPO"
dir=$REPO_DIR
STAMP=$(stamp)
branch="chore/demo-build-$mode-$STAMP"
git -C "$dir" switch --quiet -c "$branch" origin/main

if [[ "$mode" == trim ]]; then
  jq '.modules |= with_entries(.value |= (
        .images = [.images[] | select(.name == "Echo.Api")]
      | (if has("scan-projects") then .["scan-projects"] |= map(select(. == "Echo.Api")) else . end)
      | .["unit-test-projects"] = []
      | del(.["integration-test-compose-file"])))' \
    "$dir/build-config.json" > "$dir/build-config.json.new"
  mv "$dir/build-config.json.new" "$dir/build-config.json"
  title="chore(ci): build only Echo.Api, with no tests, for the live demo"
  body="Temporary, for the Branching and Versioning session: the main build drops from about 5 minutes to about 2. Restored after the session by reverting this PR."
else
  sha=$(git -C "$dir" log origin/main --format=%H --grep '^chore(ci): build only Echo.Api, with no tests, for the live demo' -1)
  [[ -n "$sha" ]] || die "no trim commit on main to revert"
  git -C "$dir" checkout --quiet "${sha}^" -- build-config.json
  title="chore(ci): restore the full build after the live demo"
  body="Restores build-config.json as it was before ${sha:0:7}: every image, unit and integration tests."
fi

git -C "$dir" add build-config.json
commit_and_push "$dir" "$branch" "$title"
pr=$(open_pr "$REPO" main "$branch" "$title" "$body")
wait_for_checks "$REPO" "$pr" "${checks[@]}"
wait_clean "$REPO" "$pr"
merge_pr "$REPO" "$pr" >/dev/null
log "merged $REPO#$pr"

for staged in "$@"; do
  log "updating $REPO#$staged with main"
  gh api -X PUT "repos/$REPO/pulls/$staged/update-branch" >/dev/null
  sleep 10
  wait_for_checks "$REPO" "$staged" "${checks[@]}"
  wait_clean "$REPO" "$staged"
  log "$REPO#$staged is mergeable"
done
