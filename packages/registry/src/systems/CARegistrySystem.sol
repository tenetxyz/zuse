// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { CARegistry, CARegistryTableId, CARegistryData, BodyTypeRegistry, BodyTypeRegistryTableId, WorldRegistry, WorldRegistryTableId } from "../codegen/Tables.sol";
import { getKeysInTable } from "@latticexyz/world/src/modules/keysintable/getKeysInTable.sol";
import { WORLD_NOTIFY_NEW_CA_BODY_TYPE_SIG } from "../Constants.sol";
import { safeCall } from "@tenet-utils/src/CallUtils.sol";

contract CARegistrySystem is System {
  // TODO: How do we know this CA is using these body types?
  function registerCA(string memory name, string memory description, bytes32[] memory bodyTypeIds) public {
    require(bytes(name).length > 0, "Name cannot be empty");
    require(bytes(description).length > 0, "Description cannot be empty");
    require(bodyTypeIds.length > 0, "Must have at least one body type");

    address caAddress = _msgSender();

    uint32 scale = 0;
    for (uint256 i; i < bodyTypeIds.length; i++) {
      require(
        hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(bodyTypeIds[i])),
        "Body type ID has not been registered"
      );
      if (scale == 0) {
        scale = BodyTypeRegistry.getScale(bodyTypeIds[i]);
      } else {
        require(scale == BodyTypeRegistry.getScale(bodyTypeIds[i]), "All body types must be the same scale");
      }
    }

    require(!hasKey(CARegistryTableId, CARegistry.encodeKeyTuple(caAddress)), "CA has already been registered");

    CARegistry.set(
      caAddress,
      CARegistryData({
        name: name,
        description: description,
        creator: tx.origin,
        scale: scale,
        bodyTypeIds: bodyTypeIds
      })
    );
  }

  function addBodyToCA(bytes32 bodyTypeId) public {
    address caAddress = _msgSender();
    require(hasKey(CARegistryTableId, CARegistry.encodeKeyTuple(caAddress)), "CA has not been registered");
    require(
      hasKey(BodyTypeRegistryTableId, BodyTypeRegistry.encodeKeyTuple(bodyTypeId)),
      "Body type ID has not been registered"
    );

    CARegistryData memory caData = CARegistry.get(caAddress);
    require(caData.scale == BodyTypeRegistry.getScale(bodyTypeId), "Body type must be the same scale as the CA");

    bytes32[] memory bodyTypeIds = caData.bodyTypeIds;
    for (uint256 i = 0; i < bodyTypeIds.length; i++) {
      if (bodyTypeIds[i] == bodyTypeId) {
        revert("Body type has already been added to CA");
      }
    }

    bytes32[] memory updatedBodyTypeIds = new bytes32[](bodyTypeIds.length + 1);
    for (uint256 i = 0; i < bodyTypeIds.length; i++) {
      updatedBodyTypeIds[i] = bodyTypeIds[i];
    }
    updatedBodyTypeIds[bodyTypeIds.length] = bodyTypeId;

    CARegistry.setBodyTypeIds(caAddress, updatedBodyTypeIds);

    // Notify worlds using this CA that a new body type has been added
    bytes32[][] memory worlds = getKeysInTable(WorldRegistryTableId);
    for (uint256 i = 0; i < worlds.length; i++) {
      address world = address(uint160(uint256(worlds[i][0])));
      address[] memory worldCAs = WorldRegistry.getCaAddresses(world);
      for (uint256 j = 0; j < worldCAs.length; j++) {
        if (worldCAs[j] == caAddress) {
          safeCall(
            world,
            abi.encodeWithSignature(WORLD_NOTIFY_NEW_CA_BODY_TYPE_SIG, caAddress, bodyTypeId),
            "addBodyToCA"
          );
        }
      }
    }
  }
}
