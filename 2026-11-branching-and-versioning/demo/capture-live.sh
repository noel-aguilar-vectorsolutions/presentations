#!/usr/bin/env bash
# capture-live.sh <demo 1|2|3> <merged PR number> [label]
#
# Run right after the live merge (or a rehearsal's). Waits for each result the
# demo shows, prints how long after the merge it appeared, and saves the
# captures under captures/demoN-<label>-*.{json,txt}. label defaults to "live".
#
#   demo 1: the PR is the feat PR on poc_echo_server_dotnet
#   demo 2: the PR is the release PR on release-please-demo
#   demo 3: the PR is the release branch's release PR on release-please-branches-demo
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=lib.sh
source "$here/lib.sh"

demo=${1:?demo number}; pr=${2:?merged PR number}; label=${3:-live}
case "$demo" in
  1) REPO=VectorLearning/poc_echo_server_dotnet; WF=ci.yml; IMAGE=echo.api ;;
  2) REPO=VectorLearning/release-please-demo; WF=release-please.yml; IMAGE=echo.api ;;
  3) REPO=VectorLearning/release-please-branches-demo; WF=release-please.yml; IMAGE=rpb-echo.api ;;
  *) die "demo is 1, 2 or 3" ;;
esac
out="$here/captures/demo$demo-$label"
mkdir -p "$here/captures"

pr_json=$(gh pr view "$pr" -R "$REPO" --json number,title,body,url,baseRefName,headRefName,mergedAt,mergeCommit)
merged_at=$(jq -r '.mergedAt // ""' <<<"$pr_json")
[[ -n "$merged_at" ]] || die "$REPO#$pr is not merged yet"
sha=$(jq -r .mergeCommit.oid <<<"$pr_json")
t0=$(epoch "$merged_at")
printf '%s\n' "$pr_json" > "$out-pr.json"
timings="$out-timings.txt"
{ echo "# demo $demo, $REPO#$pr merged at $merged_at as ${sha:0:7}"; } > "$timings"
mark() { local msg="+$(( $(date -u +%s) - t0 ))s  $1"; log "$msg"; echo "$msg" >> "$timings"; }

# The run the merge started.
run=''
while [[ -z "$run" ]]; do
  run=$(gh run list -R "$REPO" --workflow "$WF" --commit "$sha" --event push --limit 1 --json databaseId -q '.[0].databaseId // ""')
  [[ -n "$run" ]] || sleep 3
done
mark "$WF run started: https://github.com/$REPO/actions/runs/$run"

# The tag: demo 1's comes from the build; demos 2 and 3 from release-please.
tag_of_sha() {
  git ls-remote --tags "git@github.com:$REPO.git" \
    | awk -v s="$sha" '$1 == s && $2 !~ /\^\{\}$/ {sub("refs/tags/", "", $2); print $2; exit}'
}
tag=''
while [[ -z "$tag" ]]; do
  st=$(gh run view "$run" -R "$REPO" --json status,conclusion -q '.status + "/" + .conclusion')
  tag=$(tag_of_sha)
  if [[ -z "$tag" && "$st" == completed/* ]]; then
    mark "run finished ($st) without a tag on ${sha:0:7}"
    break
  fi
  [[ -n "$tag" ]] || sleep 5
done
[[ -n "$tag" ]] && mark "tag $tag"

if [[ "$demo" != 1 && -n "$tag" ]]; then
  until gh release view "$tag" -R "$REPO" >/dev/null 2>&1; do sleep 5; done
  mark "GitHub Release $tag"
  gh release view "$tag" -R "$REPO" --json tagName,name,body,url,publishedAt > "$out-release.json"
fi
if [[ "$demo" == 3 && -n "$tag" ]]; then
  IFS=. read -r ma mi pa <<<"${tag#v}"
  if [[ "$pa" == 0 ]]; then
    until git ls-remote --exit-code --heads "git@github.com:$REPO.git" "release/$ma.$mi.x" >/dev/null; do sleep 5; done
    mark "branch release/$ma.$mi.x"
  fi
fi

gh run watch "$run" -R "$REPO" --interval 10 >/dev/null 2>&1 || true
mark "$WF run finished: $(gh run view "$run" -R "$REPO" --json conclusion -q .conclusion)"

gh run view "$run" -R "$REPO" --json jobs \
  -q '.jobs[] | [.name, .conclusion, .startedAt, .completedAt] | @tsv' > "$out-run-jobs.txt"
gh run view "$run" -R "$REPO" --log 2>/dev/null \
  | grep -E '##\[notice\]|##\[warning\]|##\[error\]' | sed -E 's/^[^\t]*\t[^\t]*\t[0-9TZ:.-]+ //' > "$out-run-notices.txt" || true
gh run view "$run" -R "$REPO" --log 2>/dev/null | grep -oE "$IMAGE:[A-Za-z0-9._-]+" | sort -u > "$out-image-tags.txt" || true
prefix=${tag%%v[0-9]*}
git ls-remote --tags "git@github.com:$REPO.git" | awk '{print $2}' | sed 's#refs/tags/##' | grep -v '\^{}$' \
  | grep "^${prefix}v[0-9]" | sort -V | tail -5 > "$out-tags.txt" || true

if [[ "$demo" == 3 ]]; then
  gh pr list -R "$REPO" --state open --json number,title,url,headRefName,baseRefName,createdAt,body \
    -q '[.[] | select(.headRefName | startswith("forward-port/") or startswith("release-please--"))]' > "$out-open-prs.json"
fi

{ echo; echo "captures: $out-*"; } >> "$timings"
cat "$timings"
