# GRC Engineering Pipeline

A working compliance pipeline built one layer at a time. Each week's build feeds the next: infrastructure as code, then policy that reads it, then a CI gate that enforces the policy, then signed evidence, then native cloud controls, then a control mapping an assessor can follow.

Built as part of the GRC Engineering Club six-week challenge.

## Weeks

| Week | Build | Status |
|---|---|---|
| [1](week-1/) | Terraform for an S3 bucket enforcing SC-28, AC-3, CM-6, and AU-3, with proof emitted as JSON | Complete |
| [2](week-2/) | Rego policies that read the week 1 plan and return a verdict per control | Complete |
| [3](week-3/) | GitHub Actions gate that runs the policies on every pull request and blocks failures | Complete |
| 4 | Keyless signing of pipeline evidence for chain of custody | — |
| 5 | Native cloud monitoring controls, findings captured as evidence | — |
| 6 | NIST 800-53 mapping in OSCAL with evidence links | — |

## Why this exists

A control described in a spreadsheet is a claim. A control expressed as code that runs on every change is enforcement. This repository is the difference, made concrete.

## Stack

Terraform, Open Policy Agent (Rego), GitHub Actions, AWS.