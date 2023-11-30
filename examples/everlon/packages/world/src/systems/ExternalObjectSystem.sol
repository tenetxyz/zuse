// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { hasKey } from "@latticexyz/world/src/modules/keysintable/hasKey.sol";
import { ExternalObjectSystem as ExternalObjectProtoSystem } from "@tenet-base-world/src/systems/ExternalObjectSystem.sol";

import { SIMULATOR_ADDRESS } from "@tenet-world/src/Constants.sol";
import { VoxelCoord, ObjectProperties } from "@tenet-utils/src/Types.sol";
import { Mass } from "@tenet-simulator/src/codegen/tables/Mass.sol";
import { Energy } from "@tenet-simulator/src/codegen/tables/Energy.sol";
import { Velocity } from "@tenet-simulator/src/codegen/tables/Velocity.sol";
import { Health } from "@tenet-simulator/src/codegen/tables/Health.sol";
import { Stamina } from "@tenet-simulator/src/codegen/tables/Stamina.sol";
import { Element } from "@tenet-simulator/src/codegen/tables/Element.sol";
import { CombatMove } from "@tenet-simulator/src/codegen/tables/CombatMove.sol";
import { Nutrients } from "@tenet-simulator/src/codegen/tables/Nutrients.sol";
import { Nitrogen, NitrogenTableId } from "@tenet-simulator/src/codegen/tables/Nitrogen.sol";
import { Phosphorus, PhosphorusTableId } from "@tenet-simulator/src/codegen/tables/Phosphorus.sol";
import { Potassium, PotassiumTableId } from "@tenet-simulator/src/codegen/tables/Potassium.sol";
import { Elixir } from "@tenet-simulator/src/codegen/tables/Elixir.sol";
import { Protein } from "@tenet-simulator/src/codegen/tables/Protein.sol";
import { Temperature } from "@tenet-simulator/src/codegen/tables/Temperature.sol";

contract ExternalObjectSystem is ExternalObjectProtoSystem {
  function getSimulatorAddress() internal pure override returns (address) {
    return SIMULATOR_ADDRESS;
  }

  function getObjectProperties(bytes32 objectEntityId) public view override returns (ObjectProperties memory) {
    IStore store = IStore(getSimulatorAddress());
    address worldAddress = _world();
    ObjectProperties memory objectProperties;

    objectProperties.mass = Mass.get(store, worldAddress, objectEntityId);
    objectProperties.energy = Energy.get(store, worldAddress, objectEntityId);
    objectProperties.velocity = Velocity.getVelocity(store, worldAddress, objectEntityId);
    objectProperties.lastUpdateBlock = Velocity.getLastUpdateBlock(store, worldAddress, objectEntityId);
    objectProperties.health = Health.getHealth(store, worldAddress, objectEntityId);
    objectProperties.stamina = Stamina.get(store, worldAddress, objectEntityId);
    objectProperties.elementType = Element.get(store, worldAddress, objectEntityId);
    objectProperties.combatMoveData = CombatMove.get(store, worldAddress, objectEntityId);
    objectProperties.nutrients = Nutrients.get(store, worldAddress, objectEntityId);
    objectProperties.nitrogen = Nitrogen.get(store, worldAddress, objectEntityId);
    objectProperties.hasNitrogen = hasKey(
      store,
      NitrogenTableId,
      Nitrogen.encodeKeyTuple(worldAddress, objectEntityId)
    );
    objectProperties.phosphorus = Phosphorus.get(store, worldAddress, objectEntityId);
    objectProperties.hasPhosphorus = hasKey(
      store,
      PhosphorusTableId,
      Phosphorus.encodeKeyTuple(worldAddress, objectEntityId)
    );
    objectProperties.potassium = Potassium.get(store, worldAddress, objectEntityId);
    objectProperties.hasPotassium = hasKey(
      store,
      PotassiumTableId,
      Potassium.encodeKeyTuple(worldAddress, objectEntityId)
    );
    objectProperties.elixir = Elixir.get(store, worldAddress, objectEntityId);
    objectProperties.protein = Protein.get(store, worldAddress, objectEntityId);
    objectProperties.temperature = Temperature.get(store, worldAddress, objectEntityId);

    return objectProperties;
  }
}
