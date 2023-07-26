#/bin/sh

find . -type d -name 'node_modules' -exec rm -rf {} +
yarn cache clean
rm yarn.lock # yes. this is needed or else we won't update our pointers (in the yarn.lock) to the latest commit in our noa fork
yarn install