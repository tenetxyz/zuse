// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { IWorld } from "@tenet-simulator/src/codegen/world/IWorld.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { Constraint } from "@tenet-base-simulator/src/prototypes/Constraint.sol";

import { SimAction } from "@tenet-simulator/src/codegen/tables/SimAction.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Element, ElementTableId } from "@tenet-simulator/src/codegen/tables/Element.sol";

import { VoxelCoord, SimTable, ElementType } from "@tenet-utils/src/Types.sol";
import { addUint256AndInt256, int256ToUint256 } from "@tenet-utils/src/TypeUtils.sol";

contract ElementConstraintSystem is Constraint {
  function registerElementSelector() public {
    SimAction.set(
      SimTable.Element,
      SimTable.Element,
      IWorld(_world()).elementTransformation.selector,
      IWorld(_world()).elementTransfer.selector
    );
  }

  function decodeAmounts(
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal pure returns (ElementType, ElementType) {
    return (abi.decode(fromAmount, (ElementType)), abi.decode(toAmount, (ElementType)));
  }

  function elementTransformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transformation(objectEntityId, coord, fromAmount, toAmount);
  }

  function elementTransfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) public {
    return transfer(senderObjectEntityId, senderCoord, receiverObjectEntityId, receiverCoord, fromAmount, toAmount);
  }

  function transformation(
    bytes32 objectEntityId,
    VoxelCoord memory coord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    address worldAddress = super.getCallerAddress();
    require(
      Element.get(worldAddress, objectEntityId) == ElementType.None,
      "ElementConstraintSystem: Element already set"
    );
    (, ElementType toElementType) = decodeAmounts(fromAmount, toAmount);
    Element.set(worldAddress, objectEntityId, toElementType);
  }

  function transfer(
    bytes32 senderObjectEntityId,
    VoxelCoord memory senderCoord,
    bytes32 receiverObjectEntityId,
    VoxelCoord memory receiverCoord,
    bytes memory fromAmount,
    bytes memory toAmount
  ) internal override {
    revert("ElementConstraintSystem: You can't transfer element to another entity");
  }
}
