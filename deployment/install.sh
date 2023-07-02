#!/bin/sh

#echo "this script is used to install all dependencies on a fresh linux host. It works, but isn't the recommended way to deploy. But this script could be useful for later. "
#echo "closing this script now since you probably shouldn't use it"
#exit 0

# downloads and installs our entire repo on the prod server.

# install nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
. ~/.nvm/nvm.sh # activate nvm
nvm install --lts

# install pnpm
wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -
source /home/ec2-user/.bashrc

sudo yum install gcc-c++ -y # needed for node-gyp by mud

# install go
sudo yum install golang -y

# install protoc
sudo yum install -y protobuf-compiler

# install foundry
curl -L https://foundry.paradigm.xyz | bash
source /home/ec2-user/.bashrc
foundryup

# install our mud fork
cd ~
git clone https://github.com/tenetxyz/mud
cd mud
pnpm install
pnpm build

# install yarn
curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
sudo yum install yarn -y

# install packages for our project
cd ~/voxel-aw

# set yarn to 3.0.6+
yarn set version stable
file_path=".yarnrc.yml"
string_to_append="nodeLinker: node-modules"
if ! grep -qF "$string_to_append" "$file_path"; then
  echo "$string_to_append" >> "$file_path"
fi

# finally we can install the dependencies in our repo
yarn install
