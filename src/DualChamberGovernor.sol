// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISnapshotRegistry} from "./interfaces/ISnapshotRegistry.sol";
import {ITimelockLike} from "./interfaces/ITimelockLike.sol";
import {ConstitutionParams} from "./libraries/ConstitutionParams.sol";

/// @notice Two-chamber Governor. Votes come from frozen epoch reward credits,
///         not from wallet balances. The Governor proposes and cancels.
///         The timelock owns the dangerous contracts.
contract DualChamberGovernor {
    enum Class { Ordinary, Critical, ConsensusChange }
    enum Status { Pending, Active, Succeeded, Defeated, Queued, Executed, Cancelled }

    struct Proposal {
        address proposer;
        Class class;
        uint256 epochId;
        address target;
        uint256 value;
        bytes data;
        bytes32 salt;
        bytes32 descriptionHash;
        uint64 voteStart;
        uint64 voteEnd;
        uint256 minerYes;
        uint256 minerNo;
        uint256 minerVoted;
        uint256 stakerYes;
        uint256 stakerNo;
        uint256 stakerVoted;
        Status status;
        bytes32 timelockId;
    }

    error BadEpoch();
    error AlreadyVoted();
    error NotActive();
    error NotSucceeded();
    error OnlyGovernorAdmin();
    error ZeroAddress();

    event ProposalCreated(uint256 indexed id, address indexed proposer, Class class, uint256 epochId);
    event VoteCast(uint256 indexed id, address indexed voter, ISnapshotRegistry.Chamber chamber, bool support, uint256 weight);
    event ProposalFinalized(uint256 indexed id, Status status, uint16 scoreBps);
    event ProposalQueued(uint256 indexed id, bytes32 timelockId, uint256 delay);
    event ProposalCancelled(uint256 indexed id);

    ISnapshotRegistry public immutable snapshots;
    ITimelockLike public immutable timelock;
    address public admin;
    uint256 public proposalCount;
    uint256 public genesisScaleThreshold;
    mapping(uint256 => Proposal) private _proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint64 public votingDelay = 1 hours;
    uint64 public ordinaryVotingPeriod = 3 days;
    uint64 public criticalVotingPeriod = 7 days;

    constructor(ISnapshotRegistry snapshots_, ITimelockLike timelock_, uint256 genesisScaleThreshold_) {
        if (address(snapshots_) == address(0) || address(timelock_) == address(0)) revert ZeroAddress();
        snapshots = snapshots_;
        timelock = timelock_;
        admin = msg.sender;
        genesisScaleThreshold = genesisScaleThreshold_;
    }

    function proposals(uint256 id) external view returns (Proposal memory) {
        return _proposals[id];
    }

    function transferAdmin(address next) external {
        if (msg.sender != admin) revert OnlyGovernorAdmin();
        if (next == address(0)) revert ZeroAddress();
        admin = next;
    }

    function propose(Class class, address target, uint256 value, bytes calldata data, bytes32 salt, string calldata description)
        external returns (uint256 id)
    {
        uint256 epochId = snapshots.latestFrozenEpoch();
        ISnapshotRegistry.EpochRoot memory root = snapshots.epoch(epochId);
        if (!root.frozen || root.invalidated) revert BadEpoch();
        id = ++proposalCount;
        uint64 start = uint64(block.timestamp + votingDelay);
        uint64 period = class == Class.Ordinary ? ordinaryVotingPeriod : criticalVotingPeriod;
        _proposals[id] = Proposal({
            proposer: msg.sender,
            class: class,
            epochId: epochId,
            target: target,
            value: value,
            data: data,
            salt: salt,
            descriptionHash: keccak256(bytes(description)),
            voteStart: start,
            voteEnd: start + period,
            minerYes: 0,
            minerNo: 0,
            minerVoted: 0,
            stakerYes: 0,
            stakerNo: 0,
            stakerVoted: 0,
            status: Status.Pending,
            timelockId: bytes32(0)
        });
        emit ProposalCreated(id, msg.sender, class, epochId);
    }

    function activate(uint256 id) public {
        Proposal storage p = _proposals[id];
        if (p.status != Status.Pending) revert NotActive();
        if (block.timestamp < p.voteStart) revert NotActive();
        p.status = Status.Active;
    }

    function vote(uint256 id, ISnapshotRegistry.Chamber chamber, bool support, uint256 credits, bytes32[] calldata proof) external {
        Proposal storage p = _proposals[id];
        if (p.status == Status.Pending && block.timestamp >= p.voteStart) activate(id);
        if (p.status != Status.Active) revert NotActive();
        if (block.timestamp > p.voteEnd) revert NotActive();
        if (hasVoted[id][msg.sender]) revert AlreadyVoted();
        uint256 weight = snapshots.weightOf(p.epochId, chamber, msg.sender, credits, proof);
        hasVoted[id][msg.sender] = true;
        if (chamber == ISnapshotRegistry.Chamber.Miner) {
            p.minerVoted += weight;
            if (support) p.minerYes += weight; else p.minerNo += weight;
        } else {
            p.stakerVoted += weight;
            if (support) p.stakerYes += weight; else p.stakerNo += weight;
        }
        emit VoteCast(id, msg.sender, chamber, support, weight);
    }

    function finalize(uint256 id) external returns (Status) {
        Proposal storage p = _proposals[id];
        if (p.status == Status.Pending && block.timestamp >= p.voteStart) activate(id);
        if (p.status != Status.Active) revert NotActive();
        if (block.timestamp <= p.voteEnd) revert NotActive();
        ISnapshotRegistry.EpochRoot memory root = snapshots.epoch(p.epochId);
        (bool ok, uint16 scored) = _passed(p, root);
        p.status = ok ? Status.Succeeded : Status.Defeated;
        emit ProposalFinalized(id, p.status, scored);
        return p.status;
    }

    function queue(uint256 id) external {
        Proposal storage p = _proposals[id];
        if (p.status != Status.Succeeded) revert NotSucceeded();
        uint256 delay = p.class == Class.Ordinary ? ConstitutionParams.ORDINARY_DELAY : ConstitutionParams.CRITICAL_DELAY;
        if (delay < timelock.getMinDelay()) delay = timelock.getMinDelay();
        timelock.schedule(p.target, p.value, p.data, bytes32(0), p.salt, delay);
        p.timelockId = timelock.hashOperation(p.target, p.value, p.data, bytes32(0), p.salt);
        p.status = Status.Queued;
        emit ProposalQueued(id, p.timelockId, delay);
    }

    function cancel(uint256 id) external {
        Proposal storage p = _proposals[id];
        if (msg.sender != p.proposer && msg.sender != admin) revert OnlyGovernorAdmin();
        if (p.status == Status.Executed || p.status == Status.Cancelled) revert NotActive();
        if (p.timelockId != bytes32(0)) timelock.cancel(p.timelockId);
        p.status = Status.Cancelled;
        emit ProposalCancelled(id);
    }

    function _passed(Proposal storage p, ISnapshotRegistry.EpochRoot memory root) internal view returns (bool, uint16) {
        uint16 minerQuorum;
        uint16 stakerQuorum;
        uint16 floorBps;
        uint16 needScore;
        bool needMajorityBoth;
        if (p.class == Class.Ordinary) {
            minerQuorum = ConstitutionParams.ORDINARY_MINER_QUORUM_BPS;
            stakerQuorum = ConstitutionParams.ORDINARY_STAKER_QUORUM_BPS;
            floorBps = ConstitutionParams.ORDINARY_CHAMBER_FLOOR_BPS;
            needScore = ConstitutionParams.ORDINARY_SCORE_BPS;
            needMajorityBoth = false;
        } else {
            minerQuorum = ConstitutionParams.CRITICAL_MINER_QUORUM_BPS;
            stakerQuorum = ConstitutionParams.CRITICAL_STAKER_QUORUM_BPS;
            floorBps = 5_000;
            needScore = ConstitutionParams.CRITICAL_SCORE_BPS;
            needMajorityBoth = true;
        }
        if (root.minerTotal == 0 || root.stakerTotal == 0) return (false, 0);
        if ((p.minerVoted * ConstitutionParams.BPS_DENOMINATOR) / root.minerTotal < minerQuorum) return (false, 0);
        if ((p.stakerVoted * ConstitutionParams.BPS_DENOMINATOR) / root.stakerTotal < stakerQuorum) return (false, 0);
        uint16 m = _share(p.minerYes, p.minerYes + p.minerNo);
        uint16 s = _share(p.stakerYes, p.stakerYes + p.stakerNo);
        if (m < floorBps || s < floorBps) return (false, 0);
        if (needMajorityBoth && (m < 5_000 || s < 5_000)) return (false, 0);
        uint16 score = uint16((uint256(m) * ConstitutionParams.MINER_WEIGHT_BPS + uint256(s) * ConstitutionParams.STAKER_WEIGHT_BPS) / ConstitutionParams.BPS_DENOMINATOR);
        if (score < needScore) return (false, score);
        return (true, score);
    }

    function _share(uint256 yes, uint256 cast) internal pure returns (uint16) {
        if (cast == 0) return 0;
        return uint16((yes * ConstitutionParams.BPS_DENOMINATOR) / cast);
    }
}
