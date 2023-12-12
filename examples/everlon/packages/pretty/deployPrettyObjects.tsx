require("dotenv").config();
const { ethers } = require("ethers");
const fs = require("fs");
const { keccak256, toHex } = require("viem");

const chainId = process.env.NODE_ENV === "production" ? 1337 : 31337;
const rpcUrl = process.env.NODE_ENV === "production" ? "https://test-grid.everlon.xyz" : "http://127.0.0.1:8545";

const a = require("../../../../packages/registry/dist/types/ethers-contracts/factories/IWorld__factory.js");
const Registry__factory = a.IWorld__factory;

function keccak256Str(str) {
  return keccak256(toHex(str));
}

// TODO: Find a better way to blacklist these
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
  "plant",
  "faucet",
  "builder",
  "runner",
  "farmer",
  "creature-fire",
  "pokemon-water",
  "creature-grass",
  "thermo",
  "thermo",
]);

function snakeToCamel(str) {
  return str.replace(/(_\w)/g, (matches) => matches[1].toUpperCase());
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

// Note: must match the value in Constants.sol
const PRETTY_OBJECT_MASS = 7;

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

  const worldsJsonPath = "../world/worlds.json";
  const worldsJson = JSON.parse(fs.readFileSync(worldsJsonPath, "utf8"));
  const worldAddress = worldsJson[chainId].address;
  if (!worldAddress) {
    throw new Error("Missing worldAddress in worlds.json file");
  }

  // Connect to the Ethereum network
  const provider = new ethers.providers.JsonRpcProvider(rpcUrl);

  // Create a wallet instance with a private key and connect it to the network
  const wallet = new ethers.Wallet(privateKey, provider);
  console.log("Using wallet", wallet.address);

  // Create a typed contract instance
  console.log("Registry World address:", registryWorldAddress);
  const registryWorldContract = Registry__factory.connect(registryWorldAddress, wallet);

  const currentObjectMapping = new Map();
  const variantsData = fs.readFileSync(GEN_VARIANTS_PATH, "utf8");
  const rawObjectMapping = JSON.parse(variantsData);
  for (const [key, value] of Object.entries(rawObjectMapping)) {
    currentObjectMapping.set(key, value);
  }

  let nonce = await provider.getTransactionCount(wallet.address);

  const txOptions = {
    gasLimit: BigInt(1_900_000_000),
    // maxPriorityFeePerGas: 2000000000,
    // maxFeePerGas: 100000000000,
    nonce: nonce - 1,
  };

  // Go through currentObjectMapping and batch generate postdeploy scripts registering them
  for (const [rawObjectTypeId, variantData] of currentObjectMapping) {
    if (GEN_VOXEL_VARIANT_IDS_BLACKLIST.has(rawObjectTypeId)) {
      continue;
    }

    const objectTypeId = snakeToCamel(rawObjectTypeId);
    const capitalizedObjectTypeId = capitalize(objectTypeId);
    // make objectTypeDisplayName a spaced out version of the objectTypeId with each word capitalized
    const objectTypeDisplayName = capitalizedObjectTypeId.replace(/([A-Z])/g, " $1").trim();
    const hashedObjectTypeId = keccak256Str(rawObjectTypeId);
    console.log("Registering", objectTypeId, objectTypeDisplayName);

    // Call setTerrainProperties
    const contractAddress = worldAddress;
    // Read pretty_PrettyObjectSyst_eventHandler from out/IPrettyObjectSystem.sol/IPrettyObjectSystem.json
    const enterWorldSelector = "";
    const exitWorldSelector = "";
    const eventHandlerSelector = "";
    const neighbourEventHandlerSelector = "";

    txOptions.nonce += 1;
    let tx = await registryWorldContract.registerObjectType(
      hashedObjectTypeId,
      contractAddress,
      enterWorldSelector,
      exitWorldSelector,
      eventHandlerSelector,
      neighbourEventHandlerSelector,
      objectTypeDisplayName,
      ""
    );

    // Check the status of each transaction
    console.log("Verifying transaction...");
    const receipt = await provider.waitForTransaction(tx.hash);
    if (receipt.status === 1) {
      // console.log(`Transaction ${hash} was successful`);
    } else {
      console.log(`Transaction ${tx.hash} failed`);
      console.log(receipt);
    }
    console.log("Done verifying transaction!");
  }

  console.log("Finished deploying!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
