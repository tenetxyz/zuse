import { tenetMudConfig } from "@tenetxyz/base-world";
import { resolveTableId } from "@latticexyz/config";

export default tenetMudConfig({
  tables: {
    OwnedBy: {
      keySchema: {
        scale: "uint32",
        entity: "bytes32",
      },
      schema: {
        player: "address",
      },
    },
  },
  systems: {
    RunCASystem: {
      name: "RunCASystem",
      openAccess: false,
      accessList: ["BuildSystem", "MineSystem", "ActivateSystem", "MoveSystem"],
    },
  },
  modules: [
    {
      name: "KeysInTableModule",
      root: true,
      args: [resolveTableId("OwnedBy")],
    },
  ],
});
