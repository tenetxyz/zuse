import { getBurnerPrivateKey } from "@latticexyz/common";
import baseCAWorldsJson from "@tenetxyz/base-ca/worlds.json";
import level2CAWorldsJson from "@tenetxyz/level2-ca/worlds.json";
import registryWorldsJson from "@tenetxyz/registry/worlds.json";
import { supportedChains } from "./supportedChains";

const baseCAWorlds = baseCAWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;
const level2CAWorlds = level2CAWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;
const registryCAWorlds = registryWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;

export async function getNetworkConfig(worldId: string) {
  const params = new URLSearchParams(window.location.search);
  const chainId = Number(params.get("chainId") || params.get("chainid") || import.meta.env.VITE_CHAIN_ID || 31337);
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
    : world?.blockNumber ?? 0n;

  return {
    privateKey: getBurnerPrivateKey(),
    chainId,
    chain,
    faucetServiceUrl: params.get("faucet") ?? chain.faucetUrl,
    worldAddress,
    initialBlockNumber,
  };
}
