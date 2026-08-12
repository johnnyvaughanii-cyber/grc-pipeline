# Week 4: Evidence You Can Trust

The pipeline signs the evidence it produces. Anyone can verify that a bundle came from this repository's workflow and has not been altered since, without trusting the person who hands it to them.

## Chain of custody, mapped to artifacts

| Property | Question it answers | Artifact that proves it |
|---|---|---|
| Authenticity | Who produced this? | `evidence-bundle.tar.gz.sig.bundle` — a Sigstore certificate binding the signature to this repository and this workflow file |
| Integrity | Has it changed since? | `evidence-bundle.tar.gz.sha256` — the archive's SHA-256, recomputed and compared at verification |
| Timeliness | When was it produced? | The Rekor transparency log entry recorded inside the signature bundle, with a signed timestamp |
| Preservation | Can it still be retrieved, unaltered? | The bundle is committed to this repository. The stretch goal, an S3 Object Lock vault, is not implemented |

## Keyless signing

The workflow signs with Cosign in keyless mode. There is no private key anywhere in this repository, in GitHub Secrets, or in any cloud account.

Instead the runner requests a short-lived OIDC token from GitHub asserting which workflow in which repository is executing. Sigstore validates that token, issues a certificate valid for a few minutes bound to that identity, signs the artifact, and records the event in a public transparency log. The certificate then expires.

The property that matters: the certificate encodes `grc-gate.yml` in this repository as the signer, and that fact lives in Sigstore's public log rather than in infrastructure the repository owner controls. An administrator with full access to this account cannot forge a signature attributing evidence to a pipeline run that did not happen.

## Signing survives a failed gate

The gate step no longer ends the job on a policy violation. It records the verdict to `$GITHUB_ENV`, the bundling and signing steps run, and a final step reads the verdict and exits non-zero.

The reordering is the point. A run that blocked a merge is the run whose evidence matters most, and the original ordering discarded it. Preserving evidence only for passing runs collects the cases nobody needs to prove.

## Verification

`verify-evidence.sh` performs two checks and prints `CHAIN INTACT` only if both pass.

```
cd bundle
bash ../verify-evidence.sh evidence-bundle.tar.gz
```

Integrity is `sha256sum -c` against the sidecar. Authenticity is `cosign verify-blob` with both the OIDC issuer and the certificate identity pinned.

Pinning the identity is not optional. Without `--certificate-identity-regexp`, Cosign accepts any valid Sigstore signature, which establishes that the file was signed by someone but says nothing about who. A verification that any signer passes is not an authenticity check.

## The tamper test

A copy of the bundle with one byte appended fails immediately:

```
tampered.tar.gz: FAILED
sha256sum: WARNING: 1 computed checksum did NOT match
```

The unmodified bundle returns `Verified OK` and `CHAIN INTACT`.

Verification never reached the authenticity check on the tampered file. The script runs under `set -euo pipefail`, so the integrity failure ended it. Both checks would have failed independently: the hash no longer matches, and the signature was computed over the original bytes.

One byte out of 262 is the same failure as rewriting the file. SHA-256 gives no partial credit, which is what makes it usable as evidence.

## Note on identity pinning

The first verification attempt failed against a correctly signed bundle. The regex matched the repository prefix, but Cosign requires the pattern to match the certificate subject in full, and the subject includes the workflow path and the git ref:

```
https://github.com/johnnyvaughanii-cyber/grc-pipeline/.github/workflows/grc-gate.yml@refs/pull/5/merge
```

The corrected pattern pins the repository and the specific workflow file, and allows any ref. Pinning the ref as well would mean the check only passes for one pull request.

Worth noting which direction that failure ran. A too-narrow identity pattern rejects valid evidence, which is visible and gets fixed. A missing one accepts anything, which looks identical to working correctly.
