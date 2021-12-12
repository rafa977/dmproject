/*
*/

package main

import (
	"fmt"
	"github.com/hyperledger/fabric-chaincode-go/shim"
)

func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
