import { setupMUDV2Network } from "@latticexyz/std-client";
import { createFastTxExecutor, createFaucetService, getSnapSyncRecords } from "@latticexyz/network";
import { getNetworkConfig } from "./getNetworkConfig";
import { defineContractComponents } from "./contractComponents";
import { world } from "./world";
import { Contract, Signer, utils } from "ethers";
import { JsonRpcProvider } from "@ethersproject/providers";
import { IWorld__factory as Level2CAWordl_factory } from "@tenetxyz/level2-ca/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";
import Level2CaStoreConfig from "@tenetxyz/level2-ca/mud.config";
import RegistryStoreConfig from "@tenetxyz/registry/mud.config";

import { getTableIds } from "@latticexyz/utils";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

const USE_WORLD = "registry";

export async function setupNetwork() {
  const contractComponents = defineContractComponents(world);
  const networkConfig = await getNetworkConfig(USE_WORLD);
  networkConfig.showInDevTools = true;

  let storeConfig = undefined;
  let worldFactory = undefined;
  if (USE_WORLD === "level2-ca") {
    storeConfig = Level2CaStoreConfig;
    worldFactory = Level2CAWordl_factory;
  } else if (USE_WORLD === "registry") {
    storeConfig = RegistryStoreConfig;
    worldFactory = RegistryIWorld__factory;
  } else {
    throw new Error("Unknown world");
  }

  const result = await setupMUDV2Network<typeof contractComponents, typeof storeConfig>({
    networkConfig,
    world,
    contractComponents,
    syncThread: "main",
    storeConfig,
    worldAbi: worldFactory.abi,
    useABIInDevTools: true,
  });

  // Request drip from faucet
  const signer = result.network.signer.get();
  if (networkConfig.faucetServiceUrl && signer) {
    const address = await signer.getAddress();
    console.info("[Dev Faucet]: Player address -> ", address);

    const faucet = createFaucetService(networkConfig.faucetServiceUrl);

    const requestDrip = async () => {
      const balance = await signer.getBalance();
      console.info(`[Dev Faucet]: Player balance -> ${balance}`);
      const lowBalance = balance?.lte(utils.parseEther("1"));
      if (lowBalance) {
        console.info("[Dev Faucet]: Balance is low, dripping funds to player");
        // Double drip
        await faucet.dripDev({ address });
        await faucet.dripDev({ address });
      }
    };

    requestDrip();
    // Request a drip every 20 seconds
    setInterval(requestDrip, 20000);
  }

  const provider = result.network.providers.get().json;
  const signerOrProvider = signer ?? provider;
  // Create a World contract instance
  const worldContract = worldFactory.connect(networkConfig.worldAddress, signerOrProvider);

  if (networkConfig.snapSync) {
    const currentBlockNumber = await provider.getBlockNumber();
    const tableRecords = await getSnapSyncRecords(
      networkConfig.worldAddress,
      getTableIds(storeConfig),
      currentBlockNumber,
      signerOrProvider
    );

    console.log(`Syncing ${tableRecords.length} records`);
    result.startSync(tableRecords, currentBlockNumber);
  } else {
    result.startSync();
  }

  // Create a fast tx executor
  const fastTxExecutor =
    signer?.provider instanceof JsonRpcProvider
      ? await createFastTxExecutor(signer as Signer & { provider: JsonRpcProvider })
      : null;

  // TODO: infer this from fastTxExecute signature?
  type BoundFastTxExecuteFn<C extends Contract> = <F extends keyof C>(
    func: F,
    args: Parameters<C[F]>,
    options?: {
      retryCount?: number;
    }
  ) => Promise<ReturnType<C[F]>>;

  function bindFastTxExecute<C extends Contract>(contract: C): BoundFastTxExecuteFn<C> {
    return async function (...args) {
      if (!fastTxExecutor) {
        throw new Error("no signer");
      }
      const { tx } = await fastTxExecutor.fastTxExecute(contract, ...args);
      return await tx;
    };
  }

  return {
    ...result,
    worldContract,
    worldSend: bindFastTxExecute(worldContract),
    fastTxExecutor,
  };
}
