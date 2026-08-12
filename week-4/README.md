# Week 4 starter: Evidence You Can Trust

Chain of custody means anyone can prove your evidence is authentic and untouched, without trusting you. You build two things: a signing step that runs in your pipeline, and a verify script that checks the result.

## The signing step (you add it to week 3's workflow)

After your gate produces `evidence/`, add a step that:

1. Bundles `evidence/` into a single `.tar.gz`.
2. Writes the bundle's SHA-256 to a `.sha256` sidecar file.
3. Signs the bundle with Cosign, keyless: `cosign sign-blob --yes --bundle evidence.sig.bundle <bundle>`.

Keyless signing means no private key. In GitHub Actions, Cosign uses the workflow's OIDC token, so the signature is tied to your pipeline run. The job needs `permissions: id-token: write` or the signing fails. The `--bundle` file packs the signature, the certificate, and the transparency-log entry into one file your verifier reads.

You can also sign locally to learn the flow: `cosign sign-blob` will open a browser for a one-time identity check. Still free, still keyless.

## The verify script (fill in verify-evidence.sh)

Three checks, each exits non-zero on failure:

1. **Integrity.** Recompute the SHA-256, compare to the sidecar.
2. **Authenticity.** `cosign verify-blob` against the `.sig.bundle`, pinning the OIDC issuer.
3. **Preservation** (stretch). If you used a vault, confirm the Object Lock retention is still in the future.

Print `CHAIN INTACT` only if all checks pass.

## The tamper test (this is the deliverable)

```bash
cp evidence.tar.gz /tmp/tampered.tar.gz
echo "junk" >> /tmp/tampered.tar.gz
./verify-evidence.sh /tmp/tampered.tar.gz   # must FAIL on integrity
./verify-evidence.sh evidence.tar.gz        # must say CHAIN INTACT
```

One changed byte breaks the chain. That failure is the whole point: custody is mathematical, not a promise.

## Cost

Free. Sigstore signing and verification cost nothing and need no cloud account. The only paid piece is the optional vault, which is pennies and gets torn down.

## Stretch: the immutable vault

For true preservation, upload the signed bundle to an S3 bucket with Object Lock and versioning on, so nobody can overwrite or delete it. Apply it, push one bundle, verify retention, then tear it down the same day. The brief covers the setup and teardown.
