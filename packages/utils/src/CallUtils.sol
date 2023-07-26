// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

function safeStaticCallFunctionSelector(
  address world,
  bytes4 functionPointer,
  bytes memory args
) returns (bytes memory) {
  return safeStaticCall(world, bytes.concat(functionPointer, args), "staticcall function selector");
}

enum CallType {
  Call,
  StaticCall,
  DelegateCall
}

// bubbles up a revert reason string if the call fails
function safeGenericCall(
  CallType callType,
  address target,
  bytes memory callData,
  string memory functionName
) returns (bytes memory) {
  bool success;
  bytes memory returnData;

  if (callType == CallType.Call) {
    (success, returnData) = target.call(callData);
  } else if (callType == CallType.StaticCall) {
    (success, returnData) = target.staticcall(callData);
  } else if (callType == CallType.DelegateCall) {
    (success, returnData) = target.delegatecall(callData);
  }

  if (!success) {
    // if there is a return reason string
    if (returnData.length > 0) {
      // bubble up any reason for revert
      assembly {
        let returnDataSize := mload(returnData)
        revert(add(32, returnData), returnDataSize)
      }
    } else {
      string memory revertMsg = string(
        abi.encodePacked(functionName, " call reverted. Maybe the params aren't right?")
      );
      revert(revertMsg);
    }
  }

  return returnData;
}

function safeCall(address target, bytes memory callData, string memory functionName) returns (bytes memory) {
  return safeGenericCall(CallType.Call, target, callData, functionName);
}

function safeStaticCall(address target, bytes memory callData, string memory functionName) returns (bytes memory) {
  return safeGenericCall(CallType.StaticCall, target, callData, functionName);
}

function safeDelegateCall(address target, bytes memory callData, string memory functionName) returns (bytes memory) {
  return safeGenericCall(CallType.DelegateCall, target, callData, functionName);
}
