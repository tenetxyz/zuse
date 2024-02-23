// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

address constant REGISTRY_ADDRESS = 0xB088741f11DB22A5DB2f2ddE851FD1c9DF10FA71;

uint256 constant MAX_AGENT_HEALTH = 100;
uint256 constant MAX_AGENT_STAMINA = 200000;

uint256 constant NUM_BLOCKS_BEFORE_REDUCE_VELOCITY = 60; // 1 minute if 1 block == 1 second
uint256 constant NUM_BLOCKS_BEFORE_INCREASE_STAMINA = 60; // 1 minute if 1 block == 1 second
uint256 constant STAMINA_INCREASE_RATE = 1666;
uint256 constant NUM_BLOCKS_BEFORE_INCREASE_HEALTH = 60; // 1 minute if 1 block == 1 second
uint256 constant HEALTH_INCREASE_RATE = 2;
uint256 constant NUM_MIN_HEALTH_FOR_NO_WAIT = 10;
uint256 constant NUM_MAX_BLOCKS_TO_WAIT_IF_NO_HEALTH = 30; // 30 seconds if 1 block == 1 second
uint256 constant GRAVITY_DAMAGE = 10;
uint256 constant COLLISION_DAMAGE = 5;
