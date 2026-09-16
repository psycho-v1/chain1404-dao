// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISnapshotRegistry} from "./interfaces/ISnapshotRegistry.sol";
import {ConstitutionParams} from "./libraries/ConstitutionParams.sol";

contract SnapshotRegistry is ISnapshotRegistry {
    error AlreadyPublished();
    error ChallengeClosed();
    error AlreadyFrozen();
    error AlreadyInvalid();
    error BadProof();
    error BondNotPosted();
    error NotPublished();

    event RootSubmitted(uint256 indexed epochId, address indexed proposer, bytes32 minerRoot, bytes32 stakerRoot);
    event RootChallenged(uint256 indexed epochId, address indexed challenger, string reason);
    event RootFrozen(uint256 indexed epochId);

    mapping(uint256 => EpochRoot) private _epochs;
    mapping(address => uint256) public bonds;
    uint256 public proposerBond;
    uint256 public latestFrozen;
    address public admin;

    constructor(uint256 bond_) {
        proposerBond = bond_;
        admin = msg.sender;
    }

    function setBond(uint256 bond_) external {
        require(msg.sender == admin, "not admin");
        proposerBond = bond_;
    }

    function transferAdmin(address next) external {
        require(msg.sender == admin, "not admin");
        admin = next;
    }

    function postBond() external payable {
        bonds[msg.sender] += msg.value;
    }

    function submit(
        uint256 epochId,
        bytes32 minerRoot,
        bytes32 stakerRoot,
        uint256 minerTotal,
        uint256 stakerTotal,
        uint64 checkpoint,
        bytes32 checkpointHash,
        bytes32 stateRoot
    ) external {
        if (bonds[msg.sender] < proposerBond) revert BondNotPosted();
        EpochRoot storage e = _epochs[epochId];
        if (e.publishedAt != 0) revert AlreadyPublished();
        e.minerRoot = minerRoot;
        e.stakerRoot = stakerRoot;
        e.minerTotal = minerTotal;
        e.stakerTotal = stakerTotal;
        e.checkpoint = checkpoint;
        e.checkpointHash = checkpointHash;
        e.stateRoot = stateRoot;
        e.publishedAt = uint64(block.timestamp);
        e.challengeDeadline = uint64(block.timestamp + ConstitutionParams.SNAPSHOT_CHALLENGE_WINDOW);
        emit RootSubmitted(epochId, msg.sender, minerRoot, stakerRoot);
    }

    function challenge(uint256 epochId, address proposer, string calldata reason) external {
        EpochRoot storage e = _epochs[epochId];
        if (e.publishedAt == 0) revert NotPublished();
        if (block.timestamp > e.challengeDeadline) revert ChallengeClosed();
        if (e.invalidated) revert AlreadyInvalid();
        if (e.frozen) revert AlreadyFrozen();
        e.invalidated = true;
        uint256 slash = bonds[proposer];
        bonds[proposer] = 0;
        emit RootChallenged(epochId, msg.sender, reason);
        if (slash > 0) {
            (bool ok,) = payable(msg.sender).call{value: slash}("");
            require(ok, "slash xfer");
        }
    }

    function freeze(uint256 epochId) external {
        EpochRoot storage e = _epochs[epochId];
        if (e.publishedAt == 0) revert NotPublished();
        if (e.invalidated) revert AlreadyInvalid();
        if (block.timestamp <= e.challengeDeadline) revert ChallengeClosed();
        e.frozen = true;
        if (epochId > latestFrozen) latestFrozen = epochId;
        emit RootFrozen(epochId);
    }

    function epoch(uint256 epochId) external view returns (EpochRoot memory) {
        return _epochs[epochId];
    }

    function latestFrozenEpoch() external view returns (uint256) {
        return latestFrozen;
    }

    function weightOf(uint256 epochId, Chamber chamber, address account, uint256 credits, bytes32[] calldata proof)
        external view returns (uint256)
    {
        EpochRoot storage e = _epochs[epochId];
        if (!e.frozen || e.invalidated) revert AlreadyInvalid();
        bytes32 root = chamber == Chamber.Miner ? e.minerRoot : e.stakerRoot;
        bytes32 leaf_ = keccak256(abi.encodePacked(account, credits));
        bytes32 computed = leaf_;
        for (uint256 i = 0; i < proof.length; i++) {
            computed = computed < proof[i]
                ? keccak256(abi.encodePacked(computed, proof[i]))
                : keccak256(abi.encodePacked(proof[i], computed));
        }
        if (computed != root) revert BadProof();
        return credits;
    }
}
