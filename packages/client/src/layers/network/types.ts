// import { VoxelTypeKey } from "./constants";
// import { createNetworkLayer } from "./createNetworkLayer";
import { SetupNetworkResult } from "../../mud/setupNetwork";

// export type NetworkLayer = Awaited<ReturnType<typeof SetupNetworkResult>>;
export type NetworkLayer = SetupNetworkResult;

// export type Structure = (
//   | typeof VoxelTypeKeyToId[VoxelTypeKey]
//   | undefined
// )[][][];

export type PluginRegistrySpec = {
  source: string;
  plugins: string[];
};
