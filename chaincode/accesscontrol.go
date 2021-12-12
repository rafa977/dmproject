/* 
 This is the file of the chaincode that includes all functions.
 AUTHOR: Daniel Mengozzi
 Project: 
*/

package main

import (
	//"bytes"
	"encoding/json"
	//"fmt"
	//"strings"
	//"crypto/rand"
	//"io/ioutil"

	//"gopkg.in/yaml.v2"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	//"github.com/hyperledger/fabric-contract-api-go/contractapi"
	sc "github.com/hyperledger/fabric-protos-go/peer"

	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"

)

// Define the Smart Contract structure
type SmartContract struct {
}

// Define the Device structure
type Device struct {
	Title			string 		`json:"title"`
	Description   	string 		`json:"description"`
	AccessLevel 	string 		`json:"accessLevel"`
} 

/*
 * The Init method is called when the Smart Contract "accesscontrol" is instantiated by the blockchain network
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "accesscontrol"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "insertDevice" {
		return s.insertDevice(APIstub, args)
	} else if function == "getDevice" {
	   return s.getDevice(APIstub, args)
	} else if function == "accessDevice" {
		return s.accessDevice(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

/*
* Publish a new device
* This can be called only by users having the age property as Adult
*/
func (s *SmartContract) insertDevice(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	// check all args are provived
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3 args : Title, Description, Access Level (Adult, All)")
	}
	title := args[0]
	description := args[1]
	accessLevel := args[2]
	
	id, err := cid.New(APIstub)
    if err != nil {
    	return shim.Error("Error occured when trying to initiate the CID library: "+ err.Error())
    }
	
	// check that the user is Adult or Kid
	err = id.AssertAttributeValue("age", "Adult")
	if err != nil {
		return shim.Error("You have not the permission to add a device. You must be Adult: "+ err.Error())
	}

	// check that the device does not exist in the  WS ledger
	deviceValidityAsBytes, err := APIstub.GetState(title)

	// If the key does not exist in the state database, (nil, nil) is returned.
	if deviceValidityAsBytes != nil {
		return shim.Error("The provided device exists already in the WS ledger. ")
	}
	
	deviceToWs := Device{Title: title, Description: description, AccessLevel: accessLevel}
	
	deviceToWsBytes, err := json.Marshal(deviceToWs)
	if err != nil {
	   return shim.Error("Something wrong has happened.")
	}

	err = APIstub.PutState(title, deviceToWsBytes)
	if err != nil {
		return shim.Error("Error occured when trying to store device in WS ledger: "+err.Error())
	}

	return shim.Success(nil)
}

/*
* Get Device function is to get any device without the access control
*/
func (s *SmartContract) getDevice(APIstub shim.ChaincodeStubInterface, args []string) sc.Response{

   if len(args) != 1 {
			   return shim.Error("Incorrect arguments. Expecting an device to check")
			 }
	   
		 device := args[0]
	   
		 value, err := APIstub.GetState(device)
		 if err != nil {
			 return shim.Error("Failed to get device for key :"+ device)
		 }
		 if value == nil {
			 return shim.Error("device not found for key :"+ device)
		 }

		 return shim.Success(value)
	   
}

/*
* Access Device Function
* In the function the age attribute of the user calling, is getting validated when the device is retrieved from the WS
*/
func (s *SmartContract) accessDevice(APIstub shim.ChaincodeStubInterface, args []string) sc.Response{

	if len(args) != 1 {
		return shim.Error("Incorrect arguments. Expecting an device to check")
		}

	device := args[0]

	value, err := APIstub.GetState(device)
	if err != nil {
		return shim.Error("Failed to get device for key :"+ device)
	}
	if value == nil {
		return shim.Error("device not found for key :"+ device)
	}

	// Get the device for that record
	var qry_res_json Device
	json.Unmarshal([]byte(value), &qry_res_json)

	id, err := cid.New(APIstub)
    if err != nil {
    	return shim.Error("Error occured when trying to initiate the CID library: "+ err.Error())
    }
	
	// check that the user is Adult or Kid
	err = id.AssertAttributeValue("age", qry_res_json.AccessLevel)
	if err != nil {
		return shim.Error("You have not the permission to access this device: "+ err.Error())
	}

	return shim.Success([]byte("Hello "))
		
 }
