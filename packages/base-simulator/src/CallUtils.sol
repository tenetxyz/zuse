// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, SimTable, ActionType } from "@tenet-utils/src/Types.sol";
import { safeCall, callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { SimAction, SimActionData } from "@tenet-base-simulator/src/codegen/tables/SimAction.sol";

function runSimAction(
  address simAddress,
  ActionType actionType,
  bytes32 senderObjectEntityId,
  VoxelCoord memory senderCoord,
  SimTable senderTable,
  bytes memory senderValue,
  bytes32 receiverObjectEntityId,
  VoxelCoord memory receiverCoord,
  SimTable receiverTable,
  bytes memory receiverValue
) returns (bool, bytes memory) {
  SimActionData memory simSelectors = SimAction.get(IStore(simAddress), senderTable, receiverTable);
  if (actionType == ActionType.Transformation) {
    if (simSelectors.transformationSelector == bytes4(0)) {
      return (false, new bytes(0));
    }

    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.transformationSelector,
          senderObjectEntityId,
          senderCoord,
          senderValue,
          receiverValue
        ),
        string(
          abi.encode(
            "setSimValue ",
            senderObjectEntityId,
            " ",
            senderCoord,
            " ",
            senderTable,
            " ",
            senderValue,
            " ",
            receiverValue
          )
        )
      );
  } else if (actionType == ActionType.Transfer) {
    if (simSelectors.transferSelector == bytes4(0)) {
      return (false, new bytes(0));
    }

    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.transferSelector,
          senderObjectEntityId,
          senderCoord,
          receiverObjectEntityId,
          receiverCoord,
          senderValue,
          receiverValue
        ),
        string(
          abi.encode(
            "setSimValue ",
            senderObjectEntityId,
            " ",
            senderCoord,
            " ",
            senderTable,
            " ",
            senderValue,
            " ",
            receiverObjectEntityId,
            " ",
            receiverCoord,
            " ",
            receiverTable,
            " ",
            receiverValue
          )
        )
      );
  } else {
    return (false, new bytes(0));
  }
}
