# Chain 1404 constitution (normative sketch)

Status: **proposed**. Not live until ownership storage changes.

## Layers

- Layer 1 — validity constitution.
- Layer 2 — administrative parameters (lists, selective routing, staking-proxy upgrades).
- Layer 3 — social canonicity. Chain identifier 1404 is not a uniqueness proof.

A DAO vote may authorise a Layer 2 write. It must never be described as control of independent miners. If either the DAO gate or the miner-and-node gate fails, a Layer 1 change does not activate.

## Principles

Work not stock. Two chambers, two floors. Dual gate for consensus. The timelock is the owner. Delay is a commitment device. Observe before you amend. Immobilisation is not a burn. Open enforcement. Anyone may refuse Layer 1. Nested centres.

Full operational tests live in this file’s repository copy and in docs/PARAMETERS.md.

## Weight

Score = 0.70 × M + 0.30 × S

Use only the most recently completed weekly epoch. Pools without published allocation carry only the operator residual. Raw wallet balances do not vote.

## Classes

Ordinary: quorum 15/10, score > 50%, floor 40% yes each chamber, delay ≥ 72 hours.
Critical: quorum 20/15, majority both chambers, score ≥ 60%, delay ≥ 7 days.
Consensus change: critical DAO result plus ≥ 75% signalling in a 2,000-block window plus protocol delay and ≥ 7-day notice.

## Execution

Governor (custom counting) → TimelockController → targets.

Neither list may expose a sweep/seize/mint function.
