// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {VaultV1} from "../../src/secure/VaultV1.sol";
import {MaliciousVault} from "../../src/vulnerable/MaliciousVault.sol";

contract F01UnauthorizedUpgradeRegressionTest is Test {
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

    function testUnauthorizedUpgradeReverts() public {
        MaliciousVault malicious = new MaliciousVault();

        vm.prank(attacker);
        vm.expectRevert(VaultV1.Unauthorized.selector);

        vault.upgradeToAndCall(
            address(malicious),
            abi.encodeCall(MaliciousVault.drain, (attacker))
        );

        assertEq(address(vault).balance, 10 ether);
        assertEq(vault.balanceOf(depositor), 10 ether);
        assertEq(attacker.balance, 0);
        assertEq(vault.owner(), owner);
    }
}
