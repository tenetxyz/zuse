#!/bin/sh

source server_url.rc
cd ../packages/extension-contracts
yarn run deploy --rpc="http://$SERVER_HOST:8545"