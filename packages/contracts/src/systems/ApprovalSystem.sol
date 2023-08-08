// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { VoxelCoord } from "@tenet-contracts/src/Types.sol";
import { Player, PlayerTableId, PlayerData } from "@tenet-contracts/src/codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";

uint256 constant STAMINA_BLOCK_RATE = 1;
uint256 constant HEALTH_BLOCK_RATE = 1;
uint256 constant MINE_STAMINA_COST = 5;

contract ApprovalSystem is System {
  function playerInit(address caller) internal {
    // if there isn't a player entry in the table, then set the default values for the player
    if (!hasKey(PlayerTableId, Player.encodeKeyTuple(caller))) {
      Player.set(caller, PlayerData({ health: 50, stamina: 30, lastUpdateBlock: block.number }));
    }
  }

  function approveMine(address caller, bytes32 voxelTypeId, VoxelCoord memory coord) public {
    playerInit(caller);
    PlayerData memory playerData = Player.get(caller);
    uint256 numBlocksPassed = block.number - playerData.lastUpdateBlock;
    uint256 newStamina = playerData.stamina + (numBlocksPassed * STAMINA_BLOCK_RATE);
    require(playerData.stamina >= MINE_STAMINA_COST, "MineSystem: not enough stamina");
    Player.set(
      caller,
      PlayerData({ health: playerData.health, stamina: newStamina - MINE_STAMINA_COST, lastUpdateBlock: block.number })
    );
  }
}
