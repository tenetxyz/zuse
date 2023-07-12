// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { Classifier, ClassifierData } from "@tenet-contracts/src/codegen/Tables.sol";
import { IWorld } from "@tenet-contracts/src/codegen/world/IWorld.sol";
import { console } from "forge-std/console.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import { NamespaceOwner } from "@latticexyz/world/src/tables/NamespaceOwner.sol";
import { InterfaceVoxel } from "@tenet-contracts/src/Types.sol";

contract RegisterClassifierSystem is System {
  function registerClassifier(
    bytes4 classifySelector,
    string memory name,
    string memory description,
    string memory classificationResultTableName,
    InterfaceVoxel[] memory selectorInterface
  ) public {
    (bytes16 namespace, , ) = FunctionSelectors.get(classifySelector);
    require(NamespaceOwner.get(namespace) == _msgSender(), "Caller is not namespace owner");
    bytes32 uniqueEntity = getUniqueEntity();
    validateInterfaceVoxels(selectorInterface);
    Classifier.set(
      uniqueEntity,
      ClassifierData({
        creator: tx.origin,
        classifySelector: classifySelector,
        name: name,
        description: description,
        classificationResultTableName: classificationResultTableName,
        selectorInterface: abi.encode(selectorInterface)
      })
    );
  }

  function validateInterfaceVoxels(InterfaceVoxel[] memory selectorInterface) public {
    for (uint256 i = 0; i < selectorInterface.length; i++) {
      InterfaceVoxel memory interfaceVoxel = selectorInterface[i];
      require(bytes(interfaceVoxel.name).length > 0, "Interface voxel name cannot be empty");
    }
  }
}
