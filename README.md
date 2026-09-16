# Chain 1404 DAO Framework

Suggested dual-chamber, work-weighted constitution for BlockDAG mainnet (EVM chain ID `1404`).

**Status: proposed. Not live until ownership storage on the governed targets changes to the timelock.**

> Administrative parameters on this network should be owned by a timelocked Governor whose votes come from completed miner and staker rewards, while consensus rule changes still require an independent miner signalling gate and node-operator refusal rights. A token-balance vote would recreate the concentration the freeze was meant to constrain.

Suggested by [psycho_v1](https://github.com/psycho-v1) · 16 September 2026 · not legal advice · not an audit · not investment advice

## Design in one page

| Layer | What it is | Who may change it |
| --- | --- | --- |
| Layer 1 | Validity constitution (what nodes accept) | Critical DAO result **and** ≥75% miner signalling **and** node refusal rights |
| Layer 2 | Lists, selective routing, staking-proxy upgrades | Timelocked two-chamber Governor |
| Layer 3 | Which history wallets/exchanges treat as the network | Not this DAO. Pin hashes, not chain ID alone |

Voting weight is **flow, not stock**: finalised miner coinbase credits (70%) and finalised staking-reward credits (30%) from a completed weekly epoch. Raw wallet balances do not vote.

Every proposal must clear **both** a combined weighted score **and** a yes-floor in each chamber.

```
Custom Governor  →  TimelockController  →  list / selective-list / staking proxy
```

After handover, no externally owned account remains owner of those targets.

## Repository map

```
spec/           Normative constitution and acceptance tests
docs/           Handover sequence, parameters, evidence rules
src/            Solidity scaffolds (Governor, snapshots, interfaces)
test/           Foundry tests for floors, classification, handover
script/         Deploy and handover scripts
offchain/       Epoch snapshot / Merkle builder
addresses/      Published Chain 1404 checkpoints (August 2026 sources)
.github/        Issue templates, CI
```

Start here:

1. [`spec/CONSTITUTION.md`](spec/CONSTITUTION.md) — operative rules
2. [`spec/ACCEPTANCE_TESTS.md`](spec/ACCEPTANCE_TESTS.md) — what “live” means
3. [`docs/HANDOVER.md`](docs/HANDOVER.md) — order of operations
4. [`src/DualChamberGovernor.sol`](src/DualChamberGovernor.sol) — counting + queue path

## Thresholds (launch suggestion)

| Class | Quorum | Passage | Delay |
| --- | --- | --- | --- |
| Ordinary administration | 15% miner, 10% staker | Weighted score > 50% **and** ≥40% yes in each chamber | ≥ 72 hours |
| Critical administration | 20% miner, 15% staker | Majority in **both** chambers **and** weighted ≥ 60% | ≥ 7 days |
| Consensus change | Critical DAO + miner signalling | DAO passes, then ≥75% of a 2,000-block window | Protocol delay + ≥ 7-day notice |

Weighted score: `0.70 × miner_yes_share + 0.30 × staker_yes_share`.

A 100% miner yes and 0% staker yes cannot pass. That is the point of the floors.

## What this DAO may and may not do

May govern: full-list membership, selective routing, staking-proxy ownership and UUPS upgrades, Governor parameters, frozen-balance policy (burn / restitute / escrow / staged unlock), snapshot-root publication.

Must not: sign as another wallet, transfer another address’s balance, mint supply, or declare a failed miner signalling window to have passed. Immobilisation by miner-enforced rejection is an economic power. It is not cryptographic confiscation. Both sentences stay in the constitution.

## Build

```bash
git clone https://github.com/psycho-v1/chain1404-dao.git
cd chain1404-dao
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit
forge test
```

## Adoption test

Communities adopt constitutions by using them. Adoption of this text means, in order:

1. The text is published without a claim that it is already live.
2. The contracts are deployed and audited.
3. Ownership storage on the governed targets changes to the timelock, with published proofs.
4. The first ordinary and first critical production proposals execute after their delays.

Until those four steps complete, this repository is a suggested constitution. Intention is a speech act. Transfer is a storage slot.
