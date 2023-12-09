const { execSync } = require("child_process");
const fs = require("fs");

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
  const devCommands = [setRegistryAddressCommand, "yarn run initialize"];

  devCommands.forEach((command) => {
    executeCommand(command);
  });
} else if (action == "deploy") {
  const worldAddress = getAddressFromFile("../world/worlds.json");

  let deployCommand = `yarn mud deploy --installDefaultModules false --worldAddress ${worldAddress}`;
  let rpcUrl = "http://127.0.0.1:8545";
  if (process.env.NODE_ENV === "production") {
    deployCommand += " --profile=tenet-testgrid";
    rpcUrl = "https://test-grid.everlon.xyz";
  }
  const forgeCommand = `forge script script/TerrainDeploy.s.sol --sig 'run(address,address)' '${worldAddress}' --broadcast --rpc-url ${rpcUrl} -vv`;
  const devCommands = [deployCommand, forgeCommand];

  devCommands.forEach((command) => {
    executeCommand(command);
  });
}
