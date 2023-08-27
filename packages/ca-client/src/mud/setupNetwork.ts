import { createPublicClient, fallback, webSocket, http, createWalletClient, Hex, parseEther, ClientConfig } from "viem";
import { createFaucetService } from "@latticexyz/services/faucet";
import { encodeEntity, syncToRecs } from "@latticexyz/store-sync/recs";
import { getNetworkConfig } from "./getNetworkConfig";
import { world } from "./world";
import { createBurnerAccount, createContract, transportObserver, ContractWrite } from "@latticexyz/common";
import { Subject, share } from "rxjs";
import { defaultAbiCoder as abi } from "ethers/lib/utils";
import { IWorld__factory as BaseCAWordl_factory } from "@tenetxyz/base-ca/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as Level2CAWordl_factory } from "@tenetxyz/level2-ca/types/ethers-contracts/factories/IWorld__factory";
import { IWorld__factory as RegistryIWorld__factory } from "@tenetxyz/registry/types/ethers-contracts/factories/IWorld__factory";
import BaseCaStoreConfig from "@tenetxyz/base-ca/mud.config";
import Level2CaStoreConfig from "@tenetxyz/level2-ca/mud.config";
import RegistryStoreConfig from "@tenetxyz/registry/mud.config";

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>;

export async function setupNetwork() {
  const worldId = "level2-ca";
  const networkConfig = await getNetworkConfig(worldId);

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

  const encodedVoxelSelectorsType = "(bytes4,bytes4,bytes4,bytes4,bytes4,(bytes4,string,string)[])";
  const encodedVoxelSelectorBytes =
    "0x000000000000000000000000000000000000000000000000000000000000002098d9e45600000000000000000000000000000000000000000000000000000000b1bd6251000000000000000000000000000000000000000000000000000000005e01311800000000000000000000000000000000000000000000000000000000c4e5cde700000000000000000000000000000000000000000000000000000000c4f994920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000207c9a524700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000c4d6f766520466f727761726400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  const encodedMindType = "(address,string,string,bytes4)[]";
  const encodedMindBytes =
    "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000003c44cdddb6a900fa2b585dd299e03d12fa4293bc000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0a303e6be0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000074669676874657200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c46696768746572204d696e640000000000000000000000000000000000000000";
  const decodedData = abi.decode([encodedVoxelSelectorsType], encodedVoxelSelectorBytes)[0];
  console.log("decodedData");
  console.log(decodedData);

  const clientOptions = {
    chain: networkConfig.chain,
    transport: transportObserver(fallback([webSocket(), http()])),
    pollingInterval: 1000,
  } as const satisfies ClientConfig;

  const publicClient = createPublicClient(clientOptions);

  const burnerAccount = createBurnerAccount(networkConfig.privateKey as Hex);
  const burnerWalletClient = createWalletClient({
    ...clientOptions,
    account: burnerAccount,
  });

  const write$ = new Subject<ContractWrite>();
  const worldContract = createContract({
    address: networkConfig.worldAddress as Hex,
    abi: worldFactory.abi,
    publicClient,
    walletClient: burnerWalletClient,
    onWrite: (write) => write$.next(write),
  });

  const { components, latestBlock$, blockStorageOperations$, waitForTransaction } = await syncToRecs({
    world,
    config: storeConfig,
    address: networkConfig.worldAddress as Hex,
    publicClient,
    startBlock: BigInt(networkConfig.initialBlockNumber),
  });

  // Request drip from faucet
  if (networkConfig.faucetServiceUrl) {
    const address = burnerAccount.address;
    console.info("[Dev Faucet]: Player address -> ", address);

    const faucet = createFaucetService(networkConfig.faucetServiceUrl);

    const requestDrip = async () => {
      const balance = await publicClient.getBalance({ address });
      console.info(`[Dev Faucet]: Player balance -> ${balance}`);
      const lowBalance = balance < parseEther("1");
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

  return {
    world,
    components,
    playerEntity: encodeEntity({ address: "address" }, { address: burnerWalletClient.account.address }),
    publicClient,
    walletClient: burnerWalletClient,
    latestBlock$,
    blockStorageOperations$,
    waitForTransaction,
    worldContract,
    write$: write$.asObservable().pipe(share()),
    worldId,
  };
}
