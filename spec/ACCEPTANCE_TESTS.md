# Acceptance tests before “live”

1. **Confirm ownership has transferred to the timelock.**<br>
  Calling owner() on the full list, selective list, and staking proxy must return the TimelockController address.

2. **Confirm unauthorised wallets cannot make protected changes.**<br>
  Calls to setBlocked, setAllowedTo, and upgradeToAndCall from an unauthorised regular wallet account (EOA) must revert—fail without applying changes.

3. **Confirm the previous owner no longer has control.**<br>
  After the handover, protected calls from the old owner’s wallet must also revert.

4. **Confirm the waiting period is enforced.**<br>
  The Governor must successfully queue a harmless test change through the timelock. Executing it before the required delay ends must fail; executing it after the delay must succeed.       

5. **Confirm the combined voting score cannot bypass either chamber’s minimum support.**<br>
  A proposal must fail if either the miner or staker chamber falls below its required support floor, even when the combined weighted score meets its threshold.

6. **Confirm chamber support cannot bypass the combined voting requirement.**<br>
  A proposal must fail if its combined weighted score does not meet the required threshold, even when both chambers meet their support floors.

7. **Confirm critical actions cannot use ordinary voting rules.**<br>
  An action requiring critical approval must be rejected if submitted as an ordinary proposal.

8. **Confirm invalidated snapshots cannot provide voting power.**<br>
  Attempts to vote using a snapshot root that has been invalidated must fail. A snapshot root represents the records used to establish voting power.

9. **Confirm DAO approval alone cannot authorise a consensus-rule change.**<br>
  No contract function may treat a successful DAO vote as sufficient to change the blockchain’s fundamental rules. The separate miner-signalling requirements and node operators’ right to refuse must still apply.

