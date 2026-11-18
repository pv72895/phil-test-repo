#!/usr/bin/env bash
# Usage: compute_targets.sh <merge-base-sha> <out-file>
# Mode comes from .lab/mode: "baseline" or "edges".
set -euo pipefail
base=$1
out=$2
mode=$(tr -d '[:space:]' <.lab/mode)
lab=$(mktemp -d)

pants --changed-since="$base" --changed-dependents=transitive list | sort -u >"$lab/baseline"
cp "$lab/baseline" "$out"
echo "mode=$mode"
echo "--- baseline targets"
cat "$lab/baseline"
[[ $mode == edges ]] || exit 0

# One "<target> <dependency>" line per edge from a changed file's target.
edges() {
  (($#)) || return 0
  pants --unmatched-cli-globs=ignore peek "$@" |
    jq -r '.[] | .address as $a | (.dependencies // [])[] | "\($a) \(.)"' | sort -u
}

mapfile -t at_head < <(git diff --name-only --diff-filter=d "$base" HEAD)
mapfile -t at_base < <(git diff --name-only --diff-filter=a "$base" HEAD)
mapfile -t deleted < <(git diff --name-only --diff-filter=D "$base" HEAD)

git worktree add -q --detach "$lab/base" "$base"
start=$SECONDS
edges "${at_head[@]}" >"$lab/head.edges"
(cd "$lab/base" && edges "${at_base[@]}") >"$lab/base.edges"
comm -23 "$lab/head.edges" "$lab/base.edges" >"$lab/new.edges"
cut -d' ' -f2 "$lab/new.edges" | sort -u >"$lab/new.targets"
if ((${#deleted[@]})); then
  (cd "$lab/base" && pants --unmatched-cli-globs=ignore list "${deleted[@]}") | sort -u >"$lab/removed.targets"
else
  : >"$lab/removed.targets"
fi
echo "edge computation took $((SECONDS - start))s"
git worktree remove --force "$lab/base"

echo "--- new edges"
cat "$lab/new.edges"
echo "--- removed targets"
cat "$lab/removed.targets"
sort -u "$lab/baseline" "$lab/new.targets" "$lab/removed.targets" >"$out"
