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

### config.yaml 
Before we continue on creating users, peers orderers etc. a config yaml file that corresponds to each organization to the according msp folder of each peer, user, organization needs to be created.

Each config file will have the following structure:

```
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8154-ca_.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8154-ca_.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8154-ca_.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8154-ca_.pem
    OrganizationalUnitIdentifier: orderer
```

hehe... my robot got you again! Keep reading the instructions. The crypto-gen file is generating also the config.yaml files for you. 

** If you want to do it manually, remember that it works only with `.yaml` ending and not with `.yml`.

###  Crypto Files - CA

Before you run the script to create the files, you need to start the docker container of each organizations CA. This can be done and configured in the `docker-compose-ca.yaml` file.

After you edited the `docker-compose-ca.yaml` file and configured it with the settings you want, you can run it on docker.
```
docker-compose -f ./network/docker/docker-compose-ca.yaml up -d
```


### Crypto Generator - crypto-gen - And here comes the magic

In order to create the crypto files, you can run the script of `crypto-gen.sh` file.

E.g. Create new user for organization
```
./crypto-gen.sh -o orgName -t user -u 'user1' -c ca_auth -p 7054 
```
`-o` ==> Organization Name where you want to create your files
`-u` ==> String array where you specify the username for each user separated with space
`-p` ==> Port where the ca listens to
`-c` ==> ca name of the CA that corresponds to the organization
`-t` ==> type of crypto files creation (user, orderer, peer, admin)

** When an `orderer` is created the `-u` is not required since a default orderer user is created.

Remeber the password of the user follows always the structure: 
`user_org` 
E.g. 
username = paul
org = kali
password == paul_kali

In order to have a functional network you need to have the following nodes:

1. Peer Organization
    1. Peer
    2. User
    3. Admin 
2. Orderer Organization
    1. Orderer
    2. Admin User


After creating the users, we must specify their attributes because with this way we have not specify them.

Guess what, another script file waits for you. addAttribute.sh

In order to add an attribute we have to modify an existing user and then reenroll him.

```
.addAttribute.sh -o kali -c ca_kali -u user_1 -a 'age=Kid:ecert' -i 7054 -p passwordUser
```

#### Set "FABRIC_CFG_PATH"
`export FABRIC_CFG_PATH=${PWD}/network/configtx`

Grant execution permission to `configtx.yaml`

`chmod +x network/configtx/configtx.yaml`


#  Build the network

### Generate system genesis block
```
configtxgen -profile PocOrgsOrdererGenesis -channelID system-chan -outputBlock ./network/system-genesis-block/genesis.block
```

### Bring the network up
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
export CORE_PEER_ADDRESS=localhost:7051
```
#### Create the channel

```
peer channel create  -o localhost:7050  -c dmproject --ordererTLSHostnameOverride orderer.auth  -f ${PWD}/network/channel-artifacts/dmproject.tx --outputBlock ./network/channel-artifacts/dmproject.block --tls true --cafile ${PWD}/network/organizations/ordererOrganizations/auth/orderers/orderer.auth/msp/tlscacerts/tlsca.auth-cert.pem
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
export CORE_PEER_ADDRESS=localhost:8051
```
#### Join the channel Pi
```
peer channel join -b ./network/channel-artifacts/dmproject.block
```
export CORE_PEER_MSPCONFIGPATH=${PWD}/network/organizations/peerOrganizations/pi/users/Adminn_pi@pi/msp


### Update the channel definition to define the anchor peer for  Kali
Use the Kali ENV variabes from above

```
peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.auth -c dmproject -f ${PWD}/network/channel-artifacts/KaliAnchors.tx --tls --cafile $ORDERER_CA
```


### Update the channel definition to define the anchor peer for  Pi
Use the Pi ENV variabes from above

```
peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.auth -c dmproject -f ${PWD}/network/channel-artifacts/PiAnchors.tx --tls --cafile $ORDERER_CA
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
