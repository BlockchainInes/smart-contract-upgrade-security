// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {VaultV1} from "../../src/secure/VaultV1.sol";

contract F02InitializationRegressionTest is Test {
    VaultV1 internal implementation;
    VaultV1 internal vault;

    address internal owner = makeAddr("owner");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        implementation = new VaultV1();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(VaultV1.initialize, (owner))
        );

        vault = VaultV1(payable(address(proxy)));
    }

    function testImplementationInitializationReverts() public {
        vm.prank(attacker);
        vm.expectRevert(Initializable.InvalidInitialization.selector);

        implementation.initialize(attacker);

        assertEq(implementation.owner(), address(0));
        assertEq(vault.owner(), owner);
    }
}
