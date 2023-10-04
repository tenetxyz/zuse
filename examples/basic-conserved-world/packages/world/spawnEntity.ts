const fs = require("fs");
const { execSync } = require("child_process");

const worlds = JSON.parse(fs.readFileSync("worlds.json", "utf8"));
const worldAddress = worlds["31337"].address;

function runForgeScript(filePath) {
  const command = `forge script ${filePath} --sig "run(address)" ${worldAddress} --broadcast --rpc-url http://127.0.0.1:8545`;
  try {
    console.log(`Running command: ${command}`);
    const stdout = execSync(command).toString();
    console.log(`Stdout: ${stdout}`);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    if (error.stderr) {
      console.error(`Stderr: ${error.stderr.toString()}`);
    }
  }
}

runForgeScript(`script/SpawnEntity.s.sol`);
