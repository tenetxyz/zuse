import fs from "fs";
import { exec } from "child_process";
import { createWalletClient, fallback, http, parseEther, webSocket } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { transportObserver } from "@latticexyz/common";
import { defineChain } from "viem";
import Web3 from "web3";

const web3 = new Web3("http://localhost:8545");

export const localGeth = defineChain(
  {
    name: "Local Geth",
    id: 1337,
    network: "geth",
    nativeCurrency: { decimals: 18, name: "Ether", symbol: "ETH" },
    rpcUrls: {
      default: {
        http: ["http://localhost:8545"],
        webSocket: ["http://localhost:8545"],
      },
      public: {
        http: ["http://localhost:8545"],
        webSocket: ["http://localhost:8545"],
      },
    },
  },
  {
    fees: {
      defaultPriorityFee: 0n,
    },
  }
);

const clientOptions = {
  chain: localGeth,
  transport: transportObserver(fallback([webSocket(), http()])),
  pollingInterval: 1000,
};

export const walletClient = createWalletClient({
  ...clientOptions,
});

const LOCAL_KEYSTORE_DIR = "data/keystore";
async function initChain() {
  try {
    // Find the keystore file in the LOCAL_KEYSTORE_DIR directory
    await exec(`ls ${LOCAL_KEYSTORE_DIR} | grep UTC`, (error, stdout, stderr) => {
      if (error) {
        console.error("Error finding keystore file:", error);
        return;
      }
      if (stderr) {
        console.error("Error finding keystore file:", stderr);
        return;
      }

      const keystoreFile = stdout;

      if (!keystoreFile) {
        console.error("No keystore file found in the pod.");
        process.exit(1);
      }

      // Continue with the rest of the initAccounts.js logic
      initAccounts(`${LOCAL_KEYSTORE_DIR}/${keystoreFile.trim()}`);

      return stdout;
    });
  } catch (error) {
    console.error("Error in initChain:", error);
  }
}

async function initAccounts(keystorePath) {
  // Read the keystore file
  fs.readFile(keystorePath, "utf8", (err, keystoreData) => {
    if (err) {
      console.error("Error reading keystore file:", err);
      return;
    }

    // Parse the keystore JSON
    const keystore = JSON.parse(keystoreData);

    // Decrypt the keystore file to obtain the private key
    web3.eth.accounts
      .decrypt(keystore, "")
      .then((decryptedAccount) => {
        // console.log("Private Key:", decryptedAccount.privateKey);
        initAccounts(decryptedAccount.privateKey);
      })
      .catch((error) => {
        console.error("Error decrypting keystore:", error);
      });
  });

  async function initAccounts(privateKey) {
    // Local Account
    const account = privateKeyToAccount(privateKey);

    // Default dev account
    var sender = account.address;
    console.log("sender", sender);

    try {
      // Define gas price parameters
      const gasPriceParams = {
        maxPriorityFeePerGas: web3.utils.toWei("2", "gwei"), // Adjust as needed
        maxFeePerGas: web3.utils.toWei("100", "gwei"), // Adjust as needed
      };

      // List of recipient accounts
      var recipients = [
        "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
        "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
        "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc",
        "0x90f79bf6eb2c4f870365e785982e1f101e93b906",
        "0x15d34aaf54267db7d7c367839aaf71a00a2c6a65",
        "0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc",
        "0x976ea74026e726554db657fa54763abd0c3a0aa9",
        "0x14dc79964da2c08b23698b3d3cc7ca32193d9955",
        "0x23618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f",
        "0xa0ee7a142d267c1f36714e4a8f75612f20a79720",
      ];

      // Send transactions to each recipient
      for (const recipient of recipients) {
        console.log(`Sending transaction to ${recipient}...`);
        const hash = await walletClient.sendTransaction({
          account,
          to: recipient,
          value: parseEther("10000"),
        });
        console.log(`Transaction hash: ${hash}`);
      }
    } catch (error) {
      console.error("Error in transaction:", error);
    }
  }
}

// Start the process
initChain();
