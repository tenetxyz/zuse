// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Powered, PoweredData, PoweredTableId } from "../codegen/Tables.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";

import { SystemRegistry } from "@latticexyz/world/src/modules/core/tables/SystemRegistry.sol";
import { ResourceSelector} from "@latticexyz/world/src/ResourceSelector.sol";

contract PoweredSystem is System {

  function eventHandler(bytes32 centerEntityId, bytes32[] memory neighbourEntityIds) public returns (bytes32[] memory changedEntityIds) {
    bytes32[] memory changedEntityIds = new bytes32[](neighbourEntityIds.length);

    address caller = _msgSender();
    require(uint256(SystemRegistry.get(caller)) != 0, "Caller is not a system"); // cannot be called by an EOA
    bytes32 resourceSelector = SystemRegistry.get(caller);
    bytes16 callerNamespace = ResourceSelector.getNamespace(resourceSelector);
    // TODO: require not root namespace

    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = bytes32((callerNamespace));
    keyTuple[1] = bytes32((centerEntityId));

     Powered.set(callerNamespace, centerEntityId, PoweredData({
        isActive: false,
        direction: 0
      }));

    // TODO: Add back once non-root module is supported
    // if(!hasKey(PoweredTableId, keyTuple)){
    //   Powered.set(callerNamespace, centerEntityId, PoweredData({
    //     isActive: false,
    //     direction: 0
    //   }));
    // } else {
    //   PoweredData memory centerPowerData = Powered.get(callerNamespace, centerEntityId);
    //   if(!centerPowerData.isActive){
    //     // set to active
    //     centerPowerData.isActive = true;
    //     Powered.set(callerNamespace, centerEntityId, centerPowerData);
    //   }
    // }

    return changedEntityIds;
  }

}