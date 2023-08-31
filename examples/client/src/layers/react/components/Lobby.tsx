import { useEffect, useState } from "react";
import { WorldRegistry, WorldRegistryFilters } from "./WorldRegistry";
import { defineContractComponents as defineRegistryContractComponents } from "@tenetxyz/registry/client/contractComponents";
import { getNetworkConfig } from "@/mud/getNetworkConfig";
import registryStoreConfig from "@tenetxyz/registry/mud.config";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";
import { Layers } from "@/types";

type Props = {
  layers: Layers;
};
export function Lobby({ layers }: Props) {
  const [worldRegistryFilters, setWorldRegistryFilters] = useState<WorldRegistryFilters>({
    query: "",
  });
  return (
    // we need a high z-index so we can render this component on top of the noa canvas (this is a hack since we are rendering the world before we even know what world to load from the user!)
    <div className="z-50 relative bg-black h-50 w-full flex justify-center items-center" style={{ height: "100vh" }}>
      <img
        src="/img/loading-background.jpeg"
        className="z-10"
        style={{ opacity: 0.5, width: "100%", height: "100%", position: "absolute", objectFit: "cover" }}
        draggable={false}
      />
      <div className="flex flex-col">
        <div className="font-inter z-20 text-9xl opacity-100 text-white w-full h-full font-bold text-center mb-5">
          EVERLON
        </div>
        <div
          className="z-20 text-white"
          style={{
            padding: "4px 2px",
            // border: "0.5px solid #C9CACB",
            borderRadius: "4px",
            marginTop: "8px",
            backgroundColor: "#ffffff12",
            backdropFilter: "blur(2px)",
          }}
        >
          <WorldRegistry layers={layers} filters={worldRegistryFilters} setFilters={setWorldRegistryFilters} />
        </div>
      </div>
    </div>
  );
}
