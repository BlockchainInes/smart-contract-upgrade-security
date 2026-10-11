UUPS Upgrade Security Assessment
Solidity · Foundry · OpenZeppelin · Ethereum Sepolia
Security-focused assessment of upgradeable smart contracts using the Universal Upgradeable Proxy Standard (UUPS). The repository combines intentionally vulnerable implementations, reproducible exploit tests, hardened contracts, and regression coverage with an independently verifiable V1-to-V2 upgrade executed on Ethereum Sepolia.
Verified on-chain upgrade
View successful upgrade transaction on Etherscan
Evidence	Value
Network	Ethereum Sepolia
Proxy	0x7d1239581E79CD20832CdFE27F3a3Ef11353C6EF
V1 implementation	0xB1eD5ffccA3Fb502cA4BFEc4E5F5c6942C86e26a
V2 implementation	0xBcCAEd8484cb3D1BbCB21cb8dF4176406A31D1bF
Upgrade transaction	0xc221f2f6…25f232
Block	11887775
Execution status	Success
Gas used	164,940


The proxy was upgraded from VaultV1 to VaultV2 via upgradeToAndCall, with initializeV2(100) executed as part of the upgrade. Post-transaction checks confirmed that the ERC-1967 implementation slot pointed to the V2 implementation and that newAccountingValue() returned 100 through the proxy.
This provides evidence of an actual testnet upgrade and post-upgrade state verification, rather than deployment alone.
Security assessment scope
The assessment addresses four failure modes relevant to UUPS proxy deployments:
Finding	Security concern	Reproduction and mitigation evidence
F-01	Unauthorized UUPS upgrade	[Finding](docs/findings/F-01-unauthorized-uups-upgrade.md) · [Exploit](test/exploits/F01UnauthorizedUpgrade.t.sol) · [Regression](test/regression/F01UnauthorizedUpgradeRegression.t.sol)
F-02	Uninitialized implementation	[Finding](docs/findings/F-02-uninitialized-implementation.md) · [Exploit](test/exploits/F02UninitializedImplementation.t.sol) · [Regression](test/regression/F02InitializationRegression.t.sol)
F-03	Storage layout corruption	[Finding](docs/findings/F-03-storage-layout-corruption.md) · [Exploit](test/exploits/F03StorageCollision.t.sol) · [Regression](test/regression/F03StorageLayoutRegression.t.sol)
F-04	Unprotected reinitializer	[Finding](docs/findings/F-04-unprotected-reinitializer.md) · [Exploit](test/exploits/F04UnprotectedReinitializer.t.sol) · [Regression](test/regression/F04ReinitializerRegression.t.sol)


Each finding has a dedicated technical write-up and a test demonstrating the vulnerable behavior. Corresponding regression tests exercise the hardened implementation. The repository also includes an invariant test suite.
Implementation
- Hardened implementations: [`VaultV1.sol`](src/secure/VaultV1.sol) and [`VaultV2.sol`](src/secure/VaultV2.sol)
- Vulnerable reference implementations: [`src/vulnerable/`](src/vulnerable/)
- Deployment automation: [`DeployVault.s.sol`](script/DeployVault.s.sol)
- Security tests: [`test/exploits/`](test/exploits/), [`test/regression/`](test/regression/), and [`test/invariant/`](test/invariant/)
- Technical findings: [`docs/findings/`](docs/findings/)
The secure upgrade path uses OpenZeppelin's UUPS and ERC-1967 proxy components. The implementation and test suites are structured to make the trust boundaries, upgrade authorization, initialization behavior, and storage compatibility reviewable independently.
Validation
11 Foundry tests passed during the assessment, covering exploit reproductions, security regressions, and invariant testing.
Run the test suite:
forge test
Build the contracts:
forge build
The repository excludes vendored dependencies from version control. Install the dependencies required by [`foundry.toml`](foundry.toml) before building; the implementation uses OpenZeppelin Contracts 5.4.0 and Foundry's forge-std.
Assessment boundaries
This repository is a focused security engineering demonstration, not a claim of a comprehensive audit or production certification. The intentionally vulnerable contracts exist solely to reproduce and analyze specific upgradeability risks. The Sepolia transaction establishes testnet execution evidence; it does not establish mainnet readiness.
Author
Ines Krüger
Blockchain & Smart Contract Security
GitHub · LinkedIn
