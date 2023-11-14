require("dotenv").config();
const { ethers } = require("ethers");
const fs = require("fs");
const { keccak256, toHex } = require("viem");

const chainId = process.env.NODE_ENV === "production" ? 1337 : 31337;
const rpcUrl = process.env.NODE_ENV === "production" ? "https://test-grid.everlon.xyz" : "http://127.0.0.1:8545";

const a = require("../../../../packages/registry/dist/types/ethers-contracts/factories/IWorld__factory.js");
const Registry__factory = a.IWorld__factory;
const b = require("../level1-ca/dist/types/ethers-contracts/factories/IWorld__factory.js");
const CA__factory = b.IWorld__factory;

function keccak256Str(str) {
  return keccak256(toHex(str));
}

const GEN_VOXEL_VARIANT_IDS_BLACKLIST = new Set([
  "air",
  "grass",
  "dirt",
  "bedrock",
  "stone",
  "soil-protein",
  "soil-elixir",
  "soil-concentrative",
  "soil-diffusive",
  "plant-flower",
  "plant-protein",
  "plant-elixir",
  "plant-seed",
  "faucet",
  "builder",
  "runner",
  "farmer",
  "pokemon-fire",
  "pokemon-water",
  "pokemon-grass",
  "thermo-cold",
  "thermo-hot",
]);

function snakeToCamel(str) {
  return str.replace(/(_\w)/g, (matches) => matches[1].toUpperCase());
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

const PRETTY_VOXEL_MASS = 7;

const GEN_VARIANTS_PATH = "../../../../../biomes-client/src/shared/indexer/gen/variants.json";

async function main() {
  // Load the private key from the .env file
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    throw new Error("Missing PRIVATE_KEY in .env file");
  }

  // Load the world address from worlds.json file
  const registryWorldsJsonPath = "../../../../packages/registry/worlds.json";
  const registryWorldsJson = JSON.parse(fs.readFileSync(registryWorldsJsonPath, "utf8"));
  const registryWorldAddress = registryWorldsJson[chainId].address;
  if (!registryWorldAddress) {
    throw new Error("Missing registry worldAddress in worlds.json file");
  }

  const caWorldsJsonPath = "../level1-ca/worlds.json";
  const caWorldsJson = JSON.parse(fs.readFileSync(caWorldsJsonPath, "utf8"));
  const caWorldAddress = caWorldsJson[chainId].address;
  if (!caWorldAddress) {
    throw new Error("Missing ca worldAddress in worlds.json file");
  }

  // Connect to the Ethereum network
  const provider = new ethers.providers.JsonRpcProvider(rpcUrl);

  // Create a wallet instance with a private key and connect it to the network
  const wallet = new ethers.Wallet(privateKey, provider);
  console.log("Using wallet", wallet.address);

  // Create a typed contract instance
  console.log("Registry World address:", registryWorldAddress);
  const registryWorldContract = Registry__factory.connect(registryWorldAddress, wallet);
  const caWorldContract = CA__factory.connect(caWorldAddress, wallet);

  const currentVoxelMapping = new Map();
  const variantsData = fs.readFileSync(GEN_VARIANTS_PATH, "utf8");
  const rawVoxelMapping = JSON.parse(variantsData);
  for (const [key, value] of Object.entries(rawVoxelMapping)) {
    currentVoxelMapping.set(key, value);
  }

  let nonce = await provider.getTransactionCount(wallet.address);

  const txOptions = {
    gasLimit: BigInt(1_900_000_000),
    // maxPriorityFeePerGas: 2000000000,
    // maxFeePerGas: 100000000000,
    nonce: nonce - 1
};

  // Go through currentVoxelMapping and batch generate postdeploy scripts registering them
  let allTx = [];
  for (const [rawVoxelTypeId, variantData] of currentVoxelMapping) {
    if (GEN_VOXEL_VARIANT_IDS_BLACKLIST.has(rawVoxelTypeId)) {
      continue;
    }

    const voxelTypeId = snakeToCamel(rawVoxelTypeId);
    const capitalizedVoxelTypeId = capitalize(voxelTypeId);
    // make voxelTypeDisplayName a spaced out version of the voxelTypeId with each word capitalized
    const voxelTypeDisplayName = capitalizedVoxelTypeId.replace(/([A-Z])/g, " $1").trim();
    const hashedVoxelTypeId = keccak256Str(rawVoxelTypeId);
    console.log("Registering", voxelTypeId, voxelTypeDisplayName);

    // Call setTerrainProperties
    txOptions.nonce += 1;
    let tx = await registryWorldContract.registerVoxelVariant(hashedVoxelTypeId, {
      variantId: 0,
      frames: 0,
      opaque: false,
      fluid: false,
      solid: false,
      blockType: 0,
      materials: "0x",
      uvWrap: "",
    }, txOptions);
    // let receipt = await tx.wait();
    // console.log(tx.hash);
    allTx.push(tx.hash);

    // Wait for the transaction to be mined
    // console.log(`Transaction mined: ${receipt.transactionHash}`);

    txOptions.nonce += 1;
    tx = await registryWorldContract.registerVoxelType(
      voxelTypeDisplayName,
      hashedVoxelTypeId,
      hashedVoxelTypeId,
      [hashedVoxelTypeId],
      [hashedVoxelTypeId],
      hashedVoxelTypeId,
      {
        enterWorldSelector: "0x00000000",
        exitWorldSelector: "0x00000000",
        voxelVariantSelector: "0x00000000",
        activateSelector: "0x00000000",
        onNewNeighbourSelector: "0x00000000",
        interactionSelectors: [],
      },
      "0x",
      PRETTY_VOXEL_MASS,
      txOptions
    );
    // console.log(tx.hash);
    allTx.push(tx.hash);

    txOptions.nonce += 1;
    tx = await caWorldContract.registerVoxelType(hashedVoxelTypeId, txOptions);
    // console.log(tx.hash);
    allTx.push(tx.hash);

       // Check the status of each transaction
   console.log("Verifying transactions...");
   for (const hash of allTx) {
    const receipt = await provider.waitForTransaction(hash);
    if (receipt.status === 1) {
        // console.log(`Transaction ${hash} was successful`);
    } else {
        console.log(`Transaction ${hash} failed`);
        console.log(receipt);
    }
  }
  console.log("Done verifying transactions!")

  allTx = [];
  }

  console.log("Finished deploying!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
