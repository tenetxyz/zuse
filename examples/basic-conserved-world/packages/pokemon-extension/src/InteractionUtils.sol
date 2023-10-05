// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Soil } from "@tenet-pokemon-extension/src/codegen/tables/Soil.sol";
import { Plant } from "@tenet-pokemon-extension/src/codegen/tables/Plant.sol";
import { Pokemon } from "@tenet-pokemon-extension/src/codegen/tables/Pokemon.sol";

function entityIsSoil(address callerAddress, bytes32 entity) view returns (bool) {
  return Soil.getHasValue(callerAddress, entity);
}

function entityIsPlant(address callerAddress, bytes32 entity) view returns (bool) {
  return Plant.getHasValue(callerAddress, entity);
}

function entityIsPokemon(address callerAddress, bytes32 entity) view returns (bool) {
  return Pokemon.getHasValue(callerAddress, entity);
}
