#!/bin/sh
# **********
# The script generates the crypto material for IOSS-DR PoC on EBSI network 1st iteration
# It executes one by one the commands described in the ca-instructions.md guide
#
# Go to cd /etc/hyperledger/iossdr-poc-ebsi
# grant exec permission
# chmod +x ./network/crypto-generator.sh
# and then run this:
# . ./network/crypto-generator.sh
# **********

export PATH=/etc/hyperledger/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/network/configtx
# **********
# ATTENTION: Be sure to bring the docker containers up
# **********

# **********
# Org: betax.ebsi.eu
# **********
echo "####### Org: betax.ebsi.eu #######"
echo "=====> Create dir and set varialbes"
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/
export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname  ca-betax.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
echo "=====> Register peer0  for betax.ebsi.eu"
fabric-ca-client register --caname ca-betax.ebsi.eu --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
echo "=====> Register user user1_be_tax for betax.ebsi.eu [with the role of Publisher]"
fabric-ca-client register --caname ca-betax.ebsi.eu --id.name user1_be_tax --id.secret user1_be_tax --id.type client --id.attrs 'role=Publisher:ecert'  --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
echo "=====> Register user user2_be_tax for betax.ebsi.eu [with the role of Retriever]"
fabric-ca-client register --caname ca-betax.ebsi.eu --id.name user2_be_tax --id.secret user2_be_tax --id.type client --id.attrs 'role=Retriever:ecert'  --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
echo "=====> Register the org admin  for betax.ebsi.eu"
fabric-ca-client register --caname ca-betax.ebsi.eu --id.name orgbetaxadmin --id.secret orgbetaxadminpw --id.type admin --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
echo "=====> Generate the peer0 msp  for betax.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-betax.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/msp --csr.hosts peer0.betax.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/msp/config.yaml
echo "=====> Generate the peer0-tls certificates  for betax.ebsi.eu  (Enroll)"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-betax.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls --enrollment.profile tls --csr.hosts peer0.betax.ebsi.eu --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/ca.crt
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/signcerts/* ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/server.crt
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/keystore/* ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/server.key
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/msp/tlscacerts
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/msp/tlscacerts/ca.crt
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/tlsca
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/tlsca/tlsca.betax.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/ca
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/peers/peer0.betax.ebsi.eu/msp/cacerts/* ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/ca/ca.betax.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/user1_be_tax@betax.ebsi.eu
echo "=====> Generate the user1_be_tax  msp for betax.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://user1_be_tax:user1_be_tax@localhost:7054 --caname ca-betax.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/user1_be_tax@betax.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/user1_be_tax@betax.ebsi.eu/msp/config.yaml
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/user2_be_tax@betax.ebsi.eu
echo "=====> Generate the user2_be_tax  msp for betax.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://user2_be_tax:user2_be_tax@localhost:7054 --caname ca-betax.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/user2_be_tax@betax.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/user2_be_tax@betax.ebsi.eu/msp/config.yaml
mkdir -p ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/Admin@betax.ebsi.eu
echo "=====> Generate the org admin msp for betax.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://orgbetaxadmin:orgbetaxadminpw@localhost:7054 --caname ca-betax.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/Admin@betax.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/betax.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/betax.ebsi.eu/users/Admin@betax.ebsi.eu/msp/config.yaml
# **********
# Org: frcst.ebsi.eu
# **********
echo "####### Org: frcst.ebsi.eu #######"
echo "=====> Create dir and set varialbes"
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/
export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu
echo "=====> Enroll the CA admin for frcst.ebsi.eu"
fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname  ca-frcst.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
# Copy the source: from local \network\organizations\peerOrganizations\frcst.ebsi.eu\msp\config.yaml to target: ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/msp
echo "=====> Register peer0  for frcst.ebsi.eu"
fabric-ca-client register --caname ca-frcst.ebsi.eu --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
echo "=====> Register user user1_fr_cst for frcst.ebsi.eu"
fabric-ca-client register --caname ca-frcst.ebsi.eu --id.name user1_fr_cst --id.secret user1_fr_cst --id.type client --id.attrs 'role=Retriever:ecert'  --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
echo "=====> Register the org admin  for frcst.ebsi.eu"
fabric-ca-client register --caname ca-frcst.ebsi.eu --id.name orgfrcstadmin --id.secret orgfrcstadminpw --id.type admin --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
echo "=====> Generate the peer0 msp  for frcst.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-frcst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/msp --csr.hosts peer0.frcst.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/msp/config.yaml
echo "=====> Generate the peer0-tls certificates  for frcst.ebsi.eu  (Enroll)"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-frcst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls --enrollment.profile tls --csr.hosts peer0.frcst.ebsi.eu --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/ca.crt
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/signcerts/* ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/server.crt
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/keystore/* ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/server.key
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/msp/tlscacerts
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/msp/tlscacerts/ca.crt
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/tlsca
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/tlsca/tlsca.frcst.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/ca
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/peers/peer0.frcst.ebsi.eu/msp/cacerts/* ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/ca/ca.frcst.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users/user1_fr_cst@frcst.ebsi.eu
echo "=====> Generate the user1_fr_cst  msp for frcst.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://user1_fr_cst:user1_fr_cst@localhost:8054 --caname ca-frcst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users/user1_fr_cst@frcst.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users/user1_fr_cst@frcst.ebsi.eu/msp/config.yaml
mkdir -p ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users/Admin@frcst.ebsi.eu
echo "=====> Generate the org admin msp for frcst.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://orgfrcstadmin:orgfrcstadminpw@localhost:8054 --caname ca-frcst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users/Admin@frcst.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/frcst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/frcst.ebsi.eu/users/Admin@frcst.ebsi.eu/msp/config.yaml
# **********
# Org: decst.ebsi.eu
# **********
echo "####### Org: decst.ebsi.eu #######"
echo "=====> Create dir and set varialbes"
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/
export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu
echo "=====> Enroll the CA admin for decst.ebsi.eu"
fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname  ca-decst.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
# Copy the source: from local \network\organizations\peerOrganizations\decst.ebsi.eu\msp\config.yaml to target: ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/msp
echo "=====> Register peer0  for decst.ebsi.eu"
fabric-ca-client register --caname ca-decst.ebsi.eu --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
echo "=====> Register user user1_de_cst for decst.ebsi.eu"
fabric-ca-client register --caname ca-decst.ebsi.eu --id.name user1_de_cst --id.secret user1_de_cst --id.type client --id.attrs 'role=Retriever:ecert'  --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
echo "Register the org admin  for decst.ebsi.eu"
fabric-ca-client register --caname ca-decst.ebsi.eu --id.name orgdecstadmin --id.secret orgdecstadminpw --id.type admin --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
echo "=====> Generate the peer0 msp  for decst.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-decst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/msp --csr.hosts peer0.decst.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/msp/config.yaml
echo "=====> Generate the peer0-tls certificates  for decst.ebsi.eu  (Enroll)"
fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-decst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls --enrollment.profile tls --csr.hosts peer0.decst.ebsi.eu --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/ca.crt
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/signcerts/* ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/server.crt
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/keystore/* ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/server.key
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/msp/tlscacerts
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/msp/tlscacerts/ca.crt
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/tlsca
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/tlsca/tlsca.decst.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/ca
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/peers/peer0.decst.ebsi.eu/msp/cacerts/* ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/ca/ca.decst.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users/user1_de_cst@decst.ebsi.eu
echo "=====> Generate the user1_de_cst  msp for decst.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://user1_de_cst:user1_de_cst@localhost:9054 --caname ca-decst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users/user1_de_cst@decst.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users/user1_de_cst@decst.ebsi.eu/msp/config.yaml
mkdir -p ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users/Admin@decst.ebsi.eu
echo "=====> Generate the org admin msp for decst.ebsi.eu (Enroll)"
fabric-ca-client enroll -u https://orgdecstadmin:orgdecstadminpw@localhost:9054 --caname ca-decst.ebsi.eu -M ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users/Admin@decst.ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/decst.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/decst.ebsi.eu/users/Admin@decst.ebsi.eu/msp/config.yaml
# **********
# Org: orderer.ebsi.eu
# **********
echo "####### Org: orderer.ebsi.eu #######"
echo "=====> Create dir and set varialbes"
mkdir -p ${PWD}/network/organizations/ordererOrganizations/ebsi.eu
export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/ordererOrganizations/ebsi.eu
echo "=====> Enroll the CA admin for orderer.ebsi.eu"
fabric-ca-client enroll -u https://admin:adminpw@localhost:7058 --caname  ca-orderer.ebsi.eu --tls.certfiles ${PWD}/network/organizations/fabric-ca/orderer.ebsi.eu/tls-cert.pem
# Copy the source: from local \network\organizations\ordererOrganizations\ebsi.eu\msp\config.yaml to target: ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/msp
echo "=====> Register orderer  for orderer.ebsi.eu"
fabric-ca-client register --caname ca-orderer.ebsi.eu --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/network/organizations/fabric-ca/orderer.ebsi.eu/tls-cert.pem
echo "=====> Register the orderer admin  for orderer.ebsi.eu"
fabric-ca-client register --caname ca-orderer.ebsi.eu --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/network/organizations/fabric-ca/orderer.ebsi.eu/tls-cert.pem
mkdir -p  ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers
mkdir -p  ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/ebsi.eu
mkdir -p  ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu
echo "=====> Generate the orderer msp"
fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7058 --caname ca-orderer.ebsi.eu -M ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/msp --csr.hosts orderer.ebsi.eu --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/orderer.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/msp/config.yaml ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/msp/config.yaml
echo "=====> Generate the orderer-tls certificates"
fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7058 --caname ca-orderer.ebsi.eu -M ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls --enrollment.profile tls --csr.hosts orderer.ebsi.eu --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/orderer.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/ca.crt
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/signcerts/* ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/server.crt
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/keystore/* ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/server.key
mkdir -p ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/msp/tlscacerts
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/msp/tlscacerts/tlsca.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/msp/tlscacerts
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/orderers/orderer.ebsi.eu/tls/tlscacerts/* ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/msp/tlscacerts/tlsca.ebsi.eu-cert.pem
mkdir -p ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/users
mkdir -p ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/users/Admin@ebsi.eu
echo "=====> Generate the admin msp"
fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:7058 --caname ca-orderer.ebsi.eu -M ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/users/Admin@ebsi.eu/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/orderer.ebsi.eu/tls-cert.pem
cp ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/msp/config.yaml ${PWD}/network/organizations/ordererOrganizations/ebsi.eu/users/Admin@ebsi.eu/msp/config.yaml
