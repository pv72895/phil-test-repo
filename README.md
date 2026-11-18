# pants-lab

Scratch Pants repo for testing impacted-target overlap in a parallel merge queue.
`.lab/mode` selects how `.lab/compute_targets.sh` computes targets: `baseline`
(changed targets plus transitive dependents) or `edges` (baseline plus new
dependency edges and removed targets, compared against the merge base).

