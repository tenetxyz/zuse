// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { Position, VoxelType, VoxelTypeData } from "@tenet-contracts/src/codegen/Tables.sol";
import { safeCall } from "@tenet-contracts/src/Utils.sol";

contract ActivateSystem is System {
  function activate(bytes32 entity) public returns (bytes32) {
    require(Position.has(entity), "The entity must be placed in the world");

    //     struct VoxelTypeData {
    //   bytes16 voxelTypeNamespace;
    //   bytes32 voxelTypeId;
    //   bytes16 voxelVariantNamespace;
    //   bytes32 voxelVariantId;
    // }
    VoxelTypeData memory voxelType = VoxelType.get(entity);
    VoxelRegistry.get();
    // get the corresponding voxel type
    // get the activate selector

    safeCall(
      worldAddress,
      abi.encodeWithSignature(
        "tenet_RegClassifierSys_registerClassifier(bytes4,string,string,string)",
        classifySelector,
        classifierName,
        classifierDescription,
        classificationResultTableName
      ),
      string(abi.encode("register classifier: ", classifierName))
    );
  }
}
