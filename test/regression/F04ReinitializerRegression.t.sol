// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {VaultV1} from "../../src/secure/VaultV1.sol";
import {VaultV2} from "../../src/secure/VaultV2.sol";

contract F04ReinitializerRegressionTest is Test {
    VaultV2 internal vault;

    address internal owner = makeAddr("owner");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        VaultV1 implementation = new VaultV1();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(VaultV1.initialize, (owner))
        );

        VaultV2 implementationV2 = new VaultV2();

        vm.prank(owner);
        VaultV1(payable(address(proxy))).upgradeToAndCall(
            address(implementationV2),
            ""
        );

        vault = VaultV2(payable(address(proxy)));
    }

    function testUnauthorizedReinitializerReverts() public {
        vm.prank(attacker);
        vm.expectRevert(VaultV1.Unauthorized.selector);
        vault.initializeV2(999);

        assertEq(vault.newAccountingValue(), 0);

        vm.prank(owner);
        vault.initializeV2(42);

        assertEq(vault.newAccountingValue(), 42);

        vm.prank(owner);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        vault.initializeV2(100);

        assertEq(vault.newAccountingValue(), 42);
        assertEq(vault.owner(), owner);
    }
}
