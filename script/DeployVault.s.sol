// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {VaultV1} from "../src/secure/VaultV1.sol";
import {VaultV2} from "../src/secure/VaultV2.sol";

contract DeployVault is Script {
    function run() external {
        address owner = vm.envAddress("VAULT_OWNER");
        require(owner != address(0), "Invalid owner");

        vm.startBroadcast();

        VaultV1 implementationV1 = new VaultV1();
        VaultV2 implementationV2 = new VaultV2();

        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementationV1),
            abi.encodeCall(VaultV1.initialize, (owner))
        );

        vm.stopBroadcast();

        console2.log("VaultV1 implementation:", address(implementationV1));
        console2.log("VaultV2 implementation:", address(implementationV2));
        console2.log("ERC1967 proxy:", address(proxy));
        console2.log("Vault owner:", owner);
    }
}
