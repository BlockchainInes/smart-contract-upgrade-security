
# F-04: Unprotected V2 Reinitializer

**Severity:** Medium
**Category:** Access Control / Initialization
**Status:** Remediated and Regression Tested

## Summary

The vulnerable V2 implementation exposes an initialization function without access control.

Although `reinitializer(2)` prevents repeated initialization, it does not restrict which account may execute the function first.

If the proxy is upgraded without atomically executing the V2 initializer, an unauthorized account can initialize the new version before the legitimate administrator.

## Root Cause

`VaultV2Vulnerable.initializeV2(uint256)` uses `reinitializer(2)` without an authorization modifier.

The initializer can therefore be executed by any external account while version 2 remains uninitialized.

## Impact

An unauthorized account can assign an attacker-controlled value to `newAccountingValue`.

Once initialization succeeds, the legitimate administrator cannot initialize version 2 again.

The demonstrated issue causes unauthorized configuration and initialization denial.

No direct theft of funds was demonstrated.

The severity assessment assumes that the initialized value is relevant to protocol configuration. The actual impact depends on how the application uses this value.

## Proof of Concept

**Test:** `test/exploits/F04UnprotectedReinitializer.t.sol`

1. Deploy the vulnerable V1 implementation behind an ERC1967 proxy.
2. Initialize the proxy with its legitimate owner.
3. Upgrade to the vulnerable V2 implementation without calling its initializer.
4. Execute `initializeV2(999)` from an attacker-controlled account.
5. Attempt to initialize V2 with the intended value of 42 from the legitimate owner.

### Observed Result

- The attacker successfully initializes V2 with value 999.
- The legitimate owner's subsequent initialization attempt reverts.
- The attacker-controlled configuration remains stored.
- The Foundry proof-of-concept test passes.

## Remediation

The secured `VaultV2` applies both `reinitializer(2)` and `onlyOwner` to `initializeV2`.

The authorization modifier prevents untrusted accounts from initializing V2.

The reinitializer modifier prevents repeated initialization.

Where possible, the upgrade and initialization should be executed atomically using `upgradeToAndCall`.

## Regression Verification

**Test:** `test/regression/F04ReinitializerRegression.t.sol`

The regression test verifies that:

- Unauthorized initialization reverts with `Unauthorized()`.
- The legitimate owner successfully initializes V2 with value 42.
- Repeated initialization reverts with `InvalidInitialization()`.
- The legitimate owner remains unchanged.

The regression test passes.

## Security Recommendations

Versioned initializers should enforce appropriate authorization.

Upgrade and initialization operations should preferably be atomic to avoid exposing an initialization window.

Security reviews should distinguish between initializer version enforcement and caller authorization.

## Scope

The vulnerability was intentionally introduced in a local Foundry environment.

No third-party contract or public network was targeted.
