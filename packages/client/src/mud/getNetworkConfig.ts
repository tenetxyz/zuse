import { SetupContractConfig, getBurnerWallet } from "@latticexyz/std-client";
import worldsJson from "@tenetxyz/contracts/worlds.json";
import registryWorldsJson from "@tenetxyz/registry/worlds.json";
import { supportedChains } from "./supportedChains";
import { tenetTestnet, tenetRelayServiceUrl } from "./tenetTestnet";
import { createClock } from "@latticexyz/network";

const registryWorlds = registryWorldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;
const worlds = worldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;

type NetworkConfig = SetupContractConfig & {
  privateKey: string;
  faucetServiceUrl?: string;
  snapSync?: boolean;
  relayServiceUrl?: string;
};

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

  // const clock = createClock({
  //   period: 1000,
  //   initialTime: 0,
  //   syncInterval: 5000,
  // });
  // world?.registerDisposer(() => clock.dispose());
  // latestBlock$
  // .pipe(
  //   map((block) => Number(block.timestamp) * 1000), // Map to timestamp in ms
  //   filter((blockTimestamp) => blockTimestamp !== clock.lastUpdateTime), // Ignore if the clock was already refreshed with this block
  //   filter((blockTimestamp) => blockTimestamp !== clock.currentTime) // Ignore if the current local timestamp is correct
  // )
  // .subscribe(clock.update); // Update the local clock

  return {
    provider: {
      chainId,
      jsonRpcUrl: params.get("rpc") ?? chain.rpcUrls.default.http[0],
      wsRpcUrl: params.get("wsRpc") ?? chain.rpcUrls.default.webSocket?.[0],
    },
    privateKey: getBurnerWallet().value,
    chain,
    chainId,
    chainConfig: chain,
    // modeUrl: params.get("mode") ?? chain.modeUrl,
    faucetServiceUrl: params.get("faucet") ?? chain.faucetUrl,
    worldAddress,
    initialBlockNumber,
    snapSync: params.get("snapSync") === "false" ? false : true,
    disableCache: params.get("cache") === "false",
    relayServiceUrl: params.get("relay") ?? defaultRelay,
  };
}
