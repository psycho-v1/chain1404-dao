// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockList {
    address public owner;
    mapping(address => bool) public blocked;
    constructor(address owner_) { owner = owner_; }
    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
    function transferOwnership(address newOwner) external onlyOwner { owner = newOwner; }
    function setBlocked(address account, bool value) external onlyOwner { blocked[account] = value; }
    function setBlockedBatch(address[] calldata accounts, bool value) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) blocked[accounts[i]] = value;
    }
}

contract MockStakingProxy {
    address public owner;
    address public implementation;
    constructor(address owner_, address implementation_) { owner = owner_; implementation = implementation_; }
    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }
    function transferOwnership(address newOwner) external onlyOwner { owner = newOwner; }
    function upgradeToAndCall(address newImplementation, bytes memory) external payable onlyOwner { implementation = newImplementation; }
}
