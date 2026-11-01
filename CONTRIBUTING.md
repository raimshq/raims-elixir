# Contributing

Read [AGENTS.md](AGENTS.md) and [maintenance](docs/maintenance.md) before
changing this SDK. Keep documentation and repository descriptions in English.

Use the pinned public contract. Generate resource modules, models, named
values, metadata, and the reference with `python scripts/generate.py`.
Do not edit generated outputs or import private API code. Preserve JSON
names, integer cents, Unix seconds, omission, explicit null, unknown response
fields, and pending outcomes.

Run `python scripts/generate.py --check` and `python scripts/check.py`.
The canonical gate requires the engineering workspace and Developer Toolkit.
It runs isolated consumers without calling the financial API. Tests,
simulators, dependencies, builds, and reports belong in the workspace's
temporary directory and must not enter this repository or its package.

Review all changed and new files, `git diff --check`, `git diff`, and
`git diff --cached`. Leave changes uncommitted and unstaged until a commit
is requested. Keep secrets, customer data, internal plans, TODO lists,
backlogs, and roadmaps outside the public source and distribution.

Remote creation, push, tags, releases, executable workflows, public guides,
and Hex publication require separate authorization. Successful local checks
do not publish the SDK. Report vulnerabilities privately as described in
[SECURITY.md](SECURITY.md).
