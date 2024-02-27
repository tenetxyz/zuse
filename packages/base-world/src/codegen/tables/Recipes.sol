// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("Recipes")));
bytes32 constant RecipesTableId = _tableId;

struct RecipesData {
  bytes32[] inputObjectTypeIds;
  uint8[] inputObjectTypeAmounts;
  bytes32[] outputObjectTypeIds;
  uint8[] outputObjectTypeAmounts;
  bytes outputObjectProperties;
}

library Recipes {
  /** Get the table's key schema */
  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.BYTES32;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's value schema */
  function getValueSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](5);
    _schema[0] = SchemaType.BYTES32_ARRAY;
    _schema[1] = SchemaType.UINT8_ARRAY;
    _schema[2] = SchemaType.BYTES32_ARRAY;
    _schema[3] = SchemaType.UINT8_ARRAY;
    _schema[4] = SchemaType.BYTES;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's key names */
  function getKeyNames() internal pure returns (string[] memory keyNames) {
    keyNames = new string[](1);
    keyNames[0] = "recipeId";
  }

  /** Get the table's field names */
  function getFieldNames() internal pure returns (string[] memory fieldNames) {
    fieldNames = new string[](5);
    fieldNames[0] = "inputObjectTypeIds";
    fieldNames[1] = "inputObjectTypeAmounts";
    fieldNames[2] = "outputObjectTypeIds";
    fieldNames[3] = "outputObjectTypeAmounts";
    fieldNames[4] = "outputObjectProperties";
  }

  /** Register the table's key schema, value schema, key names and value names */
  function register() internal {
    StoreSwitch.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Register the table's key schema, value schema, key names and value names (using the specified store) */
  function register(IStore _store) internal {
    _store.registerTable(_tableId, getKeySchema(), getValueSchema(), getKeyNames(), getFieldNames());
  }

  /** Get inputObjectTypeIds */
  function getInputObjectTypeIds(bytes32 recipeId) internal view returns (bytes32[] memory inputObjectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Get inputObjectTypeIds (using the specified store) */
  function getInputObjectTypeIds(
    IStore _store,
    bytes32 recipeId
  ) internal view returns (bytes32[] memory inputObjectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 0, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Set inputObjectTypeIds */
  function setInputObjectTypeIds(bytes32 recipeId, bytes32[] memory inputObjectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setField(_tableId, _keyTuple, 0, EncodeArray.encode((inputObjectTypeIds)), getValueSchema());
  }

  /** Set inputObjectTypeIds (using the specified store) */
  function setInputObjectTypeIds(IStore _store, bytes32 recipeId, bytes32[] memory inputObjectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.setField(_tableId, _keyTuple, 0, EncodeArray.encode((inputObjectTypeIds)), getValueSchema());
  }

  /** Get the length of inputObjectTypeIds */
  function lengthInputObjectTypeIds(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 0, getValueSchema());
    unchecked {
      return _byteLength / 32;
    }
  }

  /** Get the length of inputObjectTypeIds (using the specified store) */
  function lengthInputObjectTypeIds(IStore _store, bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 0, getValueSchema());
    unchecked {
      return _byteLength / 32;
    }
  }

  /**
   * Get an item of inputObjectTypeIds
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemInputObjectTypeIds(bytes32 recipeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        0,
        getValueSchema(),
        _index * 32,
        (_index + 1) * 32
      );
      return (Bytes.slice32(_blob, 0));
    }
  }

  /**
   * Get an item of inputObjectTypeIds (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemInputObjectTypeIds(IStore _store, bytes32 recipeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(
        _tableId,
        _keyTuple,
        0,
        getValueSchema(),
        _index * 32,
        (_index + 1) * 32
      );
      return (Bytes.slice32(_blob, 0));
    }
  }

  /** Push an element to inputObjectTypeIds */
  function pushInputObjectTypeIds(bytes32 recipeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 0, abi.encodePacked((_element)), getValueSchema());
  }

  /** Push an element to inputObjectTypeIds (using the specified store) */
  function pushInputObjectTypeIds(IStore _store, bytes32 recipeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.pushToField(_tableId, _keyTuple, 0, abi.encodePacked((_element)), getValueSchema());
  }

  /** Pop an element from inputObjectTypeIds */
  function popInputObjectTypeIds(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 0, 32, getValueSchema());
  }

  /** Pop an element from inputObjectTypeIds (using the specified store) */
  function popInputObjectTypeIds(IStore _store, bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.popFromField(_tableId, _keyTuple, 0, 32, getValueSchema());
  }

  /**
   * Update an element of inputObjectTypeIds at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateInputObjectTypeIds(bytes32 recipeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 0, _index * 32, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /**
   * Update an element of inputObjectTypeIds (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateInputObjectTypeIds(IStore _store, bytes32 recipeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 0, _index * 32, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /** Get inputObjectTypeAmounts */
  function getInputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint8[] memory inputObjectTypeAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /** Get inputObjectTypeAmounts (using the specified store) */
  function getInputObjectTypeAmounts(
    IStore _store,
    bytes32 recipeId
  ) internal view returns (uint8[] memory inputObjectTypeAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 1, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /** Set inputObjectTypeAmounts */
  function setInputObjectTypeAmounts(bytes32 recipeId, uint8[] memory inputObjectTypeAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setField(_tableId, _keyTuple, 1, EncodeArray.encode((inputObjectTypeAmounts)), getValueSchema());
  }

  /** Set inputObjectTypeAmounts (using the specified store) */
  function setInputObjectTypeAmounts(IStore _store, bytes32 recipeId, uint8[] memory inputObjectTypeAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.setField(_tableId, _keyTuple, 1, EncodeArray.encode((inputObjectTypeAmounts)), getValueSchema());
  }

  /** Get the length of inputObjectTypeAmounts */
  function lengthInputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 1, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of inputObjectTypeAmounts (using the specified store) */
  function lengthInputObjectTypeAmounts(IStore _store, bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 1, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of inputObjectTypeAmounts
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemInputObjectTypeAmounts(bytes32 recipeId, uint256 _index) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        1,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (uint8(Bytes.slice1(_blob, 0)));
    }
  }

  /**
   * Get an item of inputObjectTypeAmounts (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemInputObjectTypeAmounts(
    IStore _store,
    bytes32 recipeId,
    uint256 _index
  ) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 1, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (uint8(Bytes.slice1(_blob, 0)));
    }
  }

  /** Push an element to inputObjectTypeAmounts */
  function pushInputObjectTypeAmounts(bytes32 recipeId, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 1, abi.encodePacked((_element)), getValueSchema());
  }

  /** Push an element to inputObjectTypeAmounts (using the specified store) */
  function pushInputObjectTypeAmounts(IStore _store, bytes32 recipeId, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.pushToField(_tableId, _keyTuple, 1, abi.encodePacked((_element)), getValueSchema());
  }

  /** Pop an element from inputObjectTypeAmounts */
  function popInputObjectTypeAmounts(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 1, 1, getValueSchema());
  }

  /** Pop an element from inputObjectTypeAmounts (using the specified store) */
  function popInputObjectTypeAmounts(IStore _store, bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.popFromField(_tableId, _keyTuple, 1, 1, getValueSchema());
  }

  /**
   * Update an element of inputObjectTypeAmounts at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateInputObjectTypeAmounts(bytes32 recipeId, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 1, _index * 1, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /**
   * Update an element of inputObjectTypeAmounts (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateInputObjectTypeAmounts(IStore _store, bytes32 recipeId, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 1, _index * 1, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /** Get outputObjectTypeIds */
  function getOutputObjectTypeIds(bytes32 recipeId) internal view returns (bytes32[] memory outputObjectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Get outputObjectTypeIds (using the specified store) */
  function getOutputObjectTypeIds(
    IStore _store,
    bytes32 recipeId
  ) internal view returns (bytes32[] memory outputObjectTypeIds) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 2, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_bytes32());
  }

  /** Set outputObjectTypeIds */
  function setOutputObjectTypeIds(bytes32 recipeId, bytes32[] memory outputObjectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setField(_tableId, _keyTuple, 2, EncodeArray.encode((outputObjectTypeIds)), getValueSchema());
  }

  /** Set outputObjectTypeIds (using the specified store) */
  function setOutputObjectTypeIds(IStore _store, bytes32 recipeId, bytes32[] memory outputObjectTypeIds) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.setField(_tableId, _keyTuple, 2, EncodeArray.encode((outputObjectTypeIds)), getValueSchema());
  }

  /** Get the length of outputObjectTypeIds */
  function lengthOutputObjectTypeIds(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 2, getValueSchema());
    unchecked {
      return _byteLength / 32;
    }
  }

  /** Get the length of outputObjectTypeIds (using the specified store) */
  function lengthOutputObjectTypeIds(IStore _store, bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 2, getValueSchema());
    unchecked {
      return _byteLength / 32;
    }
  }

  /**
   * Get an item of outputObjectTypeIds
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemOutputObjectTypeIds(bytes32 recipeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        2,
        getValueSchema(),
        _index * 32,
        (_index + 1) * 32
      );
      return (Bytes.slice32(_blob, 0));
    }
  }

  /**
   * Get an item of outputObjectTypeIds (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemOutputObjectTypeIds(IStore _store, bytes32 recipeId, uint256 _index) internal view returns (bytes32) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(
        _tableId,
        _keyTuple,
        2,
        getValueSchema(),
        _index * 32,
        (_index + 1) * 32
      );
      return (Bytes.slice32(_blob, 0));
    }
  }

  /** Push an element to outputObjectTypeIds */
  function pushOutputObjectTypeIds(bytes32 recipeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 2, abi.encodePacked((_element)), getValueSchema());
  }

  /** Push an element to outputObjectTypeIds (using the specified store) */
  function pushOutputObjectTypeIds(IStore _store, bytes32 recipeId, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.pushToField(_tableId, _keyTuple, 2, abi.encodePacked((_element)), getValueSchema());
  }

  /** Pop an element from outputObjectTypeIds */
  function popOutputObjectTypeIds(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 2, 32, getValueSchema());
  }

  /** Pop an element from outputObjectTypeIds (using the specified store) */
  function popOutputObjectTypeIds(IStore _store, bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.popFromField(_tableId, _keyTuple, 2, 32, getValueSchema());
  }

  /**
   * Update an element of outputObjectTypeIds at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateOutputObjectTypeIds(bytes32 recipeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 2, _index * 32, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /**
   * Update an element of outputObjectTypeIds (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateOutputObjectTypeIds(IStore _store, bytes32 recipeId, uint256 _index, bytes32 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 2, _index * 32, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /** Get outputObjectTypeAmounts */
  function getOutputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint8[] memory outputObjectTypeAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /** Get outputObjectTypeAmounts (using the specified store) */
  function getOutputObjectTypeAmounts(
    IStore _store,
    bytes32 recipeId
  ) internal view returns (uint8[] memory outputObjectTypeAmounts) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 3, getValueSchema());
    return (SliceLib.getSubslice(_blob, 0, _blob.length).decodeArray_uint8());
  }

  /** Set outputObjectTypeAmounts */
  function setOutputObjectTypeAmounts(bytes32 recipeId, uint8[] memory outputObjectTypeAmounts) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setField(_tableId, _keyTuple, 3, EncodeArray.encode((outputObjectTypeAmounts)), getValueSchema());
  }

  /** Set outputObjectTypeAmounts (using the specified store) */
  function setOutputObjectTypeAmounts(
    IStore _store,
    bytes32 recipeId,
    uint8[] memory outputObjectTypeAmounts
  ) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.setField(_tableId, _keyTuple, 3, EncodeArray.encode((outputObjectTypeAmounts)), getValueSchema());
  }

  /** Get the length of outputObjectTypeAmounts */
  function lengthOutputObjectTypeAmounts(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of outputObjectTypeAmounts (using the specified store) */
  function lengthOutputObjectTypeAmounts(IStore _store, bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 3, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of outputObjectTypeAmounts
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemOutputObjectTypeAmounts(bytes32 recipeId, uint256 _index) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        3,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (uint8(Bytes.slice1(_blob, 0)));
    }
  }

  /**
   * Get an item of outputObjectTypeAmounts (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemOutputObjectTypeAmounts(
    IStore _store,
    bytes32 recipeId,
    uint256 _index
  ) internal view returns (uint8) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 3, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (uint8(Bytes.slice1(_blob, 0)));
    }
  }

  /** Push an element to outputObjectTypeAmounts */
  function pushOutputObjectTypeAmounts(bytes32 recipeId, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 3, abi.encodePacked((_element)), getValueSchema());
  }

  /** Push an element to outputObjectTypeAmounts (using the specified store) */
  function pushOutputObjectTypeAmounts(IStore _store, bytes32 recipeId, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.pushToField(_tableId, _keyTuple, 3, abi.encodePacked((_element)), getValueSchema());
  }

  /** Pop an element from outputObjectTypeAmounts */
  function popOutputObjectTypeAmounts(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /** Pop an element from outputObjectTypeAmounts (using the specified store) */
  function popOutputObjectTypeAmounts(IStore _store, bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.popFromField(_tableId, _keyTuple, 3, 1, getValueSchema());
  }

  /**
   * Update an element of outputObjectTypeAmounts at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateOutputObjectTypeAmounts(bytes32 recipeId, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 3, _index * 1, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /**
   * Update an element of outputObjectTypeAmounts (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateOutputObjectTypeAmounts(IStore _store, bytes32 recipeId, uint256 _index, uint8 _element) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 3, _index * 1, abi.encodePacked((_element)), getValueSchema());
    }
  }

  /** Get outputObjectProperties */
  function getOutputObjectProperties(bytes32 recipeId) internal view returns (bytes memory outputObjectProperties) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 4, getValueSchema());
    return (bytes(_blob));
  }

  /** Get outputObjectProperties (using the specified store) */
  function getOutputObjectProperties(
    IStore _store,
    bytes32 recipeId
  ) internal view returns (bytes memory outputObjectProperties) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = _store.getField(_tableId, _keyTuple, 4, getValueSchema());
    return (bytes(_blob));
  }

  /** Set outputObjectProperties */
  function setOutputObjectProperties(bytes32 recipeId, bytes memory outputObjectProperties) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setField(_tableId, _keyTuple, 4, bytes((outputObjectProperties)), getValueSchema());
  }

  /** Set outputObjectProperties (using the specified store) */
  function setOutputObjectProperties(IStore _store, bytes32 recipeId, bytes memory outputObjectProperties) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.setField(_tableId, _keyTuple, 4, bytes((outputObjectProperties)), getValueSchema());
  }

  /** Get the length of outputObjectProperties */
  function lengthOutputObjectProperties(bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = StoreSwitch.getFieldLength(_tableId, _keyTuple, 4, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /** Get the length of outputObjectProperties (using the specified store) */
  function lengthOutputObjectProperties(IStore _store, bytes32 recipeId) internal view returns (uint256) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    uint256 _byteLength = _store.getFieldLength(_tableId, _keyTuple, 4, getValueSchema());
    unchecked {
      return _byteLength / 1;
    }
  }

  /**
   * Get an item of outputObjectProperties
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemOutputObjectProperties(bytes32 recipeId, uint256 _index) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = StoreSwitch.getFieldSlice(
        _tableId,
        _keyTuple,
        4,
        getValueSchema(),
        _index * 1,
        (_index + 1) * 1
      );
      return (bytes(_blob));
    }
  }

  /**
   * Get an item of outputObjectProperties (using the specified store)
   * (unchecked, returns invalid data if index overflows)
   */
  function getItemOutputObjectProperties(
    IStore _store,
    bytes32 recipeId,
    uint256 _index
  ) internal view returns (bytes memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      bytes memory _blob = _store.getFieldSlice(_tableId, _keyTuple, 4, getValueSchema(), _index * 1, (_index + 1) * 1);
      return (bytes(_blob));
    }
  }

  /** Push a slice to outputObjectProperties */
  function pushOutputObjectProperties(bytes32 recipeId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.pushToField(_tableId, _keyTuple, 4, bytes((_slice)), getValueSchema());
  }

  /** Push a slice to outputObjectProperties (using the specified store) */
  function pushOutputObjectProperties(IStore _store, bytes32 recipeId, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.pushToField(_tableId, _keyTuple, 4, bytes((_slice)), getValueSchema());
  }

  /** Pop a slice from outputObjectProperties */
  function popOutputObjectProperties(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.popFromField(_tableId, _keyTuple, 4, 1, getValueSchema());
  }

  /** Pop a slice from outputObjectProperties (using the specified store) */
  function popOutputObjectProperties(IStore _store, bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.popFromField(_tableId, _keyTuple, 4, 1, getValueSchema());
  }

  /**
   * Update a slice of outputObjectProperties at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateOutputObjectProperties(bytes32 recipeId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      StoreSwitch.updateInField(_tableId, _keyTuple, 4, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /**
   * Update a slice of outputObjectProperties (using the specified store) at `_index`
   * (checked only to prevent modifying other tables; can corrupt own data if index overflows)
   */
  function updateOutputObjectProperties(IStore _store, bytes32 recipeId, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    unchecked {
      _store.updateInField(_tableId, _keyTuple, 4, _index * 1, bytes((_slice)), getValueSchema());
    }
  }

  /** Get the full data */
  function get(bytes32 recipeId) internal view returns (RecipesData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, bytes32 recipeId) internal view returns (RecipesData memory _table) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    bytes memory _blob = _store.getRecord(_tableId, _keyTuple, getValueSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(
    bytes32 recipeId,
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts,
    bytes32[] memory outputObjectTypeIds,
    uint8[] memory outputObjectTypeAmounts,
    bytes memory outputObjectProperties
  ) internal {
    bytes memory _data = encode(
      inputObjectTypeIds,
      inputObjectTypeAmounts,
      outputObjectTypeIds,
      outputObjectTypeAmounts,
      outputObjectProperties
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    bytes32 recipeId,
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts,
    bytes32[] memory outputObjectTypeIds,
    uint8[] memory outputObjectTypeAmounts,
    bytes memory outputObjectProperties
  ) internal {
    bytes memory _data = encode(
      inputObjectTypeIds,
      inputObjectTypeAmounts,
      outputObjectTypeIds,
      outputObjectTypeAmounts,
      outputObjectProperties
    );

    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.setRecord(_tableId, _keyTuple, _data, getValueSchema());
  }

  /** Set the full data using the data struct */
  function set(bytes32 recipeId, RecipesData memory _table) internal {
    set(
      recipeId,
      _table.inputObjectTypeIds,
      _table.inputObjectTypeAmounts,
      _table.outputObjectTypeIds,
      _table.outputObjectTypeAmounts,
      _table.outputObjectProperties
    );
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, bytes32 recipeId, RecipesData memory _table) internal {
    set(
      _store,
      recipeId,
      _table.inputObjectTypeIds,
      _table.inputObjectTypeAmounts,
      _table.outputObjectTypeIds,
      _table.outputObjectTypeAmounts,
      _table.outputObjectProperties
    );
  }

  /**
   * Decode the tightly packed blob using this table's schema.
   * Undefined behaviour for invalid blobs.
   */
  function decode(bytes memory _blob) internal pure returns (RecipesData memory _table) {
    // 0 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 0));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 0) {
      // skip static data length + dynamic lengths word
      uint256 _start = 32;
      uint256 _end;
      unchecked {
        _end = 32 + _encodedLengths.atIndex(0);
      }
      _table.inputObjectTypeIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_bytes32());

      _start = _end;
      unchecked {
        _end += _encodedLengths.atIndex(1);
      }
      _table.inputObjectTypeAmounts = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint8());

      _start = _end;
      unchecked {
        _end += _encodedLengths.atIndex(2);
      }
      _table.outputObjectTypeIds = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_bytes32());

      _start = _end;
      unchecked {
        _end += _encodedLengths.atIndex(3);
      }
      _table.outputObjectTypeAmounts = (SliceLib.getSubslice(_blob, _start, _end).decodeArray_uint8());

      _start = _end;
      unchecked {
        _end += _encodedLengths.atIndex(4);
      }
      _table.outputObjectProperties = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    bytes32[] memory inputObjectTypeIds,
    uint8[] memory inputObjectTypeAmounts,
    bytes32[] memory outputObjectTypeIds,
    uint8[] memory outputObjectTypeAmounts,
    bytes memory outputObjectProperties
  ) internal pure returns (bytes memory) {
    PackedCounter _encodedLengths;
    // Lengths are effectively checked during copy by 2**40 bytes exceeding gas limits
    unchecked {
      _encodedLengths = PackedCounterLib.pack(
        inputObjectTypeIds.length * 32,
        inputObjectTypeAmounts.length * 1,
        outputObjectTypeIds.length * 32,
        outputObjectTypeAmounts.length * 1,
        bytes(outputObjectProperties).length
      );
    }

    return
      abi.encodePacked(
        _encodedLengths.unwrap(),
        EncodeArray.encode((inputObjectTypeIds)),
        EncodeArray.encode((inputObjectTypeAmounts)),
        EncodeArray.encode((outputObjectTypeIds)),
        EncodeArray.encode((outputObjectTypeAmounts)),
        bytes((outputObjectProperties))
      );
  }

  /** Encode keys as a bytes32 array using this table's schema */
  function encodeKeyTuple(bytes32 recipeId) internal pure returns (bytes32[] memory) {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    return _keyTuple;
  }

  /* Delete all data for given keys */
  function deleteRecord(bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    StoreSwitch.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, bytes32 recipeId) internal {
    bytes32[] memory _keyTuple = new bytes32[](1);
    _keyTuple[0] = recipeId;

    _store.deleteRecord(_tableId, _keyTuple, getValueSchema());
  }
}