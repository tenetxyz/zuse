// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import { Signal, SignalData, SignalSource } from "@tenet-level2-ca/src/codegen/Tables.sol";

function entityIsSignal(address callerAddress, bytes32 entity) view returns (bool) {
  return Signal.get(callerAddress, entity).hasValue;
}

function entityIsActiveSignal(address callerAddress, bytes32 entity) view returns (bool) {
  SignalData memory signalData = Signal.get(callerAddress, entity);
  return signalData.hasValue && signalData.isActive;
}

function entityIsInactiveSignal(address callerAddress, bytes32 entity) view returns (bool) {
  SignalData memory signalData = Signal.get(callerAddress, entity);
  return signalData.hasValue && !signalData.isActive;
}

function entityIsSignalSource(address callerAddress, bytes32 entity) view returns (bool) {
  return SignalSource.get(callerAddress, entity).hasValue;
}
