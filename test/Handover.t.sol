// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MockList, MockStakingProxy} from "../src/mocks/MockList.sol";
import {MockTimelock} from "../src/mocks/MockTimelock.sol";
import {SnapshotRegistry} from "../src/SnapshotRegistry.sol";
import {DualChamberGovernor} from "../src/DualChamberGovernor.sol";

contract HandoverTest is Test {
    MockList list;
    MockStakingProxy staking;
    MockTimelock lock;
    address oldOwner = address(0xE0A);
    address stranger = address(0xBAD);

    function setUp() public {
        SnapshotRegistry snaps = new SnapshotRegistry(0);
        lock = new MockTimelock(1, address(0));
        DualChamberGovernor gov = new DualChamberGovernor(snaps, lock, 0);
        lock.setGovernor(address(gov));
        list = new MockList(oldOwner);
        staking = new MockStakingProxy(oldOwner, address(0xDC14));
        vm.startPrank(oldOwner);
        list.transferOwnership(address(lock));
        staking.transferOwnership(address(lock));
        vm.stopPrank();
    }

    function test_owner_slots_are_timelock() public view {
        assertEq(list.owner(), address(lock));
        assertEq(staking.owner(), address(lock));
    }

    function test_random_eoa_cannot_setBlocked() public {
        vm.prank(stranger);
        vm.expectRevert(bytes("not owner"));
        list.setBlocked(stranger, true);
    }

    function test_old_eoa_cannot_upgrade_after_handover() public {
        vm.prank(oldOwner);
        vm.expectRevert(bytes("not owner"));
        staking.upgradeToAndCall(address(0x1111), "");
    }
}
