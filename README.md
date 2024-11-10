# blockchain-group-project
NFTSwap - Solidity 103
This repository contains the source code and documentation for the NFTSwap contract, a decentralized application (dApp) that allows users to swap their NFTs with each other. This project is part of the WTF Academy Solidity 103 series.

## content
- [Overview](#Overview)
- [Features](#Features)
- [Prerequisites](#Prerequisites)
- [Installation](#Installation)
- [Usage](#Usage)
- [ContractDetails](#ContractDetails)

## Overview
NFTSwap is a smart contract built with Solidity that facilitates the swapping of NFTs (Non-Fungible Tokens) between users. This contract ensures that the swap process is secure and atomic, meaning that both parties must agree to the swap for it to succeed. If either party changes their mind before the swap is finalized, the transaction is aborted.

## Features
Atomic Swaps: Ensures that either both NFTs are swapped or none are, preventing partial transfers.
Secure Transactions: Utilizes Solidity's security features to ensure safe and trustless exchanges.
Easy Integration: Can be easily integrated into existing NFT marketplaces or used as a standalone contract.

## Prerequisites
Before you begin, ensure you have met the following requirements:
Installed Node.js (version 12 or higher)
Installed Truffle and Ganache
A basic understanding of Solidity and smart contract development

## Installation
1.Clone the repository:
git clone https://github.com/yourusername/NFTSwap.git
cd NFTSwap

2.Install dependencies:
npm install

3.Compile the smart contracts:
truffle compile

4.Migrate the smart contracts to the local blockchain:
truffle migrate

5.Run tests:
bash
truffle test

## Usage
To use the NFTSwap contract, follow these steps:

1.Deploy the contract: Ensure you have migrated the contract to your blockchain network as shown in the installation steps.

2.Interact with the contract: You can use Truffle Console, Remix IDE, or a frontend application to interact with the deployed contract.

3.Perform a Swap:
Call the function to start a swap process.initiateSwap
The second party needs to call the function to agree to the swap.acceptSwap
If either party calls the function before the swap is accepted, the swap will be aborted.cancelSwap


## Contract Details
1.Functions
initiateSwap(address _to, uint256 _tokenId1, uint256 _tokenId2):
Initiates a swap request from the caller to address , proposing to swap for ._to_tokenId1_tokenId2
acceptSwap(uint256 _swapId): Accepts a swap request identified by ._swapId
cancelSwap(uint256 _swapId): Cancels a swap request identified by ._swapId

2.Events
SwapInitiated(address indexed from, address indexed to, uint256 tokenId1, uint256 tokenId2, uint256 swapId): Emitted when a swap is initiated.
SwapAccepted(uint256 indexed swapId): Emitted when a swap is accepted.
SwapCancelled(uint256 indexed swapId): Emitted when a swap is cancelled.

