// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { ObjectType } from "@tenet-base-world/src/prototypes/ObjectType.sol";
import { VoxelCoord, ObjectProperties, Action } from "@tenet-utils/src/Types.sol";
import { Mind, MindData, MindTableId } from "@tenet-base-world/src/codegen/tables/Mind.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { getFirstCaller } from "@tenet-utils/src/Utils.sol";

// Represents an object
abstract contract AgentType is ObjectType {
  // TODO: Remove this function once we know a better way to handle
  // address forwarding for agents
  function getCallerAddress() internal view returns (address) {
    address callerAddress = getFirstCaller();
    if (callerAddress == address(0)) {
      callerAddress = _msgSender();
    }
    return callerAddress;
  }

  // Called by Zuse when an event occurs where this object is the center entity
  // Returns the actions it wants to invoke
  function eventHandler(
    bytes32 centerObjectEntityId,
    bytes32[] memory neighbourObjectEntityIds
  ) public virtual override returns (Action[] memory) {
    // Call mind, and call event handler selected
    MindData memory mindData = Mind.get(centerObjectEntityId);
    if (mindData.mindAddress == address(0) || mindData.mindSelector == bytes4(0)) {
      return new Action[](0);
    }

    bytes memory mindReturnData = callOrRevert(
      mindData.mindAddress,
      abi.encodeWithSelector(mindData.mindSelector, centerObjectEntityId, neighbourObjectEntityIds),
      "mindSelector"
    );
    (address eventHandlerAddress, bytes4 eventHandlerSelector) = abi.decode(mindReturnData, (address, bytes4));
    if (eventHandlerAddress == address(0) || eventHandlerSelector == bytes4(0)) {
      return new Action[](0);
    }

    bytes memory eventHandlerReturnData = callOrRevert(
      eventHandlerAddress,
      abi.encodeWithSelector(eventHandlerSelector, centerObjectEntityId, neighbourObjectEntityIds),
      "eventHandler"
    );
    return abi.decode(eventHandlerReturnData, (Action[]));
  }
}
