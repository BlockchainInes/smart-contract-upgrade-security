// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {VaultV1} from "../../src/secure/VaultV1.sol";
import {VaultV2} from "../../src/secure/VaultV2.sol";

contract F03StorageLayoutRegressionTest is Test {
    VaultV1 internal vault;

    address internal owner = makeAddr("owner");
    address internal depositor = makeAddr("depositor");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        VaultV1 implementation = new VaultV1();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(VaultV1.initialize, (owner))
        );

        vault = VaultV1(payable(address(proxy)));

        vm.deal(depositor, 10 ether);

        vm.prank(depositor);
        vault.deposit{value: 10 ether}();
    }

    function testUpgradePreservesBalances() public {
        assertEq(vault.balanceOf(depositor), 10 ether);
        assertEq(vault.totalDeposits(), 10 ether);

        VaultV2 implementationV2 = new VaultV2();

        vm.prank(owner);
        vault.upgradeToAndCall(
            address(implementationV2),
            abi.encodeCall(VaultV2.initializeV2, (42))
        );

        VaultV2 upgradedVault = VaultV2(payable(address(vault)));

        assertEq(upgradedVault.balanceOf(depositor), 10 ether);
        assertEq(upgradedVault.totalDeposits(), 10 ether);
        assertEq(address(upgradedVault).balance, 10 ether);
        assertEq(upgradedVault.owner(), owner);
        assertEq(upgradedVault.newAccountingValue(), 42);
    }
}
