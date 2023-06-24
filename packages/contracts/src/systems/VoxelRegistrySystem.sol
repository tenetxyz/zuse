// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { NamespaceOwner } from "@latticexyz/world/src/tables/NamespaceOwner.sol";
import { FunctionSelectors } from "@latticexyz/world/src/modules/core/tables/FunctionSelectors.sol";
import {VoxelTypeRegistry, VoxelTypeRegistryTableId, VoxelVariants, VoxelVariantsData, VoxelVariantsTableId} from "../codegen/Tables.sol";
import { IWorld } from "../codegen/world/IWorld.sol";
import {NoaBlockType} from "../codegen/Types.sol";
import { getCallerNamespace } from "../utils.sol";
import { VoxelVariantsKey } from "../types.sol";

contract VoxelRegistrySystem is System {

    function airVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
        return VoxelVariantsKey({
            namespace: bytes16("tenet"),
            voxelVariantId: bytes32(keccak256("air"))
        });
    }

    function dirtVariantSelector(bytes32 entity) public returns (VoxelVariantsKey memory) {
         return VoxelVariantsKey({
            namespace: bytes16("tenet"),
            voxelVariantId: bytes32(keccak256("dirt"))
        });
    }

    function registerVoxelType(bytes32 voxelType, bytes4 voxelVariantSelector) public {
        (bytes16 namespace, , ) = FunctionSelectors.get(voxelVariantSelector);
        // TODO: Dhvani add back
        // require(NamespaceOwner.get(namespace) == _msgSender(), "Caller is not namespace owner");

        // check if voxel type is already registered
        bytes32[] memory keyTuple = new bytes32[](2);
        keyTuple[0] = bytes32((namespace));
        keyTuple[1] = voxelType;

        require(!hasKey(VoxelTypeRegistryTableId, keyTuple), "Voxel type already registered for this namespace");

        // TODO: We should add some signature check for voxelVariantSelector to make sure it returns the right type
        // that the client needs to render the voxel
        // should return the type expected by VoxelType (ie VoxelTypeData struct)

        // register voxel type
        VoxelTypeRegistry.set(namespace, voxelType, voxelVariantSelector);
    }

    function registerVoxelVariant(bytes32 voxelVariantId, VoxelVariantsData memory voxelVariant) public {
        // get caller's namespace
        bytes16 callerNamespace = getCallerNamespace(_msgSender());

        // check if voxel type is already registered
        bytes32[] memory keyTuple = new bytes32[](2);
        keyTuple[0] = bytes32((callerNamespace));
        keyTuple[1] = voxelVariantId;

        require(!hasKey(VoxelVariantsTableId, keyTuple), "Voxel variant already registered for this namespace");

        // TODO: Keep track of voxelVariantId counter and increment as more are added

        VoxelVariants.set(callerNamespace, voxelVariantId, voxelVariant);
    }

}