#/bin/sh

find . -type d -name 'node_modules' -exec rm -rf {} +
yarn cache clean
# rm yarn.lock # yes. this is needed or else we won't update our pointers (in the yarn.lock) to the latest commit in our forks

cd scripts
yarn install # in scripts
cd ../ # move to root
yarn install
cd examples/everlon
yarn install
