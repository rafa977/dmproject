# Hyperledger Fabric Installation v2.2.0 D.M. Project
The Hyperledger Fabric binaries installation root folder is `/etc/hyperledger/` and it should be created in the target server e.g.:

`mkdir -p /etc/hyperledger`

Go to the target folder

`cd /etc/hyperledger`

Then download in this folder the binaries for Fabric v2.2.0 and Fabric CA v1.4.8 using HFL script

`curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/release-2.2/scripts/bootstrap.sh | bash -s -- 2.2.0 1.4.8 -s`

`-s`: bypass fabric-samples repo clone

### Hyperledger Fabric folder structure
The HLF binaries should be located in `/etc/hyperledger/bin` and the config files in `/etc/hyperledger/config`

Set the PATH variable

`export PATH=/etc/hyperledger/bin:${PWD}:$PATH`

# Installation of "dmproject" network files

The installation project root folder is `dmproject` and it should be created in the target server e.g.:

`mkdir -p /etc/hyperledger/dmproject`

All the commands should be executed within this folder so this will be the ${PWD}

`cd /etc/hyperledger/dmproject`

### Filesystem structure
The network files should be deployed in the `{PWD}/network` folder

Run the `firstRunStruct.sh` script to create the required folders.

The complete target file structure for the `network` is the following:

```
dmproject
  ├── network
  |   ├── channel-artifacts
  |   ├── configtx
  |   ├── docker
  |       └── .env
  |   ├── organizations
  |   |   ├── ordererOrganizations
  |   |   └── peerOrganizations   
  |   └── system-genesis-block
  └── chaincode
```

### Environment Settings - .env 
There is a `.env` file which needs to be configured before running our network. There we have to configure the following values:

1. COMPOSE_PROJECT_NAME=net
2. IMAGE_TAG=2.2.0
3. CA_IMAGE_TAG=1.4.8
4. SYS_CHANNEL=system-channel

**The system channel needs to different for each network.

This file needs to be placed in the docker folder.

###  Crypto Files - CA

The first thing we want to do in order to create our folders is to create our crypto files. This will create all the nodes that we need for our network.

Before you run the script to create the files, you need to start the docker container of each organizations CA. This can be done and configured in the `docker-compose-ca.yml` file.

After you edited the `docker-compose-ca.yml` file and configured it with the settings you want, you can run it on docker.
```
docker-compose -f ./network/docker/docker-compose-ca.yml up -d
```



#### Set "FABRIC_CFG_PATH"
`export FABRIC_CFG_PATH=${PWD}/network/configtx`

Grant execution permission to `configtx.yaml`

`chmod +x network/configtx/configtx.yaml`


#  Build the network

### Generate system genesis block
```
configtxgen -profile PocOrgsOrdererGenesis -channelID system-channel -outputBlock ./network/system-genesis-block/genesis.block
```

### Bring the network up with couchdb
```
docker-compose -f network/docker/docker-compose-net.yaml  up -d
```

### Create channel block
**Attention**: Please be sure to have write privs on the `channel-artifacts` directory

```
configtxgen -profile PocOrgsChannel -outputCreateChannelTx ./network/channel-artifacts/dmproject.tx -channelID dmproject
```

### For each organization and channel we have to generate the anchor peer update transaction as follows for our 3 organizations and 1 channel
```
configtxgen -profile PocOrgsChannel -outputAnchorPeersUpdate ./network/channel-artifacts/KaliAnchors.tx -channelID dmproject -asOrg Kali
configtxgen -profile PocOrgsChannel -outputAnchorPeersUpdate ./network/channel-artifacts/PiAnchors.tx -channelID dmproject -asOrg Pi
```

#### Set "FABRIC_CFG_PATH"
The `config` should point to the hyperledger Fabric `/config` folder

`export FABRIC_CFG_PATH=${PWD}/../config`

In case `config` is in `/etc/hyperledger/config` then:

`export FABRIC_CFG_PATH=/etc/hyperledger/config`

#### Set "ORDERER_CA" this is for our convenience
```
export ORDERER_CA=${PWD}/network/organizations/ordererOrganizations/auth/orderers/orderer.auth/msp/tlscacerts/tlsca.auth-cert.pem
```

#### Set Kali variabes
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="KaliMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/network/organizations/peerOrganizations/kali/peers/peer0.kali/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/network/organizations/peerOrganizations/kali/users/Admin_kali@kali/msp
export CORE_PEER_ADDRESS=localhost:7151
```
#### Create the channel

```
peer channel create  -o localhost:7150  -c dmproject --ordererTLSHostnameOverride orderer.auth  -f ${PWD}/network/channel-artifacts/dmproject.tx --outputBlock ./network/channel-artifacts/dmproject.block --tls true --cafile ${PWD}/network/organizations/ordererOrganizations/auth/orderers/orderer.auth/msp/tlscacerts/tlsca.auth-cert.pem
```

### Kali join the channel
Use the ENV variabes from above for Kali organization

#### Join the channel Kali
```
peer channel join -b ./network/channel-artifacts/dmproject.block
```

### Pi join the channel

#### Set Pi variabes
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="PiMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/network/organizations/peerOrganizations/pi/peers/peer0.pi/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/network/organizations/peerOrganizations/pi/users/Admin_pi@pi/msp
export CORE_PEER_ADDRESS=localhost:8151
```
#### Join the channel Pi
```
peer channel join -b ./network/channel-artifacts/dmproject.block
```


### Update the channel definition to define the anchor peer for  Kali
Use the Kali ENV variabes from above

```
peer channel update -o localhost:7150 --ordererTLSHostnameOverride orderer.auth -c dmproject -f ${PWD}/network/channel-artifacts/KaliAnchors.tx --tls --cafile $ORDERER_CA
```


### Update the channel definition to define the anchor peer for  Pi
Use the Pi ENV variabes from above

```
peer channel update -o localhost:7150 --ordererTLSHostnameOverride orderer.auth -c dmproject -f ${PWD}/network/channel-artifacts/PiAnchors.tx --tls --cafile $ORDERER_CA
```


#  Network operations

###  Bring down the network
#### With Fabric CA
```
docker-compose -f network/docker/docker-compose-net.yaml -f network/docker/docker-compose-ca.yaml down
```

#### Without Fabric CA
```
docker-compose -f network/docker/docker-compose-net.yaml down
```
