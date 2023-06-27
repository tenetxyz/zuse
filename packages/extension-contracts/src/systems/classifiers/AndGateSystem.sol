// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { query, QueryFragment, QueryType } from "@latticexyz/world/src/modules/keysintable/query.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { getVoxelCoordStrict } from "../../Utils.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../../codegen/world/IWorld.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { SignalSourceID } from "../../prototypes/Voxels.sol";
import { VoxelCoord } from "@tenetxyz/contracts/src/Types.sol";
import { entityIsPowered, clearCoord, build } from "../../Utils.sol";
import { getCallerNamespace } from "@tenetxyz/contracts/src/SharedUtils.sol";
import { getUniqueEntity } from "@latticexyz/world/src/modules/uniqueentity/getUniqueEntity.sol";

contract AndGateSystem is System {
  bytes32 inEntity1 = keccak256("inEntity1");
  bytes32 inEntity2 = keccak256("inEntity2");

  function classify(bytes memory input, address worldAddress) public {
    (bytes32 in1, bytes32 in2, bytes32 out) = abi.decode(input, (bytes32, bytes32, bytes32));
    VoxelCoord memory in1Coord = getVoxelCoordStrict(in1);
    VoxelCoord memory in2Coord = getVoxelCoordStrict(in2);
    // mine the coord so we can place power sources at it
    clearCoord(worldAddress, in1Coord);
    clearCoord(worldAddress, in2Coord);
    // IWorld(_world()).tenet_MineSystem_mine(SignalSourceID, in1Coord);
    // IWorld(_world()).tenet_MineSystem_mine(SignalSourceID, in2Coord);
    IWorld(_world()).tenet_SignalSourceSyst_getOrCreateSignalSource(inEntity1);
    IWorld(_world()).tenet_SignalSourceSyst_getOrCreateSignalSource(inEntity2);
    simulateLogic(worldAddress, in1Coord, in2Coord, out, 0, 0, 0);
    simulateLogic(worldAddress, in1Coord, in2Coord, out, 1, 0, 0);
    simulateLogic(worldAddress, in1Coord, in2Coord, out, 0, 1, 0);
    simulateLogic(worldAddress, in1Coord, in2Coord, out, 1, 1, 1); // this is the only case where the output is on since both inputs are on
  }

  // the reason why the in/out states are uints is cause 1s and 0s are more readable than true/false
  function simulateLogic(
    address worldAddress,
    VoxelCoord memory in1Coord,
    VoxelCoord memory in2Coord,
    bytes32 out,
    uint8 in1State,
    uint8 in2State,
    uint8 outState
  ) private {
    if (in1State == 1) {
      build(worldAddress, in1Coord, inEntity1);
    }
    if (in2State == 1) {
      build(worldAddress, in2Coord, inEntity2);
    }

    // No need to run the simulation logic since the build function automatically runs the simulation logic
    bytes16 callerNamespace = getCallerNamespace(_msgSender());
    if (outState == 1) {
      require(entityIsPowered(out, callerNamespace), "out voxel must be on");
    } else {
      require(!entityIsPowered(out, callerNamespace), "out voxel cannot be on");
    }
  }
}
