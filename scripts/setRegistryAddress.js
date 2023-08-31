// read worlds.json from registry
import fs from "fs";

const chainId = process.argv[2];
const worldsJsonPath = process.argv[3];
const solidityFilePath = process.argv[4];
const variableName = process.argv[5];

function setRegistryAddress() {
    if (chainId === undefined) {
        console.log('chainId is undefined');
        return;
    }

    if (worldsJsonPath === undefined) {
        console.log('worldsJsonPath is undefined');
        return;
    }

    if (solidityFilePath === undefined) {
        console.log('solidityFilePath is undefined');
        return;
    }

    if (variableName === undefined) {
        console.log('variableName is undefined');
        return;
    }

    const worldsJson = JSON.parse(fs.readFileSync(worldsJsonPath, 'utf8'));

    if (worldsJson[chainId] === undefined) {
        console.log('chainId is not found');
        return;
    }

    const worldAddress = worldsJson[chainId]["address"];

    // set registry address in base-ca

    // Read the file
    fs.readFile(solidityFilePath, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading file:', err);
            return;
        }

        // Replace the line with the new content
        const lines = data.split('\n');
        const newLines = [];
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line.startsWith(`address constant ${variableName}`)) {
                const newLine = `address constant ${variableName} = ${worldAddress};`;
                newLines.push(newLine);
            } else {
                newLines.push(line);
            }
        }
        const updatedContent = newLines.join('\n');

        // Write the updated content back to the file
        fs.writeFile(solidityFilePath, updatedContent, 'utf8', (err) => {
            if (err) {
                console.error('Error writing to file:', err);
                return;
            }
            console.log(`Address variable ${variableName} replaced successfully to ${worldAddress}.`);
        });
    });
}

setRegistryAddress();