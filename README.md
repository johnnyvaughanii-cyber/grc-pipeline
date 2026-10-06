# GRC Engineering Pipeline

A working compliance pipeline that takes AWS infrastructure from deployed to audit-defensible. Terraform builds the resources, Rego policies evaluate the plan, a GitHub Actions gate blocks non-compliant pull requests, Cosign signs the evidence, CloudTrail records account activity, and an OSCAL component definition maps the controls to NIST SP 800-53 Rev. 5 with evidence links an assessor can follow.

I built it in 6 stages between July 30 and August 17, 2026, as part of the GRC Engineering Club pipeline challenge. All 6 are complete.

[Read the case study](week-6/PORTFOLIO-CASE-STUDY.md). It presents the pipeline as one system and links to the proof behind every claim.

## Verify it yourself

Each control in the OSCAL component definition links to a Cosign-signed evidence bundle. You can confirm the chain without taking my word for it:

```bash
git clone https://github.com/johnnyvaughanii-cyber/grc-pipeline.git
cd grc-pipeline/week-4/bundle
bash ../verify-evidence.sh evidence-bundle.tar.gz
```

You'll need `cosign` and `sha256sum`. The script recomputes the bundle's SHA-256 hash, verifies the signature against this repository's workflow identity, and prints `CHAIN INTACT` only when both checks pass.

## Stages

| Week | Build | Status |
|---|---|---|
| [1](week-1/) | Terraform for S3 storage enforcing SC-28, AC-3, AU-3, and CM-6, with the plan captured as JSON evidence | Complete |
| [2](week-2/) | 3 Rego policies that read the Week 1 plan and return a verdict per control, with 6 unit tests | Complete |
| [3](week-3/) | A GitHub Actions gate that runs the policies on every pull request and blocks failures | Complete |
| [4](week-4/) | Keyless Cosign signing of pipeline evidence, with a verification script and a tamper test | Complete |
| [5](week-5/) | Multi-region CloudTrail with log file validation, applied and torn down the same day | Complete |
| [6](week-6/) | OSCAL component definition and profile with evidence links, plus the case study | Complete |

## Controls

| Control | Implementation | Week |
|---|---|---|
| SC-28 | Default server-side encryption, with a policy that checks the algorithm against an approved allowlist | 1, 2 |
| AC-3 | Public access blocked on all 4 vectors | 1, 2 |
| AU-3 | Server access logging to a segregated log bucket | 1 |
| CM-6 | Versioning, plus 4 mandatory tags applied through the provider `default_tags` block | 1, 2 |
| AU-2, AU-12 | Multi-region CloudTrail recording management events in every region | 5 |
| AU-10 | CloudTrail log file validation, producing signed hourly digest files | 5 |
| RA-5, SI-4 | Not implemented. Security Hub returns `SubscriptionRequiredException` on this account | 5 |

The Week 3 gate enforces SC-28, AC-3, and CM-6 on every pull request. [PR #1](https://github.com/johnnyvaughanii-cyber/grc-pipeline/pull/1) passed the gate and merged. [PR #2](https://github.com/johnnyvaughanii-cyber/grc-pipeline/pull/2) broke encryption and is permanently blocked. The Week 6 OSCAL component definition maps SC-28, AC-3, AU-3, and CM-6.

## Open items

- The Terraform plan is committed rather than generated in CI. Generating it in the workflow needs GitHub OIDC federation to an AWS role that trusts only this repository.
- Signed bundles are committed to this repository rather than stored in an S3 Object Lock vault, so the preservation property of chain of custody isn't met yet.
- RA-5 and SI-4 stay open until Security Hub can be enabled on the account.
- The OSCAL mapping doesn't include the Week 5 CloudTrail controls yet.

## Stack

Terraform, Open Policy Agent (Rego), Conftest 0.69.0, GitHub Actions, Cosign with Sigstore keyless signing, AWS S3 and CloudTrail, and OSCAL 1.2.1 authored and validated with compliance-trestle.

## Related

- Portfolio: [portfolio.johnnyvaughanllc.com](https://portfolio.johnnyvaughanllc.com)
- Lab reference: [GRCEngClub/cgep-labs](https://github.com/GRCEngClub/cgep-labs). This pipeline follows the AWS track of the Certified GRC Engineer Practitioner labs.
