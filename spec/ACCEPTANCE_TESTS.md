# Acceptance tests before “live”

- owner() on full list, selective list, and staking proxy returns the TimelockController.
- Random EOA setBlocked / setAllowedTo / upgradeToAndCall reverts.
- Old owner EOA after handover reverts.
- Governor queues a harmless test write and cannot execute it before delay.
- Weighted score without a chamber floor fails.
- Floors without the weighted score fail.
- Critical payload tagged ordinary is rejected.
- Invalidated snapshot root cannot vote.
- No contract function treats a DAO pass as sufficient for a consensus-rule change.
