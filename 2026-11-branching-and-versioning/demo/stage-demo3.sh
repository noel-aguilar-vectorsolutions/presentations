#!/usr/bin/env bash
# Demo 3, release-please with release branches (release-please-branches-demo).
#
# 1. Merges any forward-port PR still open into main (a rehearsal leaves one),
#    so main's release PR is not held by the missing-ports rule.
# 2. Merges one feat(echo) pull request to main: unreleased, so main's release
#    PR proposes the next minor.
# 3. Merges one fix(echo) pull request into the newest release/X.Y.x. The
#    release App opens its forward-port PR to main at once, and release-please
#    opens or updates that branch's release PR for the next patch.
# 4. Waits for the release branch's release PR to be mergeable.
#
# The presenter merges the release branch's release PR live: tag vX.Y.Z, the
# GitHub Release, the re-tag of release/X.Y.x's image. The forward-port PR is
# already open (it opens when the fix merges, not when the release does).
#
# Re-runnable: run it again after a rehearsal.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
source "$here/lib.sh"

REPO=VectorLearning/release-please-branches-demo
CHECKS=("PR / Lint PR title" "CI / CI result" "release-please / release-pr-version-check")
STAMP=$(stamp)

clone_repo "$REPO"
dir=$REPO_DIR

# 1. Ports left open by an earlier run or rehearsal.
for port in $(gh pr list -R "$REPO" --state open --base main --json number,headRefName \
  -q '.[] | select(.headRefName | startswith("forward-port/")) | .number'); do
  log "merging the open forward-port PR #$port into main"
  # A port opened before a later merge to main is behind it; bring it up to date.
  if [[ "$(gh pr view "$port" -R "$REPO" --json mergeStateStatus -q .mergeStateStatus)" == BEHIND ]]; then
    gh pr update-branch "$port" -R "$REPO" >/dev/null
    sleep 10
  fi
  wait_for_checks "$REPO" "$port" "${CHECKS[@]}"
  wait_clean "$REPO" "$port"
  sha=$(merge_pr "$REPO" "$port")
  wait_run "$REPO" ci.yml "$sha" >/dev/null
done

# stage_change type base file description -> one PR into base, merged after its
# checks, then base's build of the merge waited for; prints the PR number and SHA.
stage_change() {
  local type=$1 base=$2 file=$3 what=$4 branch title pr sha
  branch="$type/demo-$STAMP"
  git -C "$dir" fetch --quiet origin "$base"
  git -C "$dir" switch --quiet -c "$branch" "origin/$base"
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
  pr=$(open_pr "$REPO" "$base" "$branch" "$title" "A $type: change for the release-branches demo, into \`$base\`.")
  wait_for_checks "$REPO" "$pr" "${CHECKS[@]}"
  wait_clean "$REPO" "$pr"
  sha=$(merge_pr "$REPO" "$pr")
  # The build pushes the <branch>-<run> images the release re-tags.
  wait_run "$REPO" ci.yml "$sha" >/dev/null
  printf '%s %s\n' "$pr" "$sha"
}

# 2. A feature on main, left unreleased.
out=$(stage_change feat main DemoFeature "stamp the demo feature")
read -r _ main_sha <<<"$out"
wait_run "$REPO" release-please.yml "$main_sha" >/dev/null

# 3. A fix on the newest release branch.
git -C "$dir" fetch --quiet origin '+refs/heads/release/*:refs/remotes/origin/release/*'
line=$(git -C "$dir" for-each-ref --format='%(refname:lstrip=3)' 'refs/remotes/origin/release/' \
  | sed -n 's#^release/\([0-9]*\)\.\([0-9]*\)\.x$#\1 \2 &#p' | sort -k1,1n -k2,2n | tail -1 | cut -d' ' -f3)
[[ -n "$line" ]] || die "no release/X.Y.x branch in $REPO"
log "newest release branch: $line"
out=$(stage_change fix "$line" DemoFix "stamp the demo fix")
read -r fix_pr fix_sha <<<"$out"
wait_run "$REPO" release-please.yml "$fix_sha" >/dev/null

# 4. The release branch's release PR, and the port the fix got.
rel_pr=$(open_pr_by_head "$REPO" "release-please--branches--$line")
[[ -n "$rel_pr" ]] || die "no open release PR from release-please--branches--$line"
wait_for_checks "$REPO" "$rel_pr" "${CHECKS[@]}"
wait_clean "$REPO" "$rel_pr"
rel_title=$(gh pr view "$rel_pr" -R "$REPO" --json title -q .title)

port_head="forward-port/$(tr / - <<<"$line")/$fix_pr/main"
port_pr=$(open_pr_by_head "$REPO" "$port_head")
port_info="none open from $port_head: check the fix's comment"
if [[ -n "$port_pr" ]]; then
  port_at=$(epoch "$(gh pr view "$port_pr" -R "$REPO" --json createdAt -q .createdAt)")
  fix_merged_at=$(epoch "$(gh pr view "$fix_pr" -R "$REPO" --json mergedAt -q .mergedAt)")
  port_info="https://github.com/$REPO/pull/$port_pr (opened about $((port_at - fix_merged_at))s after the fix PR was merged)"
fi

main_pr=$(open_pr_by_head "$REPO" release-please--branches--main)
main_title=$(gh pr view "$main_pr" -R "$REPO" --json title -q .title 2>/dev/null || echo '?')

cat <<EOF

Demo 3 staged ($REPO)
  Release PR to merge live: https://github.com/$REPO/pull/$rel_pr  ($rel_title)
  Expected live:            v$(version_from_title "$rel_title") (tag, GitHub Release, re-tag of noel/rpb-echo.api's $(tr / - <<<"$line") image)
  Fix merged to $line:  https://github.com/$REPO/pull/$fix_pr
  Its forward-port to main: $port_info
  main's release PR:        https://github.com/$REPO/pull/$main_pr  ($main_title)
                            (the missing-ports rule fails its version check on its next update while the port is open)
EOF
