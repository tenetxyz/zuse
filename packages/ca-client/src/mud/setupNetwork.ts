import { setupMUDV2Network } from "@latticexyz/std-client";
import { createFastTxExecutor, createFaucetService, getSnapSyncRecords } from "@latticexyz/network";
import { getNetworkConfig } from "./getNetworkConfig";
import { defineContractComponents } from "./contractComponents";
import { world } from "./world";
import { Contract, Signer, utils } from "ethers";
import { JsonRpcProvider } from "@ethersproject/providers";
import { defaultAbiCoder as abi } from "ethers/lib/utils";
import { IWorld__factory as BaseCAWordl_factory } from "@tenetxyz/base-ca/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as Level2CAWordl_factory } from "@tenetxyz/level2-ca/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";
import BaseCaStoreConfig from "@tenetxyz/base-ca/mud.config";
import Level2CaStoreConfig from "@tenetxyz/level2-ca/mud.config";
import RegistryStoreConfig from "@tenetxyz/registry/mud.config";

import { getTableIds } from "@latticexyz/utils";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

export async function setupNetwork() {
  const worldId = "level2-ca";
  const contractComponents = defineContractComponents(world);
  const networkConfig = await getNetworkConfig(worldId);
  networkConfig.showInDevTools = true;

  let storeConfig = undefined;
  let worldFactory = undefined;
  if (worldId === "base-ca") {
    storeConfig = BaseCaStoreConfig;
    worldFactory = BaseCAWordl_factory;
  } else if (worldId === "level2-ca") {
    storeConfig = Level2CaStoreConfig;
    worldFactory = Level2CAWordl_factory;
  } else if (worldId === "registry") {
    storeConfig = RegistryStoreConfig;
    worldFactory = RegistryIWorld__factory;
  } else {
    throw new Error("Unknown world");
  }

  const encodedVoxelSelectorsType = "(bytes4,bytes4,bytes4,bytes4,(bytes4,string,string)[])";
  const encodedVoxelSelectorBytes =
    "0x000000000000000000000000000000000000000000000000000000000000002098d9e45600000000000000000000000000000000000000000000000000000000b1bd6251000000000000000000000000000000000000000000000000000000005e01311800000000000000000000000000000000000000000000000000000000c4e5cde70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020fd50185600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000744656661756c74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  const encodedMindType = "(address,string,string,bytes4)[]";
  const encodedMindBytes =
    "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000003c44cdddb6a900fa2b585dd299e03d12fa4293bc000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0a303e6be0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074669676874657200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c46696768746572204d696e640000000000000000000000000000000000000000";
  const decodedData = abi.decode([encodedMindType], encodedMindBytes)[0];
  console.log("decodedData");
  console.log(decodedData);

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
    worldId,
  };
}
