#!/bin/bash

# Extract worldAddress using awk
worldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' ../level1-ca/worlds.json)
mainWorldAddress=$(awk -F'"' '/"31337":/{getline; print $4}' ../world/worlds.json)

yarn mud deploy --installDefaultModules false --worldAddress ${worldAddress}
