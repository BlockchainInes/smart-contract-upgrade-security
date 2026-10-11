
# F-03: Storage Layout Corruption During UUPS Upgrade

**Severity:** High
**Category:** Upgrade Safety / Storage Layout
**Status:** Remediated and Regression Tested

## Summary

An incompatible storage layout between two versions of an upgradeable vault causes existing accounting data to be interpreted incorrectly after an upgrade.

The vulnerable V2 implementation inserts a new state variable before the original storage variables, shifting their assigned storage slots.

## Root Cause

The V1 implementation stores:

| Variable | Slot |
|---|---|
| `_balances` | 0 |
| `owner` | 1 |
| `totalDeposits` | 2 |

The vulnerable V2 implementation introduces `newAccountingValue` before the existing variables:

| Variable | Slot |
|---|---|
| `newAccountingValue` | 0 |
| `_balances` | 1 |
| `owner` | 2 |
| `totalDeposits` | 3 |

Because the proxy retains its storage during an implementation upgrade, these layout changes break compatibility with the previously deployed state.

## Impact

Following an upgrade to the incompatible implementation, existing user balances are no longer read from their original mapping location.

In the demonstrated scenario:

- The depositor's balance before the upgrade is 10 ETH.
- The depositor's reported balance after the upgrade is 0 ETH.
- The proxy still holds 10 ETH.
- The V2 accounting state no longer reflects the original deposits.

This creates a serious accounting integrity failure and may prevent users from accessing their deposited funds.

The test demonstrates state misinterpretation, not an actual transfer of funds to an attacker.

## Proof of Concept

**Test:** `test/exploits/F03StorageCollision.t.sol`

1. Deploy the vulnerable V1 implementation behind an ERC1967 proxy.
2. Initialize the proxy with a legitimate owner.
3. Deposit 10 ETH from a separate account.
4. Deploy the incompatible V2 implementation.
5. Upgrade the proxy to V2.
6. Compare the recorded user balance and proxy ETH balance.

### Observed Result

The depositor's recorded balance changes from 10 ETH to 0 ETH while the proxy retains its 10 ETH.

The Foundry proof-of-concept test passes.

## Remediation

The secured `VaultV2` inherits from the secured `VaultV1` and appends the new state variable after the existing storage layout.

This preserves the original storage slots.

The upgrade remains restricted to the authorized owner.

## Regression Verification

**Test:** `test/regression/F03StorageLayoutRegression.t.sol`

The regression test verifies that:

- The depositor retains a recorded balance of 10 ETH.
- Total deposits remain 10 ETH.
- The proxy retains 10 ETH.
- The legitimate owner remains unchanged.
- The new V2 accounting variable is initialized to 42.

The regression test passes.

## Security Recommendations

Upgradeable contracts should preserve existing storage layouts across implementation versions.

New state variables should be appended without reordering or changing existing storage definitions.

Storage layouts should be compared before deployment, and upgrade regression tests should verify critical state preservation.

## Scope

The vulnerability was intentionally introduced in a local Foundry test environment.

No third-party contract or public network was targeted.
