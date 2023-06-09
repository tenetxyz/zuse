import { VoxelTypeKeyToId } from "./constants";
// import { createNetworkLayer } from "./createNetworkLayer";
import { SetupNetworkResult } from "../../mud/setupNetwork";

// export type NetworkLayer = Awaited<ReturnType<typeof SetupNetworkResult>>;
export type NetworkLayer = SetupNetworkResult;

export type Structure = (
  | typeof VoxelTypeKeyToId[keyof typeof VoxelTypeKeyToId]
  | undefined
)[][][];

export type PluginRegistrySpec = {
  source: string;
  plugins: string[];
};
