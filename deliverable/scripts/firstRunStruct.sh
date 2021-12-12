#!/bin/bash

mkdir network
chmod 777 ./network

mkdir ./network/channel-artifacts/
mkdir ./network/organizations/
mkdir ./network/system-genesis-block/

mkdir ./network/configtx/
chmod 777 ./network/configtx/
cp ./configtx/configtx.yml ./network/configtx/
rm -rf ./configtx/

mkdir ./network/docker/
chmod 777 ./network/docker/
cp ./docker/.env ./network/docker/
cp ./docker/* ./network/docker/
rm -rf ./docker/