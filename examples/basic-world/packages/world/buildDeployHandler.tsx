const { execSync } = require("child_process");

const chainId = process.env.NODE_ENV === "production" ? 1337 : 31337;

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
  const setRegistryAddressCommand = `node ../../../../scripts/setAddress.js ${chainId} ../../../../packages/registry/worlds.json src/Constants.sol REGISTRY_ADDRESS`;
  const setSimAddressCommand = `node ../../../../scripts/setAddress.js ${chainId} ../simulator/worlds.json src/Constants.sol SIMULATOR_ADDRESS`;
  const devCommands = [setRegistryAddressCommand, setSimAddressCommand, "yarn run initialize"];

  devCommands.forEach((command) => {
    executeCommand(command);
  });
} else if (action == "deploy") {
  let deployCommand = "yarn mud deploy";
  if (process.env.NODE_ENV === "production") {
    deployCommand += " --profile=tenet-testgrid";
  }
  const devCommands = [deployCommand];

  devCommands.forEach((command) => {
    executeCommand(command);
  });
}
