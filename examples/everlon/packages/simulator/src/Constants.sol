// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0x057ef64E23666F000b34aE31332854aCBd1c8544;

uint256 constant NUM_BLOCKS_BEFORE_REDUCE_VELOCITY = 60; // 1 minute if 1 block == 1 second
uint256 constant NUM_MIN_HEALTH_FOR_NO_WAIT = 10;
uint256 constant NUM_MAX_BLOCKS_TO_WAIT_IF_NO_HEALTH = 30; // 30 seconds if 1 block == 1 second
uint256 constant GRAVITY_DAMAGE = 5;
