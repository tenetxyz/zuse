// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { EventApprovals } from "../prototypes/EventApprovals.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord, EventType } from "@tenet-contracts/src/Types.sol";
import { Player, PlayerTableId, PlayerData } from "@tenet-contracts/src/codegen/Tables.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";

uint256 constant MAX_HEALTH = 100;
uint256 constant MAX_STAMINA = 100;
uint256 constant STAMINA_BLOCK_RATE = 1;
uint256 constant TRAVEL_BLOCK_RATE = 10;
uint256 constant MINE_STAMINA_COST = 5;
uint256 constant BUILD_STAMINA_COST = 5;
uint256 constant ACTIVATE_STAMINA_COST = 1;

contract ApprovalSystem is EventApprovals {
  function preApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal override {
    // if there isn't a player entry in the table, then set the default values for the player
    if (!hasKey(PlayerTableId, Player.encodeKeyTuple(caller))) {
      Player.set(
        caller,
        PlayerData({ health: 100, stamina: 100, lastUpdateBlock: block.number, lastUpdateCoord: abi.encode(coord) })
        // TODO: Should use player spawn point
      );
    }
  }

  function postApproval(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal override {
    Player.setLastUpdateBlock(caller, block.number);
  }

  function staminaLimit(address caller, uint256 actionCost) internal {
    PlayerData memory playerData = Player.get(caller);
    uint256 numBlocksPassed = block.number - playerData.lastUpdateBlock;
    // TODO: What to do if numBlocksPassed is 0? Ie multiple tx in same block
    if (numBlocksPassed == 0) {
      numBlocksPassed = 1;
    }
    uint256 newStamina = playerData.stamina + (numBlocksPassed * STAMINA_BLOCK_RATE);
    if (newStamina > MAX_STAMINA) {
      newStamina = MAX_STAMINA;
    }
    require(
      newStamina >= actionCost,
      string.concat("Not enough stamina. Need ", Strings.toString(actionCost), " for this action")
    );
    Player.setStamina(caller, newStamina - actionCost);
  }

  function movementLimit(address caller, VoxelCoord memory coord) internal {
    PlayerData memory playerData = Player.get(caller);
    uint256 numBlocksPassed = block.number - playerData.lastUpdateBlock;
    // TODO: What to do if numBlocksPassed is 0? Ie multiple tx in same block
    if (numBlocksPassed == 0) {
      numBlocksPassed = 1;
    }
    uint256 distanceDelta = distanceBetween(abi.decode(playerData.lastUpdateCoord, (VoxelCoord)), coord);
    require(
      distanceDelta <= numBlocksPassed * TRAVEL_BLOCK_RATE,
      string.concat(
        "Cannot travel that far in ",
        Strings.toString(numBlocksPassed),
        " blocks. Distance delta: ",
        Strings.toString(distanceDelta)
      )
    );
    Player.setLastUpdateCoord(caller, abi.encode(coord));
  }

  function approveEvent(
    EventType eventType,
    address caller,
    bytes32 voxelTypeId,
    VoxelCoord memory coord
  ) internal override {
    movementLimit(caller, coord);
    uint256 staminaCost;
    if (eventType == EventType.Mine) {
      staminaCost = MINE_STAMINA_COST;
    } else if (eventType == EventType.Build) {
      staminaCost = BUILD_STAMINA_COST;
    } else if (eventType == EventType.Activate) {
      staminaCost = ACTIVATE_STAMINA_COST;
    }
    staminaLimit(caller, staminaCost);
  }

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.approveMine(caller, voxelTypeId, coord);
  }

  function approveBuild(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.approveBuild(caller, voxelTypeId, coord);
  }

  function approveActivate(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public override {
    super.approveActivate(caller, voxelTypeId, coord);
  }
}
