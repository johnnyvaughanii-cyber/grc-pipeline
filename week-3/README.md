# Week 3: The Gate

A GitHub Actions workflow that runs the Week 2 policies against a Terraform plan on every pull request to `main`, and blocks the merge when a control fails.

## What the gate enforces

| Control | Namespace |
|---|---|
| SC-28 | `compliance.sc28_aws` |
| AC-3 | `compliance.ac3_aws` |
| CM-6 | `compliance.cm6_aws` |

The workflow is `.github/workflows/grc-gate.yml`. It checks out the repo, installs Conftest at a pinned version, runs the three namespaces against `week-3/evidence/plan.json`, and uploads the results as a build artifact.

Branch protection on `main` requires the `grc-gate` check. A pull request that fails a policy cannot be merged by anyone, including the repository owner.

## The two pull requests

| PR | Plan | Gate | Outcome |
|---|---|---|---|
| [#1](../../pull/1) | Compliant | Pass | Merged |
| [#2](../../pull/2) | `sse_algorithm` set to `none` | Fail | Blocked, left open as evidence |

PR #2 remains open deliberately. It is the artifact.

## Three implementation decisions

**Conftest is pinned to 0.69.0.** Most published install snippets query the GitHub API for the latest release and install whatever comes back. An unpinned tool means the same commit can produce different results on two runs, which breaks the reproducibility that evidence depends on. The pin is the compliance-relevant choice.

**The pipeline fails closed.** Conftest exits non-zero on a violation, but its output is piped to `tee` so the results are both written to the artifact and visible in the log. A shell pipeline reports the exit code of its last command, so without `set -o pipefail` the gate would record every violation and pass the build anyway. A gate that captures findings but does not act on them is not a gate.

**Evidence uploads on failure.** The upload step carries `if: always()`. By default a step is skipped when an earlier step fails, which would mean evidence is preserved on exactly the runs where it does not matter and discarded on the ones where it does.

## The gate passed a plan it should have failed

The first red pull request went green.

The plan had `sse_algorithm` set to `none` on both buckets. SC-28 raised nothing. The rule checked whether an encryption configuration resource existed and referenced each bucket. It never read the algorithm that resource specified. A bucket with an encryption resource declaring no encryption satisfied the control as written.

The control statement is protection of information at rest. The rule tested for the presence of a resource whose name suggests encryption. Those are not the same assertion, and the gap is invisible until something exercises it.

The fix adds a second rule that reads `sse_algorithm` out of `planned_values` and tests it against an allowlist of approved algorithms. An allowlist rather than a denylist: the failure was a value nobody anticipated, and a denylist only catches the values someone thought to write down. Merged in [#3](../../pull/3).

Worth noting where this surfaced. Six unit tests passed. Three policies ran clean against real infrastructure. The defect appeared only when a plan was deliberately broken in a way the policy author had not modeled. Negative testing is not a formality at the end of the build; it is the only step that tests the control instead of the code.

## The ruleset blocked its own author

The SC-28 fix was first pushed directly to `main`. The push was rejected: the required status check cannot pass on a direct push, because no check runs on one.

Correct behavior. The fix went through PR #3 like any other change. A control that yields to the person who configured it is a preference.

## An encoding defect in the evidence

The first gate run failed to parse the plan with `invalid character 'ÿ'`. PowerShell 5.1 writes UTF-16 with a byte order mark when redirecting output, so `plan.json` was not UTF-8. OPA on Windows tolerated it. Conftest on the Linux runner did not.

An evidence file that only parses on the machine that produced it is not portable evidence. The file is now written as UTF-8 without a BOM.

## Verify

Open a pull request against `main` with a modified `week-3/evidence/plan.json`. The gate runs automatically. Results appear in the check output and in the `grc-gate-evidence` artifact attached to the run, pass or fail.
