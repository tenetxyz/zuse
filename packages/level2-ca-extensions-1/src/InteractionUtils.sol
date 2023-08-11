// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Signal, SignalData } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Signal.sol";
import { SignalSource } from "@tenet-level2-ca-extensions-1/src/codegen/tables/SignalSource.sol";
import { Powered } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Powered.sol";
import { InvertedSignal } from "@tenet-level2-ca-extensions-1/src/codegen/tables/InvertedSignal.sol";
import { Temperature } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Temperature.sol";
import { Generator } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Generator.sol";
import { PowerWire } from "@tenet-level2-ca-extensions-1/src/codegen/tables/PowerWire.sol";
import { Storage } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Storage.sol";
import { Consumer } from "@tenet-level2-ca-extensions-1/src/codegen/tables/Consumer.sol";
import { PowerSignal } from "@tenet-level2-ca-extensions-1/src/codegen/tables/PowerSignal.sol";

function entityIsSignal(address callerAddress, bytes32 entity) view returns (bool) {
  return Signal.get(callerAddress, entity).hasValue;
}

function entityIsSignalSource(address callerAddress, bytes32 entity) view returns (bool) {
  return SignalSource.get(callerAddress, entity).hasValue;
}

function entityIsPowered(address callerAddress, bytes32 entity) view returns (bool) {
  return Powered.get(callerAddress, entity).hasValue;
}

function entityIsInvertedSignal(address callerAddress, bytes32 entity) view returns (bool) {
  return InvertedSignal.get(callerAddress, entity).hasValue;
}

function entityHasTemperature(address callerAddress, bytes32 entity) view returns (bool) {
  return Temperature.get(callerAddress, entity).hasValue;
}

function entityIsGenerator(address callerAddress, bytes32 entity) view returns (bool) {
  return Generator.get(callerAddress, entity).hasValue;
}

function entityIsPowerWire(address callerAddress, bytes32 entity) view returns (bool) {
  return PowerWire.get(callerAddress, entity).hasValue;
}

function entityIsStorage(address callerAddress, bytes32 entity) view returns (bool) {
  return Storage.get(callerAddress, entity).hasValue;
}

function entityIsConsumer(address callerAddress, bytes32 entity) view returns (bool) {
  return Consumer.get(callerAddress, entity).hasValue;
}

function entityIsPowerSignal(address callerAddress, bytes32 entity) view returns (bool) {
  return PowerSignal.get(callerAddress, entity).hasValue;
}
