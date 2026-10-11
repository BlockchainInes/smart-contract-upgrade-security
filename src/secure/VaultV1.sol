// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract VaultV1 is Initializable, UUPSUpgradeable {
    mapping(address => uint256) private _balances;

    address public owner;
    uint256 public totalDeposits;

    error Unauthorized();
    error InvalidOwner();
    error InvalidAmount();
    error InsufficientBalance();
    error TransferFailed();

    constructor() {
        _disableInitializers();
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    function initialize(address initialOwner) external initializer {
        if (initialOwner == address(0)) revert InvalidOwner();
        owner = initialOwner;
    }

    function deposit() external payable {
        if (msg.value == 0) revert InvalidAmount();

        _balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        if (amount == 0) revert InvalidAmount();
        if (_balances[msg.sender] < amount) revert InsufficientBalance();

        _balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
