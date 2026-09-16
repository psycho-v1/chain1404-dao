// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library ConstitutionParams {
    uint16 internal constant MINER_WEIGHT_BPS = 7_000;
    uint16 internal constant STAKER_WEIGHT_BPS = 3_000;
    uint16 internal constant BPS_DENOMINATOR = 10_000;
    uint16 internal constant ORDINARY_MINER_QUORUM_BPS = 1_500;
    uint16 internal constant ORDINARY_STAKER_QUORUM_BPS = 1_000;
    uint16 internal constant ORDINARY_CHAMBER_FLOOR_BPS = 4_000;
    uint16 internal constant ORDINARY_SCORE_BPS = 5_001;
    uint16 internal constant CRITICAL_MINER_QUORUM_BPS = 2_000;
    uint16 internal constant CRITICAL_STAKER_QUORUM_BPS = 1_500;
    uint16 internal constant CRITICAL_SCORE_BPS = 6_000;
    uint64 internal constant ORDINARY_DELAY = 72 hours;
    uint64 internal constant CRITICAL_DELAY = 7 days;
    uint32 internal constant SIGNALLING_WINDOW = 2_000;
    uint32 internal constant SIGNALLING_THRESHOLD = 1_500;
    uint64 internal constant SNAPSHOT_CHALLENGE_WINDOW = 48 hours;
    uint64 internal constant GUARDIAN_PAUSE_LIMIT = 14 days;
}
