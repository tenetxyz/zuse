// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { Player, PlayerTableId, PlayerData } from "@tenet-contracts/src/codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";

uint256 constant STAMINA_BLOCK_RATE = 1;
uint256 constant MINE_STAMINA_COST = 5;
uint256 constant BUILD_STAMINA_COST = 5;
uint256 constant ACTIVATE_STAMINA_COST = 1;

contract ApprovalSystem is System {
  function playerInit(address caller) internal {
    // if there isn't a player entry in the table, then set the default values for the player
    if (!hasKey(PlayerTableId, Player.encodeKeyTuple(caller))) {
      Player.set(caller, PlayerData({ health: 50, stamina: 30, lastUpdateBlock: block.number }));
    }
  }

  function staminaLimit(address caller, uint256 limit) public returns (uint256) {
    PlayerData memory playerData = Player.get(caller);
    uint256 numBlocksPassed = block.number - playerData.lastUpdateBlock;
    uint256 newStamina = playerData.stamina + (numBlocksPassed * STAMINA_BLOCK_RATE);
    require(newStamina >= limit, "MineSystem: not enough stamina");
    Player.set(
      caller,
      PlayerData({ health: playerData.health, stamina: newStamina - limit, lastUpdateBlock: block.number })
    );
  }

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller);
    staminaLimit(caller, MINE_STAMINA_COST);
  }

  function approveBuild(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller);
    staminaLimit(caller, BUILD_STAMINA_COST);
  }

  function approveActivate(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller);
    staminaLimit(caller, ACTIVATE_STAMINA_COST);
  }
}
