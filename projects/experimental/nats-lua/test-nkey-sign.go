package main

import (
	"encoding/hex"
	"fmt"
	"os"

	"github.com/nats-io/nkeys"
)

func main() {
	// Your NKEY seed from the credentials file
	seedStr := "SUAI5HFFRWZ3RESJEFTHJQPU2P23O52A2H2P4BUIU3K73GLNTJQUFUWWKM"

	kp, err := nkeys.FromSeed([]byte(seedStr))
	if err != nil {
		fmt.Printf("Error creating keypair: %v\n", err)
		os.Exit(1)
	}

	// Test with the latest nonce from debug output
	nonce, err := hex.DecodeString("42c9f762a1a4ff58609051")
	if err != nil {
		fmt.Printf("Error decoding nonce: %v\n", err)
		os.Exit(1)
	}

	// Sign the nonce
	sig, err := kp.Sign(nonce)
	if err != nil {
		fmt.Printf("Error signing: %v\n", err)
		os.Exit(1)
	}

	// Get the public key
	pubKey, err := kp.PublicKey()
	if err != nil {
		fmt.Printf("Error getting public key: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Seed:      %s\n", seedStr)
	fmt.Printf("Public Key: %s\n", pubKey)
	fmt.Printf("Nonce hex:  %x\n", nonce)
	fmt.Printf("Nonce len:  %d bytes\n", len(nonce))
	fmt.Printf("Signature hex: %x\n", sig)
	fmt.Printf("Signature len: %d bytes\n", len(sig))

	// Also print what we got from Lua for comparison
	fmt.Printf("\n--- From Lua (for comparison) ---\n")
	fmt.Printf("Signature hex: 3a67eb560965984a7152cbd70c6c4fa7a7b15ff4c229544c35af2262bbd9a779bcec282bfb5da38034eb8c9dd3f5c0023e5e5124c3eebbc42177c457b726a40d\n")
}
