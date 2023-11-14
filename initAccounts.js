const fs = require("fs");
const {
    Web3
} = require("web3");
const web3 = new Web3("http://127.0.0.1:8545");

async function initChain() {
    try {
        // Read keystore file from dir
        const LOCAL_KEYSTORE_DIR = "./geth-datadir/keystore";
        const keystoreFile = fs.readdirSync(LOCAL_KEYSTORE_DIR)[0];

        // Continue with the rest of the initAccounts.js logic
        await initAccounts(`${LOCAL_KEYSTORE_DIR}/${keystoreFile.trim()}`);
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
        // Add the account to web3
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        // Default dev account
        var sender = account.address;

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

            var amount = web3.utils.toWei("10000", "ether");

            // Send transactions to each recipient
            for (const recipient of recipients) {
                receipt = await web3.eth.sendTransaction({
                    from: sender,
                    to: recipient,
                    value: amount,
                    ...gasPriceParams,
                });
                console.log(`Transaction to ${recipient} successful:`, receipt);
            }
        } catch (error) {
            console.error("Error in transaction:", error);
        }
    }
}

// Start the process
initChain();