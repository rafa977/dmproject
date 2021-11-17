#!/bin/bash
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


createPeer(){

    peer=$1
    ca=$2
    organization=$3;
    port=$4

    peerPw=$peer''pw
    peerOrg=$peer'.'$organization

    echo $peerPw
    echo $peer "--" $organization "--" $ca;

    echo $peer "--" $organization "--" $ca;

    # **********
    # Org: $organization
    # **********
    echo "####### Org: "$organization "#######"
    echo "=====> Create dir and set varialbes"
    mkdir -p ${PWD}/network/organizations/peerOrganizations/$organization/

    export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/$organization
    fabric-ca-client enroll -u https://admin:adminpw@localhost:$port --caname  $ca --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem 
    
    echo "=====> Register "$peer" for "$organization
    fabric-ca-client register --caname $ca --id.name $peer --id.secret $peerPw --id.type peer --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem > /dev/null

    status=$?
    if [ $status -eq 1 ]; then
        echo "Peer already exists"
        exit 1;
    elif [ $status -eq 2 ]; then
        echo "Misuse of shell builtins"
        exit 1;
    elif [ $status -eq 126 ]; then
        echo "Command invoked cannot execute"
        exit 1;
    elif [ $status -eq 128 ]; then
        echo "Invalid argument"
        exit 1;
    fi

    echo "=====> Generate the "$peer" msp  for "$organization" (Enroll)"
    fabric-ca-client enroll -u https://$peer:$peerPw@localhost:$port --caname $ca -M ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/msp --csr.hosts $peerOrg --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    cp ${PWD}/network/organizations/peerOrganizations/$organization/msp/config.yaml ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/msp/config.yaml

    echo "=====> Generate the peer0-tls certificates  for " $organization  "(Enroll)"
    fabric-ca-client enroll -u https://$peer:$peerPw@localhost:$port --caname $ca -M ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls --enrollment.profile tls --csr.hosts $peerOrg --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    cp ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/ca.crt
    cp ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/signcerts/* ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/server.crt
    cp ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/keystore/* ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/server.key
    mkdir -p ${PWD}/network/organizations/peerOrganizations/$organization/msp/tlscacerts
    cp ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/$organization/msp/tlscacerts/ca.crt
    mkdir -p ${PWD}/network/organizations/peerOrganizations/$organization/tlsca
    cp ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/tls/tlscacerts/* ${PWD}/network/organizations/peerOrganizations/$organization/tlsca/tlsca.$organization-cert.pem
    mkdir -p ${PWD}/network/organizations/peerOrganizations/$organization/ca
    cp ${PWD}/network/organizations/peerOrganizations/$organization/peers/$peerOrg/msp/cacerts/* ${PWD}/network/organizations/peerOrganizations/$organization/ca/ca.$organization-cert.pem

}

createUser(){
    user=$1
    ca=$2
    organization=$3;
    port=$4

    userPw=$user'_'$organization
    userOrg=$userPw

    echo $userPw
    echo $user "--" $organization "--" $ca;

    # **********
    # Org: $organization
    # **********
    echo "####### Org: "$organization "#######"
    echo "=====> Create dir and set varialbes"
    mkdir -p ${PWD}/network/organizations/peerOrganizations/$organization/
    export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/$organization
    fabric-ca-client enroll -u https://admin:adminpw@localhost:$port --caname  $ca --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem

    echo "=====> Register user "$user"_"$organization" for "$organization
    fabric-ca-client register --caname $ca --id.name $userPw --id.secret $userPw --id.type client --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem > /dev/null
    
    status=$?
    if [ $status -eq 1 ]; then
        echo "User already exists"
        exit 1;
    elif [ $status -eq 2 ]; then
        echo "Misuse of shell builtins"
        exit 1;
    elif [ $status -eq 126 ]; then
        echo "Command invoked cannot execute"
        exit 1;
    elif [ $status -eq 128 ]; then
        echo "Invalid argument"
        exit 1;
    fi

    echo "=====> Generate the "$user"_"$organization"  msp for "$organization "(Enroll)"
    fabric-ca-client enroll -u https://$userOrg:$userPw@localhost:$port --caname $ca -M ${PWD}/network/organizations/peerOrganizations/$organization/users/$userOrg@$organization/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem

}

createAdmin(){
    user=$1
    ca=$2
    organization=$3;
    port=$4

    userPw=$user'_'$organization
    userOrg=$userPw

    echo $userPw
    echo $user "--" $organization "--" $ca;

    # **********
    # Org: $organization
    # **********
    echo "####### Org: "$organization "#######"
    echo "=====> Create dir and set varialbes"
    mkdir -p ${PWD}/network/organizations/peerOrganizations/$organization/
    export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/$organization
    fabric-ca-client enroll -u https://admin:adminpw@localhost:$port --caname  $ca --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem

    echo "=====> Register user "$user"_"$organization" for "$organization
    fabric-ca-client register --caname $ca --id.name $userPw --id.secret $userPw --id.type admin --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem > /dev/null
    
    status=$?
    if [ $status -eq 1 ]; then
        echo "User already exists"
        exit 1;
    elif [ $status -eq 2 ]; then
        echo "Misuse of shell builtins"
        exit 1;
    elif [ $status -eq 126 ]; then
        echo "Command invoked cannot execute"
        exit 1;
    elif [ $status -eq 128 ]; then
        echo "Invalid argument"
        exit 1;
    fi

    echo "=====> Generate the "$user"_"$organization"  msp for "$organization "(Enroll)"
    fabric-ca-client enroll -u https://$userOrg:$userPw@localhost:$port --caname $ca -M ${PWD}/network/organizations/peerOrganizations/$organization/users/$userOrg@$organization/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem

}

createOrdererUser(){

    ca=$1
    organization=$2;
    port=$3

    ordererOrg=orderer.$organization

    echo $ordererOrg "--" $organization "--" $ca;
    
    # **********
    # Org: orderer.ebsi.eu
    # **********
    echo "####### Org: orderer.ebsi.eu #######"
    echo "=====> Create dir and set varialbes"
    mkdir -p ${PWD}/network/organizations/ordererOrganizations/$organization
    export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/ordererOrganizations/$organization
   
    echo "=====> Enroll the CA admin for orderer.ebsi.eu"
    fabric-ca-client enroll -u https://admin:adminpw@localhost:$port --caname  $ca --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    # Copy the source: from local \network\organizations\ordererOrganizations\ebsi.eu\msp\config.yaml to target: ${PWD}/network/organizations/ordererOrganizations/$organization/msp
    
    echo "=====> Register orderer  for orderer.ebsi.eu"
    fabric-ca-client register --caname $ca --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    
    echo "=====> Register the orderer admin  for orderer.ebsi.eu"
    fabric-ca-client register --caname $ca --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    mkdir -p  ${PWD}/network/organizations/ordererOrganizations/$organization/orderers
    mkdir -p  ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$organization
    mkdir -p  ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg
   
    echo "=====> Generate the orderer msp"
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:$port --caname $ca -M ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/msp --csr.hosts $ordererOrg --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/msp/config.yaml ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/msp/config.yaml
    
    echo "=====> Generate the orderer-tls certificates"
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:$port --caname $ca -M ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls --enrollment.profile tls --csr.hosts $ordererOrg --csr.hosts localhost --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/tlscacerts/* ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/ca.crt
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/signcerts/* ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/server.crt
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/keystore/* ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/server.key
    mkdir -p ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/msp/tlscacerts
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/tlscacerts/* ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/msp/tlscacerts/tlsca.$organization-cert.pem
    mkdir -p ${PWD}/network/organizations/ordererOrganizations/$organization/msp/tlscacerts
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/orderers/$ordererOrg/tls/tlscacerts/* ${PWD}/network/organizations/ordererOrganizations/$organization/msp/tlscacerts/tlsca.$organization-cert.pem
    mkdir -p ${PWD}/network/organizations/ordererOrganizations/$organization/users
    
    echo "=====> Generate the admin msp"
    fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:$port --caname $ca -M ${PWD}/network/organizations/ordererOrganizations/$organization/users/Admin@$organization/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem
    cp ${PWD}/network/organizations/ordererOrganizations/$organization/msp/config.yaml ${PWD}/network/organizations/ordererOrganizations/$organization/users/Admin@$organization/msp/config.yaml

}

helpFunction()
{
   echo ""
   echo "Usage: $0 -o organization -c caname -u 'user_1 user_2' -t user -p 7054"
   echo -o "Organization"
   echo -c "Caname"
   echo -u "String Array with Users"
   echo -t "Type of registration: user / peer / orgadmin"
   echo -p "Port of CA"
   exit 1 # Exit script after printing help
}

while getopts o:c:d:u:t:p: flag
do
    case "${flag}" in
        o) organization=${OPTARG};;
        c) ca=${OPTARG};;
        u) users=${OPTARG};;
        t) type=${OPTARG};;
        p) port=${OPTARG};;
    esac
done

# Print helpFunction in case parameters are empty
if [ -z "$type" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Print helpFunction in case parameters are empty
if [[ "$type" == "user" ]]
    then
    # Print helpFunction in case parameters are empty
    if [ -z "$organization" ] || [ -z "$ca" ] || [ -z "$users" ] || [ -z "$port" ]
    then
    echo "Some or all of the parameters are empty";
    helpFunction
    fi


    IFS=' ' read -ra my_array <<< "$users"

    #Print the split string
    for user in "${my_array[@]}"
    do
        echo $user
        createUser $user $ca $organization $port
    done
elif [[ "$type" == "admin" ]]
then
    # Print helpFunction in case parameters are empty
    if [ -z "$organization" ] || [ -z "$ca" ] || [ -z "$users" ] || [ -z "$port" ]
    then
    echo "Some or all of the parameters are empty";
    helpFunction
    fi


    IFS=' ' read -ra my_array <<< "$users"

    #Print the split string
    for user in "${my_array[@]}"
    do
        echo $user
        createAdmin $user $ca $organization $port
    done
elif [[ "$type" == "peer" ]]
then
    # Print helpFunction in case parameters are empty
    if [ -z "$organization" ] || [ -z "$ca" ] || [ -z "$users" ] || [ -z "$port" ]
    then
    echo "Some or all of the parameters are empty";
    helpFunction
    fi


    IFS=' ' read -ra my_array <<< "$users"

    #Print the split string
    for peer in "${my_array[@]}"
    do
        echo $peer
        createPeer $peer $ca $organization $port
    done
elif [[ "$type" == "orderer" ]]
then
    # Print helpFunction in case parameters are empty
    if [ -z "$organization" ] || [ -z "$ca" ] || [ -z "$port" ]
    then
    echo "Some or all of the parameters are empty";
    helpFunction
    fi

    createOrdererUser $ca $organization $port
    
else
    echo "Wrong type"
fi

