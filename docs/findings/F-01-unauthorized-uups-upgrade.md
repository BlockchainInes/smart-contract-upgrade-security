
# F-01: Unauthorized UUPS Upgrade

**Severity:** Critical  
**Category:** Access Control  
**Status:** Remediated and Regression Tested

## Summary

The vulnerable vault implementation does not enforce authorization in `_authorizeUpgrade(address)`. Consequently, any external account can upgrade the ERC1967 proxy to an attacker-controlled, UUPS-compatible implementation.

## Root Cause

`VaultV1Vulnerable` overrides `_authorizeUpgrade(address)` without restricting the caller.

The UUPS compatibility check validates the upgrade mechanism but does not replace application-level authorization.

## Impact

An unauthorized account can replace the vault implementation and execute arbitrary logic through the proxy.

In the demonstrated exploit, the attacker upgrades the proxy to `MaliciousVault` and transfers the entire 10 ETH vault balance to an attacker-controlled address.

The vulnerability affects the deliberately insecure example implementation, not the OpenZeppelin library.

## Proof of Concept

**Test:** `test/exploits/F01UnauthorizedUpgrade.t.sol`

1. Deploy `VaultV1Vulnerable` behind an ERC1967 proxy.
2. Initialize the vault with a legitimate owner.
3. Deposit 10 ETH from a separate account.
4. Deploy the UUPS-compatible `MaliciousVault`.
5. Execute `upgradeToAndCall` from an unauthorized account.
6. Invoke `drain` through the proxy during the upgrade.

### Observed Result

- Unauthorized upgrade succeeds.
- Vault ETH balance decreases from 10 ETH to 0 ETH.
- Attacker receives 10 ETH.
- Foundry exploit test passes.

## Remediation

The secured implementation, `VaultV1`, restricts `_authorizeUpgrade(address)` using the `onlyOwner` modifier.

It also disables direct initialization of the implementation contract through `_disableInitializers()`.

## Regression Verification

**Test:** `test/regression/F01UnauthorizedUpgradeRegression.t.sol`

The regression test confirms that:

- Unauthorized upgrade attempts revert with `Unauthorized()`.
- The vault retains its 10 ETH balance.
- The depositor's recorded balance remains unchanged.
- The attacker receives no ETH.
- The legitimate owner remains unchanged.

## Test Results

Command:

`forge test`

Result:

**2 tests passed, 0 failed, 0 skipped.**

## Scope

This finding concerns a deliberately vulnerable educational security-assessment implementation tested locally with Foundry. No public network or third-party contract was targeted.
