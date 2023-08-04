// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { Player, PlayerData, PlayerTableId } from "@tenet-contracts/src/codegen/Tables.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

contract InitPlayerSystem is System {
  function init() public {
    address player = _msgSender();
    // if there isn't a player entry in the table, then set the default values for the player
    if (!hasKey(PlayerTableId, Player.encodeKeyTuple(player))) {
      Player.set(player, PlayerData({ health: 50, stamina: 30 }));
    }
  }
}
