#!/usr/bin/env bash
# Demo 1, Continuous versioning (poc_echo_server_dotnet).
#
# Stages one feat(echo) pull request on a feat/demo-<stamp> branch with its
# branch build green, and does NOT merge it: the presenter squash-merges it live,
# and main's build computes the next minor, pushes the image with that version
# and tags the commit.
#
# Re-runnable: an earlier staged pull request still open (feat/demo-*) is closed
# first, so only one is ever waiting. Run it again after a rehearsal.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
source "$here/lib.sh"

REPO=VectorLearning/poc_echo_server_dotnet
CHECKS=("PR / Lint PR title" "CI / CI result")
STAMP=$(stamp)

for old in $(gh pr list -R "$REPO" --state open --json number,headRefName \
  -q '.[] | select(.headRefName | startswith("feat/demo-")) | .number'); do
  log "closing the earlier staged PR #$old"
  gh pr close "$old" -R "$REPO" --delete-branch --comment "Superseded by a new demo staging." >/dev/null
done

clone_repo "$REPO"
dir=$REPO_DIR
latest=$(git -C "$dir" tag -l 'v*' --sort=-v:refname | head -1)
[[ -n "$latest" ]] || die "no v* tag in $REPO"
IFS=. read -r major minor _ <<<"${latest#v}"
expected="$major.$((minor + 1)).0"

# Nothing of the module's may be unreleased on main, or the live version would
# include it. The module is src/Services/Echo plus src/docker/entrypoint.sh.
unreleased=$(git -C "$dir" log --oneline "$latest..origin/main" -- src/Services/Echo src/docker/entrypoint.sh)
[[ -z "$unreleased" ]] || die "main has unreleased Echo changes since $latest:
$unreleased"

branch="feat/demo-$STAMP"
git -C "$dir" switch --quiet -c "$branch"
file="$dir/src/Services/Echo/Echo.Domain/DemoStamp.cs"
cat > "$file" <<EOF
namespace Echo.Domain
{
    // Changed by the Branching and Versioning demo's stage script.
    public static class DemoStamp
    {
        public const string Value = "continuous-versioning $STAMP";
    }
}
EOF
git -C "$dir" add "$file"
title="feat(echo): stamp the demo build $STAMP"
commit_and_push "$dir" "$branch" "$title"
pr=$(open_pr "$REPO" main "$branch" "$title" \
  "A feature for the Continuous versioning demo. Merging it cuts the next minor, $expected, from main's build.")

wait_for_checks "$REPO" "$pr" "${CHECKS[@]}"
wait_clean "$REPO" "$pr"

run=$(gh run list -R "$REPO" --branch "$branch" --workflow ci.yml --limit 1 --json databaseId -q '.[0].databaseId')
image_tag=$(gh run view "$run" -R "$REPO" --log 2>/dev/null | grep -o 'echo\.api:[A-Za-z0-9._-]*' | sort -u | head -1 || true)

cat <<EOF

Demo 1 staged ($REPO)
  PR to merge live:   https://github.com/$REPO/pull/$pr  ($title)
  Branch build image: noel/${image_tag:-echo.api:<see run $run>}
  Last version:       $latest
  Expected live:      v$expected (main's build tags the merge commit and pushes noel/echo.api:$expected)
EOF
