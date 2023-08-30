import {
    anvil,
    forge,
    getRpcUrl,
    getScriptDirectory,
    getSrcDirectory
} from "@latticexyz/common/foundry";
import {
    homedir
} from "os";
import path from "path";
import {
    rmSync
} from "fs";

console.log("Cleaning devnode cache");
const userHomeDir = homedir();
rmSync(path.join(userHomeDir, ".foundry", "anvil", "tmp"), {
    recursive: true,
    force: true
});

const anvilArgs = [
    "--block-time",
    "1",
    "--block-base-fee-per-gas",
    "0",
    "--host",
    "0.0.0.0",
    "--chain-id",
    "31337",
    "--gas-limit",
    "1000000000",
];
anvil(anvilArgs);