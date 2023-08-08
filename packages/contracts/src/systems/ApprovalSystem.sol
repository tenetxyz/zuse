// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { Player, PlayerTableId, PlayerData } from "@tenet-contracts/src/codegen/Tables.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { distanceBetween } from "@tenet-utils/src/VoxelCoordUtils.sol";

uint256 constant MAX_HEALTH = 100;
uint256 constant MAX_STAMINA = 100;
uint256 constant STAMINA_BLOCK_RATE = 1;
uint256 constant TRAVEL_BLOCK_RATE = 1;
uint256 constant MINE_STAMINA_COST = 5;
uint256 constant BUILD_STAMINA_COST = 5;
uint256 constant ACTIVATE_STAMINA_COST = 1;

contract ApprovalSystem is System {
  function playerInit(address caller, VoxelCoord memory coord) internal {
    // if there isn't a player entry in the table, then set the default values for the player
    if (!hasKey(PlayerTableId, Player.encodeKeyTuple(caller))) {
      Player.set(
        caller,
        PlayerData({ health: 50, stamina: 30, lastUpdateBlock: block.number, lastUpdateCoord: abi.encode(coord) })
        // TODO: Should use player spawn point
      );
    }
  }

  function staminaLimit(address caller, uint256 limit) internal {
    PlayerData memory playerData = Player.get(caller);
    uint256 numBlocksPassed = block.number - playerData.lastUpdateBlock;
    uint256 newStamina = playerData.stamina + (numBlocksPassed * STAMINA_BLOCK_RATE);
    if (newStamina > MAX_STAMINA) {
      newStamina = MAX_STAMINA;
    }
    require(
      newStamina >= limit,
      string.concat("Not enough stamina. Need ", Strings.toString(limit), " for this action")
    );
    Player.setStamina(caller, newStamina - limit);
  }

  function movementLimit(address caller, VoxelCoord memory coord) internal {
    PlayerData memory playerData = Player.get(caller);
    uint256 numBlocksPassed = block.number - playerData.lastUpdateBlock;
    uint256 distanceDelta = distanceBetween(abi.decode(playerData.lastUpdateCoord, (VoxelCoord)), coord);
    require(distanceDelta <= numBlocksPassed * TRAVEL_BLOCK_RATE, "Cannot travel that far.");
    Player.setLastUpdateCoord(caller, abi.encode(coord));
  }

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller, coord);
    movementLimit(caller, coord);
    staminaLimit(caller, MINE_STAMINA_COST);
    Player.setLastUpdateBlock(caller, block.number);
  }

  function approveBuild(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller, coord);
    movementLimit(caller, coord);
    staminaLimit(caller, BUILD_STAMINA_COST);
    Player.setLastUpdateBlock(caller, block.number);
  }

  function approveActivate(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller, coord);
    movementLimit(caller, coord);
    staminaLimit(caller, ACTIVATE_STAMINA_COST);
    Player.setLastUpdateBlock(caller, block.number);
  }
}
