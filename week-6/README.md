# Week 6 starter: Speak the Auditor's Language

Two builds this week. An OSCAL control mapping, and the portfolio case study that presents the whole pipeline as one system. The starter is a README and a case-study template. The OSCAL is yours to author with trestle.

## Setup

```bash
pip install compliance-trestle
trestle init
```

trestle is NIST's OSCAL toolkit. It generates valid skeletons and validates your documents against the strict OSCAL schema.

## What you build

1. A **component definition** describing your work. Create the skeleton with `trestle create -t component-definition -o my-pipeline -x json`, then fill it in:
   - One `implemented-requirement` per control you actually satisfied: sc-28, ac-3, au-3, cm-6.
   - For each, a prop naming the Terraform resource that implements it, and a `links` entry with `rel: evidence` whose `href` points at your signed bundle from week 4.
   - `source` is the public NIST 800-53 Rev 5 catalog URL.
2. A **profile** that selects exactly those control IDs from the catalog. Create with `trestle create -t profile`, list your control IDs under `include-controls`.

Validate both:

```bash
trestle validate -f component-definitions/my-pipeline/component-definition.json
trestle validate -f profiles/<name>/profile.json
```

You want `VALID` on both.

## Two things that will bite you

- **UUIDs must be v4.** Do not hand-write them. `python3 -c "import uuid; print(uuid.uuid4())"` per UUID. trestle rejects the wrong format.
- **Versions must match.** The catalog, profile, and component must share an `oscal-version`. trestle pins one; check with `trestle version`.

## Prove the traversal

Pick one control in your component, follow its evidence `href` to your vault (or your signed bundle), and run your week 4 `verify-evidence.sh`. Seeing `CHAIN INTACT` means the whole chain is wired: control mapping, evidence link, signed bundle. That is the demonstration.

## The capstone: your portfolio case study

Fill in `PORTFOLIO-CASE-STUDY.md`. This is the page that makes a hiring manager stop. It presents all six weeks as one pipeline you built, with the controls it enforces and the evidence it produces. Put it at the top of your portfolio.

## Done when

- `trestle validate` returns VALID for the component and the profile.
- At least one evidence link resolves to a real signed bundle.
- Your case study is published on your portfolio and links to the repo.

## Cost

Free. OSCAL is JSON in your repo. Nothing to deploy, nothing to tear down.
