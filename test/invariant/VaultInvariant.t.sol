 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {VaultV1} from "../../src/secure/VaultV1.sol";

contract VaultHandler is Test {
    VaultV1 internal vault;

    address[] internal actors;
    mapping(address => uint256) public expectedBalances;
    uint256 public expectedTotalDeposits;

    constructor(VaultV1 vault_) {
        vault = vault_;

        actors.push(makeAddr("alice"));
        actors.push(makeAddr("bob"));
        actors.push(makeAddr("charlie"));

        for (uint256 i = 0; i < actors.length; i++) {
            vm.deal(actors[i], 100 ether);
        }
    }

    function deposit(uint256 actorSeed, uint256 amount) external {
        address actor = actors[actorSeed % actors.length];
        amount = bound(amount, 1 wei, 10 ether);

        vm.prank(actor);
        vault.deposit{value: amount}();

        expectedBalances[actor] += amount;
        expectedTotalDeposits += amount;
    }

    function withdraw(uint256 actorSeed, uint256 amount) external {
        address actor = actors[actorSeed % actors.length];
        uint256 balance = expectedBalances[actor];

        if (balance == 0) return;

        amount = bound(amount, 1 wei, balance);

        vm.prank(actor);
        vault.withdraw(amount);

        expectedBalances[actor] -= amount;
        expectedTotalDeposits -= amount;
    }

    function actorCount() external view returns (uint256) {
        return actors.length;
    }

    function actorAt(uint256 index) external view returns (address) {
        return actors[index];
    }
}

contract VaultInvariantTest is StdInvariant, Test {
    VaultV1 internal vault;
    VaultHandler internal handler;

    address internal owner = makeAddr("owner");

    function setUp() public {
        VaultV1 implementation = new VaultV1();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(VaultV1.initialize, (owner))
        );

        vault = VaultV1(payable(address(proxy)));
        handler = new VaultHandler(vault);

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = VaultHandler.deposit.selector;
        selectors[1] = VaultHandler.withdraw.selector;

        targetSelector(
            FuzzSelector({
                addr: address(handler),
                selectors: selectors
            })
        );

        targetContract(address(handler));
    }

    function invariant_TotalDepositsMatchAccounting() public view {
        assertEq(vault.totalDeposits(), handler.expectedTotalDeposits());
        assertEq(address(vault).balance, vault.totalDeposits());
    }

    function invariant_IndividualBalancesRemainConsistent() public view {
        uint256 sum;

        for (uint256 i = 0; i < handler.actorCount(); i++) {
            address actor = handler.actorAt(i);
            uint256 expected = handler.expectedBalances(actor);

            assertEq(vault.balanceOf(actor), expected);
            sum += expected;
        }

        assertEq(sum, vault.totalDeposits());
    }

    function invariant_OwnerRemainsUnchanged() public view {
        assertEq(vault.owner(), owner);
    }
}
