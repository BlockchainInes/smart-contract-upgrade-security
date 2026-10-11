// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract VaultV2Vulnerable is Initializable, UUPSUpgradeable {
    uint256 public newAccountingValue;

    mapping(address => uint256) private _balances;

    address public owner;
    uint256 public totalDeposits;

    function initializeV2(uint256 initialValue) external reinitializer(2) {
        newAccountingValue = initialValue;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function _authorizeUpgrade(address) internal override {}
}
