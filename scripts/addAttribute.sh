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



addAttribute(){
    user=$1
    password=$2
    ca=$3
    organization=$4;
    port=$5
    attribute=$6

    userPw=$user'_'$organization
    userOrg=$userPw

    echo $userPw
    echo $user "--" $organization "--" $ca;

    # **********
    # Org: $organization
    # **********
    echo "####### Org: "$organization "#######"
    export FABRIC_CA_CLIENT_HOME=${PWD}/network/organizations/peerOrganizations/$organization
    fabric-ca-client enroll -u https://admin:adminpw@localhost:$port --caname  $ca --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem

    echo "=====> Modify user "$user" for "$organization
    fabric-ca-client register --caname $ca --id.name $userPw --id.secret $userPw --id.type client --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem > /dev/null
    fabric-ca-client identity modify $user --id.attrs $attribute --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem > /dev/null

    status=$?
    if [ $status -eq 1 ]; then
        echo "Something went wrong"
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
    fabric-ca-client enroll -u https://$user:$password@localhost:$port --caname $ca -M ${PWD}/network/organizations/peerOrganizations/$organization/users/$user@$organization/msp --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem

    fabric-ca-client identity list --id $user --tls.certfiles ${PWD}/network/organizations/fabric-ca/$organization/tls-cert.pem 

}


helpFunction()
{
   echo ""
   echo "Usage: $0 -o organization -c caname -u user_1 -a 'role='admin'' -p 7054"
   echo -o "Organization"
   echo -c "Caname"
   echo -u "Username"
   echo -p "Password of the user"
   echo -a "String with the Attribute withouth spaces"
   echo -i "Port of CA"
   exit 1 # Exit script after printing help
}

while getopts o:c:u:p:a:i: flag
do
    case "${flag}" in
        o) organization=${OPTARG};;
        c) ca=${OPTARG};;
        u) user=${OPTARG};;
        p) password=${OPTARG};;
        a) attribute=${OPTARG};;
        i) port=${OPTARG};;
    esac
done


# Print helpFunction in case parameters are empty
if [ -z "$organization" ] || [ -z "$ca" ] || [ -z "$user" ] || [ -z "$password" ] || [ -z "$port" ] || [ -z "$attribute" ]
    then
    echo "Some or all of the parameters are empty";
        helpFunction
    fi
        echo $user
        addAttribute $user $password $ca $organization $port $attribute
