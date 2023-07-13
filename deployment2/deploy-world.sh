#!/bin/sh


source server_url.rc
cd ../packages/contracts
yarn run deploy --rpc="$SERVER_URL"