import { SetupContractConfig, getBurnerWallet } from "@latticexyz/std-client";
import worldsJson from "@tenetxyz/contracts/worlds.json";
import { supportedChains } from "./supportedChains";
import { tenetTestnet, tenetRelayServiceUrl } from "./tenetTestnet";

const worlds = worldsJson as Partial<Record<string, { address: string; blockNumber?: number }>>;

type NetworkConfig = SetupContractConfig & {
  privateKey: string;
  faucetServiceUrl?: string;
  snapSync?: boolean;
  relayServiceUrl?: string;
};

export async function getNetworkConfig(): Promise<NetworkConfig> {
  const params = new URLSearchParams(window.location.search);

  const chainConfig = tenetTestnet;
  const chainId = chainConfig["id"];
  const chain = chainConfig;
  if (!chain) {
    throw new Error(`Chain not found`);
  }

  const world = worlds[chain.id.toString()];
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
    chainConfig,
    modeUrl: params.get("mode") ?? chain.modeUrl,
    faucetServiceUrl: params.get("faucet") ?? chain.faucetUrl,
    worldAddress,
    initialBlockNumber,
    snapSync: params.get("snapSync") === "true",
    disableCache: params.get("cache") === "false",
    relayServiceUrl: params.get("relay") ?? tenetRelayServiceUrl,
  };
}
