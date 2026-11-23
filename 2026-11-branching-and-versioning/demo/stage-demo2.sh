#!/usr/bin/env bash
# Demo 2, plain release-please (release-please-demo).
#
# Merges one feat(echo) and one fix(echo) pull request to main, each after its
# checks pass, waits for main's builds and for release-please to update its
# release PR, and checks that release PR is mergeable. The presenter merges the
# release PR live: tag echo@vX.Y.Z, the GitHub Release, and the re-tag of the
# image main already built.
#
# Re-runnable: each run adds one more feat and fix to whatever is unreleased, so
# run it once after a rehearsal's release, not twice in a row.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
source "$here/lib.sh"

REPO=VectorLearning/release-please-demo
CHECKS=("PR / Lint PR title" "CI / CI result" "release-please / release-pr-version-check")
RELEASE_HEAD=release-please--branches--main--components--echo
STAMP=$(stamp)

clone_repo "$REPO"
dir=$REPO_DIR
latest=$(git -C "$dir" tag -l 'echo@v*' --sort=-v:refname | head -1)
log "last release: $latest"

# stage_change type file description -> one PR to main, merged after its checks,
# then main's build of the merge waited for; prints the merge SHA.
stage_change() {
  local type=$1 file=$2 what=$3 branch title pr sha
  branch="$type/demo-$STAMP"
  git -C "$dir" fetch --quiet origin main
  git -C "$dir" switch --quiet -c "$branch" origin/main
  cat > "$dir/src/Services/Echo/Echo.Domain/$file.cs" <<EOF
namespace Echo.Domain
{
    // Changed by the Branching and Versioning demo's stage script.
    public static class $file
    {
        public const string Value = "$what $STAMP";
    }
}
EOF
  git -C "$dir" add "src/Services/Echo/Echo.Domain/$file.cs"
  title="$type(echo): $what $STAMP"
  commit_and_push "$dir" "$branch" "$title"
  pr=$(open_pr "$REPO" main "$branch" "$title" "A $type: change for the plain release-please demo.")
  wait_for_checks "$REPO" "$pr" "${CHECKS[@]}"
  wait_clean "$REPO" "$pr"
  sha=$(merge_pr "$REPO" "$pr")
  # main's build pushes the main-<run> images the release re-tags.
  wait_run "$REPO" ci.yml "$sha" >/dev/null
  printf '%s\n' "$sha"
}

stage_change feat DemoFeature "stamp the demo feature" >/dev/null
sha=$(stage_change fix DemoFix "stamp the demo fix")

wait_run "$REPO" release-please.yml "$sha" >/dev/null
pr=$(open_pr_by_head "$REPO" "$RELEASE_HEAD")
[[ -n "$pr" ]] || die "no open release PR from $RELEASE_HEAD"
wait_for_checks "$REPO" "$pr" "${CHECKS[@]}"
wait_clean "$REPO" "$pr"
title=$(gh pr view "$pr" -R "$REPO" --json title -q .title)

cat <<EOF

Demo 2 staged ($REPO)
  Release PR to merge live: https://github.com/$REPO/pull/$pr  ($title)
  Last release:             $latest
  Expected live:            echo@v$(version_from_title "$title") (tag, GitHub Release, re-tag of noel/echo.api)
EOF
