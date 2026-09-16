// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IGovernedList {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function setBlocked(address account, bool blocked) external;
    function setBlockedBatch(address[] calldata accounts, bool blocked) external;
}

interface ISelectiveList {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function setRestricted(address sender, bool restricted) external;
    function setAllowedTo(address sender, address destination, bool allowed) external;
}

interface IStakingProxy {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
