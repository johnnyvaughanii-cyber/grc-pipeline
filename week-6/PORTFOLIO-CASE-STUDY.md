# [Your name]: A GRC Engineering Pipeline, Built in Public

> Template. Replace every prompt in brackets with your own words and evidence.
> Keep it tight. A hiring manager should understand what you built in 60 seconds
> and be able to click through to the proof.

## What this is

[One paragraph. You built an end-to-end pipeline that takes a cloud resource from
"it works" to "it is audit-defensible" and proves every control along the way.
Say it in your own words.]

## The pipeline

[A short list or a diagram. Six stages, one per week:]

- Compliant infrastructure as code (SC-28, AC-3, CM-6, AU-3)
- Policy as code that proves the controls hold
- A CI gate that blocks non-compliant changes
- Signed, tamper-evident evidence with a verifiable chain of custody
- Native cloud monitoring controls (CloudTrail, Security Hub)
- An OSCAL control mapping an auditor can traverse

## Proof

[Link the repo. Link the two pull requests, green and red. Link or screenshot the
`opa test` run, the signed `CHAIN INTACT` verification, and the `trestle validate`
VALID output. Evidence over adjectives.]

- Repo: [link]
- Green PR / Red PR: [links]
- Policy tests passing: [link or screenshot]
- Evidence verification: [CHAIN INTACT screenshot]
- OSCAL validation: [VALID screenshot]

## What I would do next

[One honest paragraph. What you would harden, automate, or extend with more time.
This is where you show judgment, which is what the role is actually about.]

## What I learned

[Two or three sentences. The non-obvious thing that clicked. Match-by-reference at
plan time, why keyless signing beats stored keys, why a blocked merge beats a caught
mistake. Pick the one that was real for you.]
