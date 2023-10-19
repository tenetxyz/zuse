// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IWorld } from "@tenet-pokemon-extension/src/codegen/world/IWorld.sol";
import { getEntitySimData } from "@tenet-level1-ca/src/Utils.sol";
import { BodySimData } from "@tenet-utils/src/Types.sol";
import { registerMindIntoRegistry, getSelector } from "@tenet-registry/src/Utils.sol";
import { REGISTRY_ADDRESS, GrassPokemonVoxelID } from "@tenet-pokemon-extension/src/Constants.sol";
import { MindType } from "@tenet-base-ca/src/prototypes/MindType.sol";

contract GrassMindSystem is MindType {
  function registerMind() public {
    registerMindIntoRegistry(
      REGISTRY_ADDRESS,
      GrassPokemonVoxelID,
      "grass Mind",
      "grass desc",
      IWorld(_world()).pokemon_GrassMindSystem_mindLogic.selector
    );
  }

  function mindLogic(
    bytes32 voxelTypeId,
    bytes32 entity,
    bytes32[] memory neighbourEntityIds,
    bytes32[] memory childEntityIds,
    bytes32 parentEntity
  ) public override returns (bytes4) {
    // These are the decision rules that the mind uses
    bytes4[] memory decisionRuleSelectors = new bytes4[](1);
    decisionRuleSelectors[0] = bytes4(0x99e4bb11);

    for (uint8 i = 0; i < neighbourEntityIds.length; i++) {
      bytes32 targetEntityId = neighbourEntityIds[i];
      if (targetEntityId == bytes32(0)) {
        continue;
      }

      // This mind will use the first decision rule it has that can handle a neighbour entity
      // so if there is a match in the rules, we return the interactionSelector right away!
      for (uint8 j = 0; j < decisionRuleSelectors.length; j++) {
        bytes4 decisionRuleSelector = decisionRuleSelectors[j];

        bytes4 useInteractionSelector = decideAction(entity, targetEntityId);
        if (useInteractionSelector != bytes4(0)) {
          // console.log("runningmind selector");
          // console.logBytes4(useInteractionSelector);
          return useInteractionSelector;
        }
      }
    }
    // console.log("couldn't find mind selector");

    // we couldn't find a decision rule that could handle the neighbour entity. So return no action
    return bytes4(0);
  }

  function decideAction(bytes32 myBody, bytes32 theirBody) public returns (bytes4) {
    BodySimData memory myBodySimData = getEntitySimData(myBody);

    // get all the component values for my body
    uint256 myBodyhealth = myBodySimData.health;
    // get all the component values for their body

    // the branching logic that decides which action to take
    if (0 <= myBodyhealth && myBodyhealth <= 500) {
      if (true) {
        return 0x712c7ea0;
      }
    } else if (501 <= myBodyhealth && myBodyhealth <= 1000) {
      if (true) {
        return 0x712c7ea0;
      }
    }

    // The decision rule couldn't decide what to do. So select no interaction rule
    return 0x00000000;
  }
}
