# Lab 2.5: IaC as Compliance Evidence

An S3 bucket that refuses deletion of what's stored in it, and a script that captures a Terraform workspace's evidence, hashes it, and uploads it there. Built from the GRC Engineering Club CGE-P Lab 2.5 guide.

## What's here

| Path | What it is |
|---|---|
| `evidence-vault/` | Terraform for the vault: Object Lock enabled at creation, versioning, default retention, AES-256 encryption, public access blocked, and a bucket policy denying `s3:DeleteBucket` to everyone except the account root |
| `capture-evidence.sh` | Collects `plan.json`, `state.json`, `commit.txt` and `version.txt` from a workspace, writes a SHA-256 manifest, packs a `.tar.gz`, uploads it to the vault and prints a 1-line JSON receipt |
| `evidence/receipt.json` | Receipt for run `test-001`, a capture of the Week 1 workspace |

## How the vault protects evidence

Object Lock has to be set when the bucket is created. AWS can't add it to an existing bucket.

Every upload gets its own version ID, and the bucket's default retention rule locks that version as it arrives. The capture script never sets retention. The bucket applies it.

The vault runs in GOVERNANCE mode with 1-day retention so the lab can be torn down. In GOVERNANCE mode, a caller with `s3:BypassGovernanceRetention` can delete a locked version by passing `--bypass-governance-retention`. In COMPLIANCE mode nobody can, including the account root, until retention expires. The script and workflow are the same in both modes. Only the `lock_mode` variable changes.

## Results

Run `test-001` captured the Week 1 workspace at 2026-10-06T04:48:32Z. The bundle is stored at `runs/test-001/bundle.tar.gz`, version `S0xAf7zVOsEE.72F1gsIL1d4Fh7XGWVI`.

The Week 1 workspace had no state on disk before this lab. It was re-applied so the bundle includes post-deployment state, which Lab 2.3 calls for and the challenge didn't capture.

Deleting that specific version failed:

```
An error occurred (AccessDenied) when calling the DeleteObject operation: Access Denied because object protected by object lock.
```

The request came from the same account that created the vault. Retention was applied by the bucket's default rule at upload, not by the uploader.

The test deletes a specific version on purpose. In a versioned bucket, a delete without a version ID appears to succeed, but it only places a delete marker on top of the object. The locked version is still there.

## Run it

From Git Bash at the repository root:

```bash
cd lab-2-5/evidence-vault && terraform init && terraform apply
VAULT=$(terraform output -raw vault_name)
cd ../..
bash lab-2-5/capture-evidence.sh --workspace week-1 --run-id <id> --vault "$VAULT"
```

Save `capture-evidence.sh` with LF line endings. Windows line endings break it.

## Known gaps

- The bundle is uploaded unsigned. Keyless signing runs in CI in Week 4. Signing and uploading to the vault in the same pipeline run is capstone work.
- The vault sits in the same AWS account as the workloads it holds evidence for. A separate evidence account is the production pattern.
- Week 4's signed bundle is still committed to the repository rather than stored in the vault.
