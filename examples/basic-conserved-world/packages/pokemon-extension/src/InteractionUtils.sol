// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { EnergySource } from "@tenet-pokemon-extension/src/codegen/tables/EnergySource.sol";

function entityIsEnergySource(address callerAddress, bytes32 entity) view returns (bool) {
  return EnergySource.get(callerAddress, entity);
}
