import { MUDChain, latticeTestnet } from "@latticexyz/common/chains";
import { foundry } from "@wagmi/chains";

// const defaultRpc = "https://l2-innocent-gold-porpoise-6hdnogky9g.t.conduit.xyz";
// const defaultWs = "wss://l2-innocent-gold-porpoise-6hdnogky9g.t.conduit.xyz
// ";

declare const prodConduitChain: {
  readonly id: 901;
  readonly name: "Foundry";
  readonly network: "foundry";
  readonly nativeCurrency: {
    readonly decimals: 18;
    readonly name: "Ether";
    readonly symbol: "ETH";
  };
  readonly rpcUrls: {
    readonly default: {
      readonly http: readonly ["http://127.0.0.1:8545"];
      readonly webSocket: readonly ["ws://127.0.0.1:8545"];
    };
    readonly public: {
      readonly http: readonly ["http://127.0.0.1:8545"];
      readonly webSocket: readonly ["ws://127.0.0.1:8545"];
    };
  };
};

// If you are deploying to chains other than anvil or Lattice testnet, add them here
// export const supportedChains: MUDChain[] = [foundry, latticeTestnet, prodConduitChain];
export const supportedChains: MUDChain[] = [foundry];
