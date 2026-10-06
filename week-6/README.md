# Week 6: Speak the Auditor's Language

An OSCAL component definition and profile that map the pipeline to NIST SP 800-53 Rev. 5. Each mapped control links to the signed evidence bundle from Week 4, so an assessor can move from the control statement to verified evidence without asking me for anything. Both documents validate clean against OSCAL 1.2.1 with compliance-trestle.

The [portfolio case study](PORTFOLIO-CASE-STUDY.md) presents all 6 weeks as one system.

## What's here

| File | Contents |
|---|---|
| `oscal/profiles/grc-pipeline-profile/profile.json` | Selects sc-28, ac-3, au-3, and cm-6 from the public NIST SP 800-53 Rev. 5 catalog |
| `oscal/component-definitions/grc-pipeline/component-definition.json` | 1 component, Compliant S3 Storage Pipeline, with 1 implemented requirement per selected control |
| `PORTFOLIO-CASE-STUDY.md` | The 6-week build written up as one pipeline |

## Controls mapped

| Control | Terraform resource | Policy |
|---|---|---|
| sc-28 | `aws_s3_bucket_server_side_encryption_configuration` | `week-2/policies/sc28_encryption_aws.rego` |
| ac-3 | `aws_s3_bucket_public_access_block` | `week-2/policies/ac3_no_public_aws.rego` |
| au-3 | `aws_s3_bucket_logging` | None |
| cm-6 | `aws_s3_bucket_versioning` | `week-2/policies/cm6_required_tags_aws.rego` |

Each implemented requirement names its Terraform resource and policy file as props and carries a link with `rel: evidence` to `week-4/bundle/evidence-bundle.tar.gz`. The control implementation's `source` is the NIST SP 800-53 Rev. 5 JSON catalog published in usnistgov/oscal-content.

## Validate

```bash
pip install compliance-trestle
cd week-6/oscal
trestle validate -f component-definitions/grc-pipeline/component-definition.json
trestle validate -f profiles/grc-pipeline-profile/profile.json
```

Both return `VALID`.

## The traversal

I tested the mapping by following an evidence link the way an outside assessor would. I downloaded the bundle from the URL in the component definition into a directory that had never held it, recomputed the SHA-256 hash against the sidecar, and ran `verify-evidence.sh`. The hash matched, `cosign verify-blob` confirmed the signature against the GitHub Actions OIDC issuer and this repository's workflow identity, and the script printed `CHAIN INTACT`.

## Open items

- Evidence links point to the bundle committed in this repository, not an S3 Object Lock vault. The links resolve, but nothing prevents the bundle from being overwritten or deleted.
- The mapping covers 4 controls. Week 5's AU-2, AU-10, and AU-12 aren't in the component definition yet.

## Cost

None. OSCAL is JSON in the repository, so there was nothing to deploy or tear down.
