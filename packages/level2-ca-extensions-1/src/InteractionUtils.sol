// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Signal, SignalData, SignalSource, Powered, InvertedSignal, Temperature, Generator, PowerWire, Storage, Consumer, PowerSignal } from "@tenet-level2-ca-extensions-1/src/codegen/Tables.sol";

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
