// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { ClassifierRegistry, ClassifierRegistryData } from "@tenet-registry/src/codegen/Tables.sol";
import { InterfaceVoxel } from "@tenet-utils/src/Types.sol";

contract ClassifierSystem is System {
  function registerClassifier(
    bytes4 classifySelector,
    string memory name,
    string memory description,
    string memory classificationResultTableName,
    InterfaceVoxel[] memory selectorInterface
  ) public {
    bytes32 classifierId = getUniqueEntity();
    validateInterfaceVoxels(selectorInterface);
    ClassifierRegistry.set(
      classifierId,
      ClassifierRegistryData({
        creator: tx.origin,
        classifySelector: classifySelector,
        name: name,
        description: description,
        classificationResultTableName: classificationResultTableName,
        selectorInterface: abi.encode(selectorInterface)
      })
    );
  }

  function validateInterfaceVoxels(InterfaceVoxel[] memory selectorInterface) internal pure {
    for (uint256 i = 0; i < selectorInterface.length; i++) {
      InterfaceVoxel memory interfaceVoxel = selectorInterface[i];
      require(bytes(interfaceVoxel.name).length > 0, "Interface object name cannot be empty");
    }
  }
}
