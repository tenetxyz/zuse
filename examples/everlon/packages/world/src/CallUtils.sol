// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { VoxelCoord } from "@tenet-utils/src/Types.sol";
import { callOrRevert } from "@tenet-utils/src/CallUtils.sol";
import { WORLD_CLAIM_SHARD_SIG } from "@tenet-world/src/Constants.sol";

function claimShard(
  address worldAddress,
  VoxelCoord memory coordInShard,
  address contractAddress,
  bytes4 objectTypeIdSelector,
  bytes4 objectPropertiesSelector,
  VoxelCoord memory faucetAgentCoord
) {
  callOrRevert(
    worldAddress,
    abi.encodeWithSignature(
      WORLD_CLAIM_SHARD_SIG,
      coordInShard,
      contractAddress,
      objectTypeIdSelector,
      objectPropertiesSelector,
      faucetAgentCoord
    ),
    "claimShard"
  );
}
