#/bin/sh

find . -type d -name 'node_modules' -exec rm -rf {} +
yarn cache clean
# rm yarn.lock # yes. this is needed or else we won't update our pointers (in the yarn.lock) to the latest commit in our noa fork

cd scripts
yarn install # in scripts
cd ../ # move to root
yarn install
cd examples/basic-conserved-world
yarn install


# Now generate all the files
# we're in basic-conserved-world
yarn initialize