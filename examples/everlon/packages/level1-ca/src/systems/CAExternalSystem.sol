// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { CAExternal } from "@tenet-base-ca/src/prototypes/CAExternal.sol";

contract CAExternalSystem is CAExternal {
  function getMindSelector(bytes32 entity) public view override returns (bytes4) {
    return super.getMindSelector(entity);
  }

  function setMindSelector(bytes32 entity, bytes4 mindSelector) public override {
    super.setMindSelector(entity, mindSelector);
  }
}
