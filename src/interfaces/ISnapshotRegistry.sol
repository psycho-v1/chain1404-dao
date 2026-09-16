// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ISnapshotRegistry {
    enum Chamber { Miner, Staker }

    struct EpochRoot {
        bytes32 minerRoot;
        bytes32 stakerRoot;
        uint256 minerTotal;
        uint256 stakerTotal;
        uint64 checkpoint;
        bytes32 checkpointHash;
        bytes32 stateRoot;
        uint64 publishedAt;
        uint64 challengeDeadline;
        bool frozen;
        bool invalidated;
    }

    function epoch(uint256 epochId) external view returns (EpochRoot memory);
    function latestFrozenEpoch() external view returns (uint256);
    function weightOf(uint256 epochId, Chamber chamber, address account, uint256 credits, bytes32[] calldata proof)
        external view returns (uint256);
}
