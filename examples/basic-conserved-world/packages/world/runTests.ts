const fs = require("fs");
const { execSync } = require("child_process");

const worlds = JSON.parse(fs.readFileSync("worlds.json", "utf8"));
const worldAddress = worlds["31337"].address;

const command = `yarn mud test --worldAddress='${worldAddress}' --forgeOptions='-vvv'`;

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
