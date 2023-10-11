const fs = require("fs");
const { execSync } = require("child_process");

const worlds = JSON.parse(fs.readFileSync("../world/worlds.json", "utf8"));
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

fs.readdir("script/generated/", (err, files) => {
  if (err) {
    console.error(`Error reading directory: ${err.message}`);
    return;
  }

  files.forEach((file) => {
    if (file.startsWith("Spawn")) {
      runForgeScript(`script/generated/${file}`);
    }
  });
});
