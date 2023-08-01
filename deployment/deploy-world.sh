#!/bin/sh

source server_url.rc
cd ../packages/registry
yarn run deploy --rpc="http://$SERVER_HOST:8545"
cd ../base-ca
node ../scripts/setRegistryAddress.js 905 ../registry/worlds.json src/Constants.sol REGISTRY_ADDRESS
yarn run deploy --rpc="http://$SERVER_HOST:8545"
cd ../level2-ca
node ../scripts/setRegistryAddress.js 905 ../registry/worlds.json src/Constants.sol REGISTRY_ADDRESS
yarn run deploy --rpc="http://$SERVER_HOST:8545"
cd ../level3-ca
node ../scripts/setRegistryAddress.js 905 ../registry/worlds.json src/Constants.sol REGISTRY_ADDRESS
yarn run deploy --rpc="http://$SERVER_HOST:8545"
cd ../contracts
node ../scripts/setRegistryAddress.js 905 ../registry/worlds.json src/Constants.sol REGISTRY_ADDRESS
node ../scripts/setRegistryAddress.js 905 ../base-ca/worlds.json src/Constants.sol BASE_CA_ADDRESS
node ../scripts/setRegistryAddress.js 905 ../level2-ca/worlds.json src/Constants.sol LEVEL_2_CA_ADDRESS
node ../scripts/setRegistryAddress.js 905 ../level3-ca/worlds.json src/Constants.sol LEVEL_3_CA_ADDRESS
yarn run deploy --rpc="http://$SERVER_HOST:8545"