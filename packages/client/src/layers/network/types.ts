import { BlockType } from "./constants";
// import { createNetworkLayer } from "./createNetworkLayer";
import { SetupNetworkResult } from "../../mud/setupNetwork";

// export type NetworkLayer = Awaited<ReturnType<typeof SetupNetworkResult>>;
export type NetworkLayer = SetupNetworkResult;

export type Structure = (typeof BlockType[keyof typeof BlockType] | undefined)[][][];

export type PluginRegistrySpec = {
  source: string;
  plugins: string[];
};
