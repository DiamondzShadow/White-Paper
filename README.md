# Diamondz Shadow Movies Token

A sophisticated ERC677 token implementation with burn/mint capabilities, designed for cross-chain transfers via Chainlink CCIP.

## Features

- **ERC677 Standard**: Extended ERC20 with `transferAndCall` functionality
- **Role-Based Access Control**: Separate minter and burner roles
- **Supply Management**: 4 billion initial supply, 5 billion maximum supply cap
- **Chainlink CCIP Compatible**: Built for seamless cross-chain token transfers
- **Gamification Events**: Enhanced tracking and milestone events
- **OpenZeppelin Security**: Built on industry-standard, audited contracts

## Token Specifications

- **Initial Supply**: 4,000,000,000 tokens (4 billion)
- **Maximum Supply**: 5,000,000,000 tokens (5 billion)
- **Decimals**: 18
- **Standard**: ERC677 (ERC20 + transferAndCall)

## Project Structure

```
.
├── src/
│   ├── interfaces/
│   │   ├── IERC677.sol           # ERC677 interface
│   │   └── IERC677Receiver.sol   # Receiver interface
│   └── tokens/
│       └── BurnMintERC677.sol    # Main token contract
├── foundry.toml                   # Foundry configuration
├── remappings.txt                 # Import remappings
└── README.md
```

## Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1. Clone the repository
2. Install dependencies:

```bash
forge install OpenZeppelin/openzeppelin-contracts@v4.9.0
```

### Compile

```bash
forge build
```

### Test

```bash
forge test
```

## Contract Overview

### BurnMintERC677

The main token contract implementing:

- **Minting**: Only authorized minters can create new tokens (up to max supply)
- **Burning**: Only authorized burners can destroy tokens
- **Cross-Chain Minting**: Special function for CCIP cross-chain mints with metadata
- **Gamification**: Tracks total minted per address and emits milestone events

### Key Functions

#### Minting
- `mint(address account, uint256 amount)`: Mint tokens to an address
- `mintWithCCIPData(...)`: Mint with cross-chain metadata

#### Burning
- `burn(uint256 amount)`: Burn tokens from caller
- `burnFrom(address account, uint256 amount)`: Burn tokens from another address

#### Access Control
- `grantMintRole(address minter)`: Grant minting permission
- `revokeMintRole(address minter)`: Revoke minting permission
- `grantBurnRole(address burner)`: Grant burning permission
- `revokeBurnRole(address burner)`: Revoke burning permission

#### ERC677
- `transferAndCall(address to, uint256 amount, bytes data)`: Transfer tokens and call recipient

## Security

- Built on OpenZeppelin v4.9.0 contracts
- Role-based access control with owner management
- Maximum supply cap prevents over-minting
- Custom errors for gas-efficient reverts

## License

MIT
