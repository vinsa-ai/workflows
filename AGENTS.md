<!-- Editing rules: see https://github.com/vinsa-ai/levatas-dashboard/blob/main/docs/AGENTS_MD_MAINTENANCE.md -->
# AGENTS.md

You are working on `vinsa-ai/workflows`, the shared GitHub Actions reusable-workflow library that every other vinsa-ai/* repo `uses:` from `.github/workflows/*.yml`. There is NO version discipline here — consumers reference `@main`, so a merge to `main` is a live release across the org. A typo breaks every consumer's next CI run.

## 1. Commands

```bash
# YAML + Actions lint (install: `go install github.com/rhysd/actionlint/cmd/actionlint@latest` or use the docker image; NOT preinstalled here).
actionlint .github/workflows/<file>.yml      # file-scoped — prefer
actionlint .github/workflows/*.yml           # full suite before commit
gh workflow lint .github/workflows/<file>.yml  # if gh CLI ≥2.40
# No build, no test runner, no package manifest. Pure YAML + one bash helper (`create-key.sh`).
```

## 2. Testing

- Framework: NONE. The repo has no test suite and no internal CI; the YAML it ships is never linted in this repo.
- "Tested" means: (a) `actionlint` exits 0 locally; (b) the change has been pushed to a feature branch in this repo AND `uses: vinsa-ai/workflows/.github/workflows/<file>.yml@<feature-branch>` has been temporarily wired into at least one consumer (typically `core-platform-sdk` or `gauge-model-container`) and observed to run end-to-end green BEFORE merging to `main`.
- Coverage gaps an agent MUST know about: zero coverage of every input/secret combination; you cannot grep for callers from this repo (caller manifest lives in `vinsa-ai/levatas-dashboard/docs/AGENTS_MD_INVENTORY.md`).

## 3. Code Style

Conventions NOT enforced by any tool here (there's no linter on `.github/workflows/*.yml` in this repo):

- **YAML:** 4-space indent (matches existing files); quote strings only when needed (booleans, leading `*`, etc.).
- **Pin third-party actions** to at least a major tag (`@v5`); SHA-pin (`@<full-sha>`) anything that touches secrets or pushes images. Floating `@master` / `@main` is never acceptable except for the one historical case in §5.
- **Reusable-workflow inputs** use `snake_case` (e.g. `use_lfs`, `python_version`, `install_script`) — match existing names exactly when adding inputs to a sibling workflow.
- **Secrets** consumed via `secrets.NAME` only; never injected through `env:` at the caller level.
- **Common input/secret contract** (keep names stable across files): inputs `use_lfs`, `has_ssh_key`, `install_script`, `python_version`, `dockerfile`, `docker_context`, `source_paths`, `skip_pytest`/`skip_pylint`; secrets `REPOSITORY_USER_TOKEN` (always required), `ACTIONS_SSH_KEY` (when `has_ssh_key: true`).

## 4. Git Workflow

- Branch: `agent-<short-description>` for AI work; PR title `docs: add AGENTS.md` for this PR.
- CI: this repo has NONE. The reviewer must mentally run `actionlint` and the consumer-side smoke test described in §2.
- Release: merging to `main` IS the release. There is no tag, no `@v1` ref, no staging environment. Every consumer picks up the change on their next CI run within seconds.
- Reviewers: anyone with vinsa-ai/* commit access — but for any change to inputs/secrets, ping the owners of every consumer in the §5 cross-repo table first.

## 5. Boundaries

### Always do
1. Announce a breaking change (input rename/removal, secret added, behavior change) at least one sprint ahead via an issue in EVERY consumer repo before opening the PR here.
2. Preserve input names AND defaults across PRs — every consumer relies on the defaults.
3. Pin any newly-added third-party action to `@v<major>` minimum, SHA-pin if it handles secrets/pushes images.

### Never do
1. Rename or delete a workflow file without leaving a thin redirector AND notifying every consumer (see §2 of the consumer's AGENTS.md to find owners).
2. Add a new required secret without first opening a coordinated PR in every consumer to wire it through.
3. Commit secrets, tokens, or `.ssh/` material to any tracked file.

### Ask first
1. Adding a new reusable workflow that overlaps an existing one (e.g. the `docker-build.yml` vs `workflow-publish-package.yml` redundancy below).
2. Bumping a third-party action's major version (`@v4` → `@v5`).
3. Touching `softprops/action-gh-release@master` (see gotchas).

**Conflict order:** Never-do > Always-do > Ask-first.

**Known gotchas (high-signal — NOT discoverable by reading the code):**
- **`softprops/action-gh-release@master` is a floating ref** in `create-release.yml` (the only `@master` here). Upstream can break the release flow at any time. Pin to a tagged SHA when touched.
- **No `@v1` discipline + no internal CI.** Consumers reference `…/workflows/<file>.yml@main`; this repo has no tags and nothing lints/tests the YAML it ships. Reviewer is the only gate; treat `main` as production.
- **Circular self-checkout:** `run-pylint.yml` + `run-ruff.yml` `actions/checkout@v4` `repository: vinsa-ai/workflows` into `.workflows-config/` for `.pylintrc` / `ruff.toml`. Renaming this repo or those configs breaks every consumer's lint job at runtime, NOT at CI time.
- **`docker-build.yml` (canonical, larger-runner-x64, modern action versions) and `workflow-publish-package.yml` (legacy, @v2/@v3 actions) overlap.** Both build+push to ghcr.io. New consumers must use `docker-build.yml`; the legacy file is kept only because old consumers still reference it. Don't extend it.
- **`run-ruff.yml` references `inputs.use_lfs` but never declares it** (line ~21). Currently a silent no-op; will hard-error if Actions tightens input validation.

**Cross-repo coordination:**

| Repo | Relationship | When you'd touch it |
| --- | --- | --- |
| `vinsa-ai/core-platform-sdk` | downstream consumer (run-pylint, run-ruff, run-unit-tests, create-release) | Coordinated input/secret changes; most-tested consumer |
| `vinsa-ai/gauge-model-container` | downstream consumer (run-pylint, docker-build, create-release) | Coordinated changes touching the `has_ssh_key` flow |
| `vinsa-ai/levatas-dashboard` | downstream consumer (create-release, docker-build) | Coordinated release-flow changes |
| `vinsa-ai/levatas-ai-kit` | downstream consumer (create-release, run-unit-tests) | Coordinated SDK-style release changes |
| `dnewmon/broadcast-socket-{server,client}` | EXTERNAL-org consumers | Cannot coordinate via vinsa-ai owners; flag breaking changes in PR description |

**Source-of-truth ordering:** the workflow contracts here are authoritative; consumer-side `.github/workflows/*.yml` files are thin wrappers and must NEVER re-implement what's already reusable here. If you find a consumer with custom build/lint/release logic, the bug is in the consumer.

**On-demand procedures (Skills layer):** for the multi-consumer breaking-change rollout procedure, see `vinsa-ai/.github/skills/coordinate-workflow-change/SKILL.md` (forthcoming, Phase 6).
