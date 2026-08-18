# GRC Engineering Pipeline

I built a pipeline that takes cloud infrastructure from working to audit-defensible and proves every control claim with machine-verifiable evidence. An assessor can confirm my encryption claim by following a link, downloading a bundle, and running one command. No meeting, no screenshot request, no email thread.

Repository: https://github.com/johnnyvaughanII-cyber/grc-pipeline

## The six stages

**Compliant infrastructure as code.** Terraform provisions two S3 buckets enforcing five NIST SP 800-53 Rev. 5 controls: SC-28 server-side encryption, AC-3 public access blocked on all four vectors, CM-6 versioning and four mandatory tags applied through the provider `default_tags` block, and AU-3 with AU-6 access logging to a segregated log bucket. Proof is captured as `evidence/plan.json`, not screenshots.

**Policy as code.** Three Rego policies read the Terraform plan JSON and return a verdict on each control, with six unit tests covering both the passing and the failing case for each. The technique that makes this work is matching by reference rather than by value: at plan time the bucket name is unknown because the random suffix has not been generated, so the encryption resource has to be tied to its bucket through the reference recorded in `configuration`, not through a name comparison in `planned_values`.

**A gate that blocks.** A GitHub Actions workflow runs the policies against the plan on every pull request, with Conftest pinned to version 0.69.0 and `set -o pipefail` so a policy failure cannot be swallowed. Branch protection on main requires the check. Two pull requests demonstrate it: one compliant and merged, one that breaks encryption and is permanently blocked.

- Green pull request: https://github.com/johnnyvaughanII-cyber/grc-pipeline/pull/1
- Blocked pull request: https://github.com/johnnyvaughanII-cyber/grc-pipeline/pull/2

**Signed evidence.** The workflow bundles the evidence directory, writes a SHA-256 sidecar, and signs the archive with Cosign keyless signing. There is no long-lived private key. The certificate binds the signature to this repository and this workflow, and the event is recorded in Sigstore's public transparency log, which means the proof does not live in my AWS account and cannot be forged by anyone who holds admin there. Signing runs even when the gate fails, because a failed run is exactly the evidence most worth preserving.

**Native monitoring controls.** A multi-region CloudTrail writes to a private encrypted bucket with `enable_log_file_validation = true`, which produces signed hourly digest files and maps AU-2, AU-12, and AU-10. The bucket policy scopes the CloudTrail service principal with an `aws:SourceArn` condition bound to the specific trail. Everything was torn down the same day.

**A control mapping an assessor can traverse.** An OSCAL component definition and profile, both authored with trestle and both validating clean against OSCAL 1.2.1. The profile selects exactly four control IDs from the public NIST 800-53 Rev. 5 catalog. The component definition carries one implemented requirement per control, each naming the Terraform resource that does the work and each linking to the signed evidence bundle with `rel: evidence`.

## The traversal

This is the part that matters. I downloaded the signed bundle from the evidence link in the OSCAL document, as an outside reader would, into a directory that had never held it. Recomputing the hash matched the sidecar. `cosign verify-blob` confirmed the signature against the GitHub Actions OIDC issuer and the exact workflow identity. The verify script printed `CHAIN INTACT`.

A machine-readable control statement, an evidence link, a signed bundle, a passing verification. That chain is what engineered assurance means, and this is the smallest complete version of it.

## Defects I found in my own work

Both policies had real defects, and both were caught by testing rather than by review.

The CM-6 tag policy produced a false positive. It evaluated every resource in the plan for required tags, but non-taggable resources carry no `tags_all` attribute, so they failed a check that did not apply to them. Filtering the rule to resources that expose `tags_all` scoped it correctly.

The SC-28 encryption policy produced a false negative, which is the worse of the two. It confirmed that an encryption resource existed without inspecting the algorithm, so a plan declaring `sse_algorithm = "none"` passed the gate. A second deny rule now checks the declared algorithm against an approved allowlist. A control that verifies the presence of a setting without verifying its value is not a control.

## What is not finished

The pipeline commits a Terraform plan rather than generating one in CI. Generating it in the workflow would require GitHub OIDC federation with a role trusted only from this repository and scoped to read access. That is the next build.

## What I would do next

Move plan generation into CI with OIDC so no credentials are stored anywhere. Add an S3 Object Lock vault so the signed bundles cannot be overwritten or deleted, including by me, which closes the preservation property of chain of custody. Extend the OSCAL beyond four controls once there are more implementations genuinely worth claiming.

## The non-obvious thing

The value of the gate is the block, not the catch.

Nearly every control I have tested in eight years of audit work was detective. Sampling, reviewing, reporting on what already happened. A caught mistake is still a mistake that was made, and the remediation is a separate effort with its own owner, its own timeline, and its own chance of slipping. The finding is the beginning of work, not the end of it.

When the gate blocks a merge, the non-compliant configuration never enters the system. There is no finding to write, no owner to assign, no remediation to track, and no window during which production is out of compliance while the paperwork moves. The control does not report on the failure. It prevents the failure from occurring.

I understood that distinction as a definition long before I built one. Building it is what made the difference concrete.
