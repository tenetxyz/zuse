import { useEffect, useState } from "react";
import { WorldRegistry, WorldRegistryFilters } from "./WorldRegistry";
import { createWorld } from "@latticexyz/recs";
import { defineContractComponents as defineRegistryContractComponents } from "@tenetxyz/registry/client/contractComponents";
import { getNetworkConfig } from "@/mud/getNetworkConfig";
import { setupMUDV2Network } from "@latticexyz/std-client";
import registryStoreConfig from "@tenetxyz/registry/mud.config";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";

export function lobby() {
  const [contractComponents, setContractComponents] = useState<any>(null);
  const giveComponentsAHumanReadableId = (contractComponents: any) => {
    Object.entries(contractComponents).forEach(([name, component]) => {
      (component as any).id = name;
    });
  };

  const setupWorldRegistryNetwork = async () => {
    const params = new URLSearchParams(window.location.search);
    const registryWorld = createWorld();
    const contractComponents = defineRegistryContractComponents(registryWorld);
    giveComponentsAHumanReadableId(contractComponents);

    const networkConfig = await getNetworkConfig(true);
    networkConfig.showInDevTools = false;

    const result = await setupMUDV2Network<typeof contractComponents, typeof registryStoreConfig>({
      networkConfig,
      world: registryWorld,
      contractComponents,
      syncThread: "main", // PERF: sync using workers
      storeConfig: registryStoreConfig,
      worldAbi: RegistryIWorld__factory.abi,
      useABIInDevTools: false,
    });
    result.startSync();
    return contractComponents;
  };

  useEffect(() => {
    const contractComponents = setupWorldRegistryNetwork();
    setContractComponents(contractComponents);
  }, []);

  const [worldRegistryFilters, setWorldRegistryFilters] = useState<WorldRegistryFilters>({
    query: "",
  });
  return (
    <WorldRegistry
      layers={{
        network: {
          registryComponents: contractComponents,
        },
      }}
      filters={worldRegistryFilters}
      setFilters={setWorldRegistryFilters}
    />
  );
}
