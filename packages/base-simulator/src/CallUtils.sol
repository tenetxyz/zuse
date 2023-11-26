// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { VoxelCoord, SimTable, ValueType, ObjectType } from "@tenet-utils/src/Types.sol";
import { safeCall, callOrRevert, staticCallOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { SimAction, SimActionData } from "@tenet-base-simulator/src/codegen/tables/SimAction.sol";

// TODO: Find a way to auto-generate this
function runSimAction(
  address simAddress,
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
  if (simSelectors.selector == bytes4(0)) {
    return (false, new bytes(0));
  }
  if (simSelectors.senderValueType == ValueType.Int256 && simSelectors.receiverValueType == ValueType.Int256) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderObjectEntityId,
          senderCoord,
          abi.decode(senderValue, (int256)),
          receiverObjectEntityId,
          receiverCoord,
          abi.decode(receiverValue, (int256))
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
  } else if (
    simSelectors.senderValueType == ValueType.ObjectType && simSelectors.receiverValueType == ValueType.ObjectType
  ) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderObjectEntityId,
          senderCoord,
          abi.decode(senderValue, (ObjectType)),
          receiverObjectEntityId,
          receiverCoord,
          abi.decode(receiverValue, (ObjectType))
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
  } else if (
    simSelectors.senderValueType == ValueType.Int256 && simSelectors.receiverValueType == ValueType.ObjectType
  ) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderObjectEntityId,
          senderCoord,
          abi.decode(senderValue, (int256)),
          receiverObjectEntityId,
          receiverCoord,
          abi.decode(receiverValue, (ObjectType))
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
  } else if (
    simSelectors.senderValueType == ValueType.Int256 && simSelectors.receiverValueType == ValueType.VoxelCoord
  ) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderObjectEntityId,
          senderCoord,
          abi.decode(senderValue, (int256)),
          receiverObjectEntityId,
          receiverCoord,
          abi.decode(receiverValue, (VoxelCoord))
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
  } else if (
    simSelectors.senderValueType == ValueType.Int256 && simSelectors.receiverValueType == ValueType.VoxelCoordArray
  ) {
    return
      safeCall(
        simAddress,
        abi.encodeWithSelector(
          simSelectors.selector,
          senderObjectEntityId,
          senderCoord,
          abi.decode(senderValue, (int256)),
          receiverObjectEntityId,
          receiverCoord,
          abi.decode(receiverValue, (VoxelCoord[]))
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
