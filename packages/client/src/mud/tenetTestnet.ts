import { MUDChain } from "@latticexyz/common/chains";

// The reason why we need to have our own custom testnet is because
// when ppl connect to our faucet service, they will connect to the right URL
// we can't use "localhost" because when the user goes on our website, localhost is THEIR computer, not our AWS instance running the node
const nodeHost = import.meta.env.VITE_PROD_HOST;

export const tenetRelayServiceUrl = `http://${nodeHost}:50072`;

export const tenetTestnet = {
  name: "Tenet Testnet",
  id: 905,
  network: "tenet-testnet",
  nativeCurrency: { decimals: 18, name: "Ether", symbol: "ETH" },
  rpcUrls: {
    default: {
      http: [`http://${nodeHost}:8545`],
      webSocket: [`ws://${nodeHost}:8545`],
    },
    public: {
      http: [`http://${nodeHost}:8545`],
      webSocket: [`ws://${nodeHost}:8545`],
    },
  },
  blockExplorers: {
    otterscan: {
      name: "Explorer L2",
      url: "",
    },
    default: {
      name: "Explorer L2",
      url: "",
    },
  },
  modeUrl: `http://${nodeHost}:1111`, // TODO: fix
  faucetUrl: `http://${nodeHost}:50082`,
} as const satisfies MUDChain;
