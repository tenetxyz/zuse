#!/bin/sh

source server_url.rc
cd ../packages/extension-contracts
yarn run deploy --rpc="http://$SERVER_HOST:8545" --installDefaultModules false --worldAddress 0x5FbDB2315678afecb367f032d93F642f64180aa3