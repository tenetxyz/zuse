// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { InitWorldSystem } from "@tenet-base-world/src/prototypes/InitWorldSystem.sol";
import { REGISTRY_ADDRESS } from "@tenet-world/src/Constants.sol";
import { WorldRegistry } from "@tenet-registry/src/codegen/tables/WorldRegistry.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { CARegistry } from "@tenet-registry/src/codegen/tables/CARegistry.sol";
import { REGISTER_WORLD_SIG } from "@tenet-registry/src/Constants.sol";
import { REGISTRY_ADDRESS, BASE_CA_ADDRESS, LEVEL_2_CA_ADDRESS, LEVEL_3_CA_ADDRESS } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract InitSystem is InitWorldSystem {
  function getRegistryAddress() internal pure override returns (address) {
    return REGISTRY_ADDRESS;
  }

  function registerWorld() public {
    address[] memory caAddresses = new address[](3);
    caAddresses[0] = BASE_CA_ADDRESS;
    caAddresses[1] = LEVEL_2_CA_ADDRESS;
    caAddresses[2] = LEVEL_3_CA_ADDRESS;

    safeCall(
      REGISTRY_ADDRESS,
      abi.encodeWithSignature(REGISTER_WORLD_SIG, "Tenet Base World", "Very fun. Very nice.", caAddresses),
      "registerCA"
    );
  }

  function initWorldVoxelTypes() public override {
    super.initWorldVoxelTypes();
  }

  function onNewCAVoxelType(address caAddress, bytes32 voxelTypeId) public override {
    super.onNewCAVoxelType(caAddress, voxelTypeId);
  }

  function isCAAllowed(address caAddress) public view override returns (bool) {
    return super.isCAAllowed(caAddress);
  }

  function isVoxelTypeAllowed(bytes32 voxelTypeId) public view override returns (bool) {
    return super.isVoxelTypeAllowed(voxelTypeId);
  }
}
