### Deployment

If you want to setup EVERYTHING: the anvil node, the react app, then:

- `make create-instance`
- ssh into the linux host, create an ssh key, connect your key to github, then clone this repo
- `make install` to clone our mud fork, and install the dependencies for voxel-aw and our mud fork.

Everything is setup. We now need to change some configs so when we spin up the node, it's pointing to the right chain

- Then go into our mud fork and change:
  - The "--chain-id", to 905 in packages/cli/src/commands/dev-contracts.ts
    - Note: 905 is a chainId that I chose to use for our chain
  - Then go to tenetTestnet.ts and change the nodeUrl to the server's url **Without the https://**
- Finally, run `yarn run deploy` in the top directory of voxel-aw to spin up our node and client

### Faucet service and Snapshot Service

- We still need to spin up the faucet and snapshot service
  you probably want to use `make build-services` to send the faucet and snapshot service binaries to the server

### Setting up our own standaline anvil node

- just run `make setup-node` to spin up an anvil node on our machine

### Deploying to an existing anvil node

All you need to do is:

- go to package.json in contracts/ add the `--rpc` param in: yarn mud deploy --rpc=http://18.191.133.57:8545"
- go to the mud fork and MAKE SURE THE chainId in the configs exported by `packages/common/src/chains/index.ts` is the same chainId as the anvil node. Otherwise, the client will not be able to connect to it
  - ofc, after changing the chainId, do `pnpm build`
- run `yarn run deploy` in contracts to deploy to our chain
