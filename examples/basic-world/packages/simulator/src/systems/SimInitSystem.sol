// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { SimInitSystem as SimInitProtoSystem } from "@tenet-base-simulator/src/systems/SimInitSystem.sol";
import { Mass, MassTableId } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy, EnergyTableId } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { ObjectProperties } from "@tenet-utils/src/Types.sol";

contract SimInitSystem is SimInitProtoSystem {
  function initObject(bytes32 objectEntityId, ObjectProperties memory initialProperties) public override {
    address world = _msgSender();
    require(!hasKey(MassTableId, Mass.encodeKeyTuple(world, objectEntityId)), "Mass for object already initialized");
    require(
      !hasKey(EnergyTableId, Energy.encodeKeyTuple(world, objectEntityId)),
      "Energy for object already initialized"
    );
    Mass.set(world, objectEntityId, initialProperties.mass);
    Energy.set(world, objectEntityId, initialProperties.energy);
  }
}
