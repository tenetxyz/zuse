import { getBurnerPrivateKey } from "@latticexyz/common";
import worldsJson from "@tenetxyz/contracts/worlds.json";
import registryWorldsJson from "@tenetxyz/registry/worlds.json";
import { supportedChains } from "./supportedChains";
import { tenetTestnet, tenetRelayServiceUrl } from "./tenetTestnet";

const registryWorlds = registryWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;
const worlds = worldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;

export type NetworkConfig = Awaited<ReturnType<typeof getNetworkConfig>>;

export async function getNetworkConfig(isRegistry: boolean) {
  const params = new URLSearchParams(window.location.search);

  const chainId = Number(params.get("chainId") || import.meta.env.VITE_CHAIN_ID || 31337);
  const chainIndex = supportedChains.findIndex((c) => c.id === chainId);
  const chain = supportedChains[chainIndex];
  if (!chain) {
    throw new Error(`Chain ${chainId} not found`);
  }

  const world = isRegistry ? registryWorlds[chain.id.toString()] : worlds[chain.id.toString()];
  const worldAddress = (isRegistry ? params.get("registryAddress") : params.get("worldAddress")) || world?.address;
  if (!worldAddress) {
    throw new Error(`No world address found for chain ${chainId}. Did you run \`mud deploy\`?`);
  }

  const defaultRelay = tenetRelayServiceUrl.includes("undefined") ? undefined : tenetRelayServiceUrl;

  const initialBlockNumber = params.has("initialBlockNumber")
    ? Number(params.get("initialBlockNumber"))
    : world?.blockNumber ?? 0n;

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
    privateKey: getBurnerPrivateKey(),
    chainId,
    chain,
    chainConfig: chain,
    faucetServiceUrl: params.get("faucet") ?? chain.faucetUrl,
    worldAddress,
    initialBlockNumber,
    disableCache: params.get("cache") === "false",
    relayServiceUrl: params.get("relay") ?? defaultRelay,
  };
}
