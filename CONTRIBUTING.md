# Contributing

Status: **proposed**. Not live until the timelock owns the three governed targets.

Collaborators (`ZombieDuckling`, `EddieForge`, `Welshdag`, `Remz70`, `psycho-v1`) have write access. That is a workshop seat, not Layer-2 authority and not Layer-1 authority.

## Seats

| Seat | Job | Must not do | Who holds it |
| --- | --- | --- | --- |
| Spec editor | `spec/CONSTITUTION.md`, parameters, glossary | Change floors, 70/30, or work-not-stock without an issue labelled `constitution` | @psycho-v1 until named otherwise |
| Solidity | Governor counting, classification, timelock path | Add sweep / seize / mint / silent upgrade | open — take issue #1 or #3 |
| Snapshot / off-chain | Epoch datasets, Merkle builder, challenge format | Invent a trusted indexer as the long-term source of truth | open — take issue #2 |
| Tests | Floor vs score, misclassification, invalidated root, post-handover owner revert | Greenwash a failing floor | @EddieForge (interim, until another contributor claims Tests here) |
| Evidence | Re-query checkpoints; pin hashes, not domains | Identity claims without a signed message | open |
| Comms | Short public wording only | Speak as if this repo controls miners or the freeze | @psycho-v1 |

Put your GitHub handle in a PR that claims a seat. Do not claim two seats if that creates a self-review on spec + implementation.

## Public wording (every post, every README sentence)

- proposed framework
- not live until `owner()` / storage slot 0 on the three targets is the timelock
- this repo does not administer the lists
- a DAO vote is Layer 2; miners and nodes still own Layer 1

If a PR markets this as live, revert the language.

## Close immediately

- drop a chamber floor
- restore raw-balance voting
- add sweep / seize / mint on a governed target
- identity claims without a signed message
- treat a DAO pass as sufficient for a consensus-rule change

## Before a PR

1. Open or take an issue (`constitution`, `implementation`, or `evidence`).
2. Say which layer you are touching.
3. `forge test` must stay green.
4. If you change a number in `src/libraries/ConstitutionParams.sol`, update `docs/PARAMETERS.md` in the same PR.

## What this group cannot skip

Handover order in `docs/HANDOVER.md` is part of the constitution. Do not deploy a production Governor and ask anyone to transfer ownership into it this week. Do not run a “real” vote on frozen wallets. Do not install an unbounded emergency owner.
