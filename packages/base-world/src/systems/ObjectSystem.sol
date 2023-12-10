// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-base-world/src/codegen/world/IWorld.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";
import { getEnterWorldSelector, getExitWorldSelector } from "@tenet-registry/src/Utils.sol";

abstract contract ObjectSystem is System {
  function getRegistryAddress() internal pure virtual returns (address);

  function decodeToObjectProperties(bytes memory data) external pure returns (ObjectProperties memory) {
    return abi.decode(data, (ObjectProperties));
  }

  function enterWorld(
    bytes32 objectTypeId,
    VoxelCoord memory coord,
    bytes32 objectEntityId
  ) public virtual returns (ObjectProperties memory requestedProperties) {
    (address objectAddress, bytes4 objectEnterWorldSelector) = getEnterWorldSelector(
      IStore(getRegistryAddress()),
      objectTypeId
    );
    require(
      objectAddress != address(0) && objectEnterWorldSelector != bytes4(0),
      "ObjectSystem: Object enterWorld not defined"
    );

    (bool enterWorldSuccess, bytes memory enterWorldReturnData) = safeCall(
      objectAddress,
      abi.encodeWithSelector(objectEnterWorldSelector, objectEntityId, coord),
      "object enter world"
    );
    if (enterWorldSuccess) {
      try this.decodeToObjectProperties(enterWorldReturnData) returns (ObjectProperties memory decodedValue) {
        requestedProperties = decodedValue;
      } catch {}
    }

    return requestedProperties;
  }

  function exitWorld(bytes32 objectTypeId, VoxelCoord memory coord, bytes32 objectEntityId) public virtual {
    (address objectAddress, bytes4 objectExitWorldSelector) = getEnterWorldSelector(
      IStore(getRegistryAddress()),
      objectTypeId
    );
    require(
      objectAddress != address(0) && objectExitWorldSelector != bytes4(0),
      "ObjectSystem: Object exitWorld not defined"
    );

    (bool exitWorldSuccess, bytes memory exitWorldReturnData) = safeCall(
      objectAddress,
      abi.encodeWithSelector(objectExitWorldSelector, objectEntityId, coord),
      "object exit world"
    );
  }
}
