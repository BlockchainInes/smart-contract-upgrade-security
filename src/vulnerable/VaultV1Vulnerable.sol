// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract VaultV1Vulnerable is Initializable, UUPSUpgradeable {
    mapping(address => uint256) private _balances;

    address public owner;
    uint256 public totalDeposits;

    function initialize(address initialOwner) external initializer {
        require(initialOwner != address(0), "Invalid owner");
        owner = initialOwner;
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");

        _balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Zero amount");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function _authorizeUpgrade(address) internal override {}
}
