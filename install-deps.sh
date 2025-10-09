#!/bin/bash

# Install OpenZeppelin contracts for Foundry
echo "Installing OpenZeppelin contracts..."
forge install OpenZeppelin/openzeppelin-contracts@v4.9.0 --no-commit

echo "Dependencies installed successfully!"
echo "Run 'forge build' to compile the contracts."
