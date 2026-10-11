// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VaultV1} from "./VaultV1.sol";

contract VaultV2 is VaultV1 {
    uint256 public newAccountingValue;

    function initializeV2(uint256 initialValue)
        external
        reinitializer(2)
        onlyOwner
    {
        newAccountingValue = initialValue;
    }
}