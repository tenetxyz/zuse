import { mudConfig } from "@latticexyz/world/register";
import { resolveTableId } from "@latticexyz/config";

const KeysInTableModule_ADDRESS = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

export default mudConfig({
  namespace: "extension",
  tables: {
    TwoDirtCR: {
      // TwoDirt classify result - The key is the creationId
      schema: {
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        blockNumber: "uint256", // the blockNumber when the creation passed the classifier
        displayText: "string",
      },
    },
    AndGateCR: {
      // AndGate classify result - The key is the creationId
      schema: {
        hasValue: "bool", // TODO: Remove this once we can install non-root modules
        blockNumber: "uint256", // the blockNumber when the creation passed the classifier
        displayText: "string",
        voxelInterfaces: "bytes",
      },
    },
  },
  modules: [
    // TODO: Re-enable when we have a way to install non-root modules
    // {
    //   name: "KeysInTableModule",
    //   address: KeysInTableModule_ADDRESS,
    //   root: true,
    //   args: [resolveTableId("Signal")],
    // },
  ],
});
