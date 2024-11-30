# Enhanced Stacks Music and Art Royalty NFT Contract

## Overview
The Enhanced Stacks Music and Art Royalty NFT Contract is a comprehensive smart contract for creating, managing, and trading non-fungible tokens (NFTs) on the Stacks blockchain. Designed specifically for artists, musicians, and creators, it integrates dynamic royalty distribution, marketplace listing, and approval mechanisms. The contract ensures creators are rewarded fairly for their work with royalties on secondary sales, while buyers and sellers can securely trade NFTs in a decentralized marketplace.

## Features
1. **Minting NFTs**
    - **Mint Single NFT**: Allows a creator to mint a new NFT with attached metadata and a specified royalty percentage (up to 50%).
    - **Batch Minting**: Enables minting multiple NFTs in a single transaction for efficiency.
2. **Royalty Management**
    - Automatically calculates and distributes royalties to the original creator upon transfer.
    - Creator information, royalty percentage, and metadata are stored immutably.
3. **NFT Marketplace**
    - **List for Sale**: Allows NFT owners to list their tokens for sale at a specified price.
    - **Delist NFT**: Owners can remove their NFTs from the marketplace.
    - **Retrieve Listing Details**: Buyers can view sale details of listed NFTs.
4. **Token Transfer**
    - Supports secure transfers between users.
    - Distributes royalties to the creator upon each sale.
    - Includes approval mechanisms for operators to transfer tokens on behalf of the owner.
5. **Approval Mechanism**
    - Token owners can approve operators to manage their NFTs.
    - Only the owner or approved operator can transfer an NFT.
6. **Dynamic Pricing (Placeholder)**
    - Placeholder logic for dynamic pricing. This can be integrated with an oracle for real-time pricing data.

## Smart Contract Structure
### Constants
- **Contract Ownership**: Defines contract-owner as the deployer.
- **Error Codes**: Predefined error constants for common issues like unauthorized access, invalid royalty, etc.

### Data Structures
- **royalty-nft**: Non-fungible token representing the unique NFTs.
- **royalty-percentage Map**: Stores metadata, creator information, and royalty percentages.
- **token-approvals Map**: Tracks approved operators for each token.
- **market-listings Map**: Holds active marketplace listings for NFTs.
- **token-count Variable**: Maintains the total count of minted tokens.

### Key Functions
#### Public Functions
- **mint-nft**: Mint a single NFT with metadata and royalty percentage.
- **batch-mint**: Batch minting of NFTs.
- **approve**: Approve an operator for a specific NFT.
- **list-nft**: List an NFT for sale.
- **delist-nft**: Remove an NFT from the marketplace.
- **transfer**: Transfer an NFT and distribute royalties.

#### Private Functions
- **is-transfer-approved**: Checks if a token transfer is approved.
- **get-last-sale-price**: Placeholder for retrieving the last sale price.
- **mint-single-nft**: Helper function for batch minting.

#### Read-Only Functions
- **get-royalty-info**: Retrieve royalty information for a specific NFT.
- **get-total-nfts**: View the total number of minted NFTs.
- **get-token-owner**: Check the current owner of an NFT.
- **get-listing-details**: View marketplace details for a listed NFT.

## Usage Instructions
### Deployment
- **Deploy the Contract**: Deploy the smart contract using a Stacks-compatible development environment like Clarinet or Hiro Wallet.
- **Set Contract Owner**: The deployer becomes the contract-owner.

### Minting NFTs
- **Mint a Single NFT**:
  ```clarity
  (mint-nft "NFT Metadata" u10) ;; Metadata and 10% royalty
  ```
- **Batch Mint NFTs**:
  ```clarity
  (batch-mint ["NFT 1 Metadata" "NFT 2 Metadata"] [u10 u15])
  ```

### Listing and Selling
- **List an NFT for Sale**:
  ```clarity
  (list-nft u1 u5000) ;; List token ID 1 for 5000 micro-STX
  ```
- **Delist an NFT**:
  ```clarity
  (delist-nft u1) ;; Delist token ID 1
  ```

### Transferring NFTs
- **Transfer an NFT**:
  ```clarity
  (transfer u1 tx-sender recipient-principal)
  ```

### Querying Data
- **Get Royalty Info**:
  ```clarity
  (get-royalty-info u1)
  ```
- **Get Total NFTs**:
  ```clarity
  (get-total-nfts)
  ```

## Error Codes
| Error Code | Description                     |
|------------|---------------------------------|
| u100       | Owner-only operation.           |
| u101       | Insufficient funds.             |
| u102       | Invalid royalty percentage.     |
| u103       | Token not approved for transfer.|
| u104       | Token not found.                |

## Future Enhancements
- **Dynamic Pricing Oracle**: Integrate real-time price feeds.
- **Auction Mechanism**: Add bidding and auction functionality.
- **Enhanced Metadata Storage**: Support IPFS or other decentralized storage for metadata.
