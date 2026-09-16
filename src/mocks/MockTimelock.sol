// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ITimelockLike} from "../interfaces/ITimelockLike.sol";

contract MockTimelock is ITimelockLike {
    struct Op { address target; uint256 value; bytes data; uint256 readyAt; bool pending; bool done; bool cancelled; }
    mapping(bytes32 => Op) public ops;
    uint256 public minDelay;
    address public governor;
    constructor(uint256 minDelay_, address governor_) { minDelay = minDelay_; governor = governor_; }
    function setGovernor(address g) external { governor = g; }
    function hashOperation(address target, uint256 value, bytes calldata data, bytes32, bytes32 salt) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, data, salt));
    }
    function schedule(address target, uint256 value, bytes calldata data, bytes32, bytes32 salt, uint256 delay) external {
        require(msg.sender == governor, "not governor");
        bytes32 id = hashOperation(target, value, data, bytes32(0), salt);
        ops[id] = Op(target, value, data, block.timestamp + delay, true, false, false);
    }
    function execute(address target, uint256 value, bytes calldata payload, bytes32, bytes32 salt) external payable {
        bytes32 id = hashOperation(target, value, payload, bytes32(0), salt);
        Op storage op = ops[id];
        require(op.pending && !op.cancelled, "not pending");
        require(block.timestamp >= op.readyAt, "not ready");
        op.pending = false; op.done = true;
        (bool ok, bytes memory ret) = target.call{value: value}(payload);
        require(ok, string(ret));
    }
    function cancel(bytes32 id) external { require(msg.sender == governor, "not governor"); ops[id].cancelled = true; ops[id].pending = false; }
    function getMinDelay() external view returns (uint256) { return minDelay; }
    function isOperationPending(bytes32 id) external view returns (bool) { return ops[id].pending; }
    function isOperationReady(bytes32 id) external view returns (bool) { return ops[id].pending && !ops[id].cancelled && block.timestamp >= ops[id].readyAt; }
    function isOperationDone(bytes32 id) external view returns (bool) { return ops[id].done; }
}
