const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const chainId = process.env.NODE_ENV === "production" ? 1337 : 31337;

function getAddressFromFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, "utf8");
    const json = JSON.parse(content);
    return json[chainId] && json[chainId].address;
  } catch (error) {
    console.error(`Error reading or parsing JSON from ${filePath}:`, error);
    process.exit(1);
  }
}

const worldAddress = getAddressFromFile("../level1-ca/worlds.json");

function executeCommand(command) {
  try {
    execSync(command, {
      stdio: "inherit",
    });
  } catch (error) {
    console.error(`Error executing command: ${command}`);
    process.exit(1);
  }
}

// Get the action (build, deploy, etc.) from command-line arguments
const action = process.argv[2];

if (!action) {
  console.error("Please specify an action (e.g., build, deploy).");
  process.exit(1);
}

if (action == "build") {
  // List of dev commands
  const setRegistryAddressCommand = `node ../../../../scripts/setRegistryAddress.js ${chainId} ../../../../packages/registry/worlds.json src/Constants.sol REGISTRY_ADDRESS`;
  const setCAAddressCommand = `node ../../../../scripts/setRegistryAddress.js ${chainId} ../level1-ca/worlds.json src/Constants.sol CA_ADDRESS`;
  const devCommands = [setRegistryAddressCommand, setCAAddressCommand, "yarn run initialize"];

  devCommands.forEach((command) => {
    executeCommand(command);
  });
} else if (action == "deploy") {
  // Loop over all files in script/ and forge script each one
  const scriptDir = "script";
  const files = fs.readdirSync(scriptDir);
  let rpcUrl = "http://127.0.0.1:8545";
  if (process.env.NODE_ENV === "production") {
    rpcUrl = "https://test-grid.everlon.xyz";
  }

  files.forEach((file) => {
    if (path.extname(file) === ".sol") {
      const fullPath = path.join(scriptDir, file);
      const command = `forge script ${fullPath} --sig 'run(address)' '${worldAddress}' --broadcast --rpc-url ${rpcUrl} -vv`;

      console.log("Running command:", command);

      executeCommand(command);
    }
  });
}
