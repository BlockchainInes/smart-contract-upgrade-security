
# F-02: Uninitialized UUPS Implementation

**Severity:** Informational  
**Category:** Initialization Security  
**Status:** Remediated and Regression Tested

## Summary

The vulnerable vault implementation does not disable its initializer during construction.

Consequently, an external account can initialize the implementation contract directly and assign itself as the implementation's owner.

This does not automatically grant ownership of the proxy or access to assets held by the proxy.

## Root Cause

`VaultV1Vulnerable` inherits from `Initializable` but does not invoke `_disableInitializers()` in its constructor.

The implementation therefore retains an independently accessible initialization function.

## Impact

An attacker can initialize the implementation contract and acquire ownership within the implementation's own storage context.

The demonstrated attack does not modify the proxy's owner or establish control over the proxy.

No direct loss of funds or proxy takeover was demonstrated through this initialization issue.

The severity is classified as Informational for the tested implementation and threat model. Additional implementation-specific functionality could change the impact.

## Proof of Concept

**Test:** `test/exploits/F02UninitializedImplementation.t.sol`

1. Deploy the vulnerable implementation.
2. Deploy an ERC1967 proxy referencing that implementation.
3. Initialize the proxy with the legitimate owner.
4. Initialize the implementation directly from an attacker-controlled account.
5. Compare ownership values.

### Observed Result

- Direct implementation initialization succeeds.
- The attacker becomes owner of the implementation's storage context.
- The proxy retains its legitimate owner.
- The Foundry test passes.

## Remediation

The secured implementation, `VaultV1`, invokes `_disableInitializers()` in its constructor.

This prevents external accounts from initializing the implementation directly while preserving initialization through the proxy.

## Regression Verification

**Test:** `test/regression/F02InitializationRegression.t.sol`

The regression test confirms that:

- Direct initialization of the secured implementation reverts with `InvalidInitialization()`.
- The implementation owner remains the zero address.
- The proxy retains its legitimate owner.

## Security Considerations

Implementation storage and proxy storage are separate when calls execute directly against the implementation rather than through delegatecall.

Implementation ownership must not be confused with proxy ownership.

This finding concerns initialization hardening and does not establish an exploitable proxy takeover.

## Scope

This assessment concerns deliberately constructed local test contracts using OpenZeppelin UUPS components.

No public network or third-party contract was targeted.
