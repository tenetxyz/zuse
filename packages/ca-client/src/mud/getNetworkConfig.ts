import { SetupContractConfig, getBurnerWallet } from "@latticexyz/std-client";
import baseCAWorldsJson from "@tenetxyz/base-ca/worlds.json";
import level2CAWorldsJson from "@tenetxyz/level2-ca/worlds.json";
import registryWorldsJson from "@tenetxyz/registry/worlds.json";
import { supportedChains } from "./supportedChains";

const baseCAWorlds = baseCAWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;
const level2CAWorlds = level2CAWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;
const registryCAWorlds = registryWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;

type NetworkConfig = SetupContractConfig & {
  privateKey: string;
  faucetServiceUrl?: string;
  snapSync?: boolean;
};

export async function getNetworkConfig(worldId: string): Promise<NetworkConfig> {
  const params = new URLSearchParams(window.location.search);

  const chainId = Number(params.get("chainId") || import.meta.env.VITE_CHAIN_ID || 31337);
  const chainIndex = supportedChains.findIndex((c) => c.id === chainId);
  const chain = supportedChains[chainIndex];
  if (!chain) {
    throw new Error(`Chain ${chainId} not found`);
  }

  let world = undefined;
  if (worldId === "base-ca") {
    world = baseCAWorlds[chain.id.toString()];
  } else if (worldId === "level2-ca") {
    world = level2CAWorlds[chain.id.toString()];
  } else if (worldId === "registry") {
    world = registryCAWorlds[chain.id.toString()];
  } else {
    throw new Error(`Unknown world ${worldId}`);
  }

  const worldAddress = params.get("worldAddress") || world?.address;
  if (!worldAddress) {
    throw new Error(`No world address found for chain ${chainId}. Did you run \`mud deploy\`?`);
  }

  const initialBlockNumber = params.has("initialBlockNumber")
    ? Number(params.get("initialBlockNumber"))
    : world?.blockNumber ?? -1; // -1 will attempt to find the block number from RPC

  return {
    clock: {
      period: 1000,
      initialTime: 0,
      syncInterval: 5000,
    },
    provider: {
      chainId,
      jsonRpcUrl: params.get("rpc") ?? chain.rpcUrls.default.http[0],
      wsRpcUrl: params.get("wsRpc") ?? chain.rpcUrls.default.webSocket?.[0],
    },
    privateKey: getBurnerWallet().value,
    chainId,
    modeUrl: params.get("mode") ?? chain.modeUrl,
    faucetServiceUrl: params.get("faucet") ?? chain.faucetUrl,
    worldAddress,
    initialBlockNumber,
    snapSync: params.get("snapSync") === "true",
    disableCache: params.get("cache") === "false",
  };
}
