// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Signal, SignalData, SignalSource, Powered, InvertedSignal } from "@tenet-level2-ca/src/codegen/Tables.sol";

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

// function entityHasTemperature(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
//   return Temperature.get(callerNamespace, entity).hasValue;
// }

// function entityIsGenerator(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
//   return Generator.get(callerNamespace, entity).hasValue;
// }

// function entityIsPowerWire(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
//   return PowerWire.get(callerNamespace, entity).hasValue;
// }

// function entityIsStorage(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
//   return Storage.get(callerNamespace, entity).hasValue;
// }

// function entityIsConsumer(bytes32 entity, bytes16 callerNamespace) view returns (bool) {
//   return Consumer.get(callerNamespace, entity).hasValue;
// }
