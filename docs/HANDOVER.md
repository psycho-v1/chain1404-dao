# Handover sequence

Order is part of the constitution. Do not vote first and verify later.

Until ownership storage changes on chain, a roadmap is a speech act.

1. Publish reproducible node releases, tagged source, build instructions, binary hashes.
2. Publish Governor, custom counting, snapshot specification, tests, deployment artifacts.
3. Move each current system owner to a disclosed threshold account behind an already-installed timelock. Publish the signer set. An EOA plus a blog post is not a custody design.
4. Complete public audits. Publish findings and remediations.
5. Run one successful end-to-end test proposal that does not mutate production list or staking state.
6. Transfer ownership of the full list, the selective list, and the live staking proxy to the TimelockController. Publish hashes and old/new storage values.
7. Renounce the deployment key.
8. Only then activate the DAO for critical production decisions.

Published target addresses (August 2026 sources; re-query before use):

- full blocklist `0xe628505d5cB6F5F4f9a25Cd5c80Caa198cc645a0`
- selective list `0xc0a42A43A05e39C3a4165CA98440D516959f41D9`
- staking proxy `0x08Bd519F611556dC148e7BfFE8d6f078F23a8EF7`

An unbounded emergency owner is the current design problem under another name.
