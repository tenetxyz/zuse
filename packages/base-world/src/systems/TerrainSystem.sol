// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

import { Position, PositionData } from "@tenet-base-world/src/codegen/tables/Position.sol";
import { ObjectEntity } from "@tenet-base-world/src/codegen/tables/ObjectEntity.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";

abstract contract TerrainSystem is System {
  function getSimulatorAddress() internal pure virtual returns (address);

  function emptyObjectId() internal pure virtual returns (bytes32);

  function getTerrainObjectTypeId(VoxelCoord memory coord) public view virtual returns (bytes32);

  function getTerrainObjectProperties(
    ObjectProperties memory requestedProperties
  ) public virtual returns (ObjectProperties memory);
}
