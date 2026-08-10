# Week 3 starter: Build the Gate

A skeleton GitHub Actions workflow. You write the steps. The goal is a gate that runs your week 2 policies on every pull request and blocks the ones that break a control.

## Repo layout this assumes

Your challenge repo should have, by now:

```
terraform/        # your week 1 build
policies/         # your week 2 policies
plan.json         # terraform show -json of your compliant plan, committed
.github/workflows/grc-gate.yml   # this file, completed
```

Generate `plan.json` from your week 1 dir and commit it:

```bash
terraform plan -out=tfplan && terraform show -json tfplan > ../plan.json
```

## What to build

Complete the TODOs in `grc-gate.yml`:

1. Install Conftest at a pinned version.
2. Run your three policy namespaces against `plan.json`, write results to `evidence/conftest-results.json`, and fail the job on any policy failure.
3. Upload `evidence/` as an artifact with `if: always()` so it is saved on failure too.

## The two-PR demonstration (this is the deliverable)

1. **Green PR.** Open a pull request with your compliant `plan.json`. The gate runs, passes, the PR is mergeable.
2. **Red PR.** Open a pull request where the plan breaks a control (regenerate `plan.json` from a workspace with encryption removed, or hand-edit one flag to false). The gate runs, fails, and with branch protection on, the merge is blocked.

Turn on branch protection (Settings, Branches) and require the `grc-gate` check, so the red PR genuinely cannot merge. Screenshot both checks.

## Done when

- A PR triggers the workflow and it appears in the Actions tab.
- The compliant PR ends green. The violating PR ends red and is blocked.
- An evidence artifact is attached to both runs.

## Stretch: generate the plan in CI with OIDC

Committing `plan.json` is the simple, free, no-secrets path. The production version has CI generate the plan itself by assuming an AWS role through GitHub OIDC, so there are no stored keys. The brief explains the trust setup if you want to build it.
