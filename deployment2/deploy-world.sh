#!/bin/sh

source server_url.rc
cd ../packages/contracts
yarn run deploy --rpc="http://$SERVER_URL:8545"