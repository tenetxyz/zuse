import { SetupNetworkResult } from "./setupNetwork";
import { defineComponent, Type as RecsType } from "@latticexyz/recs";
import { world } from "./world";

export type ClientComponents = ReturnType<typeof createClientComponents>;

export function createClientComponents({ components }: SetupNetworkResult) {
  console.log("Starting createClientComponents");
  return {
    ...components,
    // add your client components or overrides here,
    // TODO: Uncomment once we support plugins
    // Plugin: createLocalCache(definePluginComponent(world), uniqueWorldId),
    // PluginRegistry: createLocalCache(definePluginRegistryComponent(world), uniqueWorldId),
  };
}
