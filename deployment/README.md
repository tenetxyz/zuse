### Deployment

If you want to setup EVERYTHING: the anvil node, the react app, then:

- `make create-instance`
- ssh into the linux host, create an ssh key, connect your key to github, then clone this repo
- `make install` to clone our mud fork, and install the dependencies for voxel-aw and our mud fork.

Everything is setup. We now need to change some configs so when we spin up the node, it's pointing to the right chain

- Then go into our mud fork and change:
  - The "--chain-id", to 905 in packages/cli/src/commands/dev-contracts.ts
  - Then go to tenetTestnet.ts and change the nodeUrl to the server's url **Without the https://**
- Then go to voxel-aw and change the chainId in packages/client/.env to 905
- Finally, run `yarn run dev` in the top directory of voxel-aw to spin up our node and client

### Faucet service and Snapshot Service

- We still need to spin up the faucet and snapshot service
  you probably want to use `make build-services` to send the faucet and snapshot service binaries to the server
