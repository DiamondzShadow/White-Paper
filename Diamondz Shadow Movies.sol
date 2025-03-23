// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title DiamondShadowMovies
 * @dev Implementation of the Diamondz Shadow Movies token on the Diamondz Shadow OP Stack blockchain
 * @custom:security-contact development@diamondzshadow.com
 */
contract DiamondShadowMovies is ERC20, ERC20Permit, ERC20Votes, ERC20Burnable, Ownable, Pausable {
    // Maximum supply cap
    uint256 public constant MAX_SUPPLY = 1_250_000_000 * 10**18;
    
    // Burn threshold - when this supply is reached, tokens will be burned from liquidity
    uint256 public constant BURN_THRESHOLD = 1_250_000_000 * 10**18;
    
    // Target supply after burn
    uint256 public constant TARGET_SUPPLY_AFTER_BURN = 750_000_000 * 10**18;
    
    // Liquidity pool addresses
    mapping(address => bool) public liquidityPools;
    
    // Contribution tracking
    mapping(address => uint256) public contributionScores;
    
    // Events
    event ContributionScoreUpdated(address indexed user, uint256 newScore);
    event LiquidityPoolAdded(address indexed pool);
    event LiquidityPoolRemoved(address indexed pool);
    event CyclicalBurnExecuted(uint256 amountBurned, uint256 newTotalSupply);
    
    /**
     * @dev Constructor that gives msg.sender all existing tokens.
     */
    constructor(address initialOwner) 
        ERC20("Diamondz Shadow Movies", "SDM") 
        ERC20Permit("Diamondz Shadow Movies")
        Ownable(initialOwner)
    {
        // Initial supply of 1 billion tokens
        _mint(initialOwner, 1_000_000_000 * 10**18);
    }
    
    /**
     * @dev Mints new tokens based on contribution.
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     * @param contributionAmount The contribution score to add
     */
    function mintWithContribution(address to, uint256 amount, uint256 contributionAmount) 
        external 
        onlyOwner 
        whenNotPaused 
    {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds maximum supply cap");
        
        _mint(to, amount);
        
        // Update contribution score
        contributionScores[to] += contributionAmount;
        emit ContributionScoreUpdated(to, contributionScores[to]);
        
        // Check if burn threshold is reached
        if (totalSupply() >= BURN_THRESHOLD) {
            _executeCyclicalBurn();
        }
    }
    
    /**
     * @dev Executes the cyclical burn when the maximum supply is reached.
     * Burns tokens only from liquidity pools to reduce supply to target level.
     */
    function _executeCyclicalBurn() internal {
        uint256 amountToBurn = totalSupply() - TARGET_SUPPLY_AFTER_BURN;
        uint256 burnedSoFar = 0;
        
        // Pause token transfers during burn
        _pause();
        
        // Burn from liquidity pools
        address[] memory pools = _getLiquidityPools();
        for (uint256 i = 0; i < pools.length && burnedSoFar < amountToBurn; i++) {
            address pool = pools[i];
            uint256 poolBalance = balanceOf(pool);
            
            uint256 burnAmount = poolBalance;
            if (burnedSoFar + burnAmount > amountToBurn) {
                burnAmount = amountToBurn - burnedSoFar;
            }
            
            if (burnAmount > 0) {
                _burn(pool, burnAmount);
                burnedSoFar += burnAmount;
            }
        }
        
        // Unpause token transfers
        _unpause();
        
        emit CyclicalBurnExecuted(burnedSoFar, totalSupply());
    }
    
    /**
     * @dev Returns an array of all registered liquidity pool addresses.
     */
    function _getLiquidityPools() internal view returns (address[] memory) {
        uint256 count = 0;
        
        // Count liquidity pools
        for (uint256 i = 0; i < 1000; i++) { // Arbitrary limit to prevent gas issues
            address account = address(uint160(i + 1)); // Start from address 1
            if (!liquidityPools[account]) break;
            count++;
        }
        
        address[] memory pools = new address[](count);
        
        // Fill array with liquidity pools
        for (uint256 i = 0; i < count; i++) {
            address account = address(uint160(i + 1));
            pools[i] = account;
        }
        
        return pools;
    }
    
    /**
     * @dev Adds a liquidity pool address.
     * @param pool The address of the liquidity pool
     */
    function addLiquidityPool(address pool) external onlyOwner {
        require(pool != address(0), "Invalid pool address");
        liquidityPools[pool] = true;
        emit LiquidityPoolAdded(pool);
    }
    
    /**
     * @dev Removes a liquidity pool address.
     * @param pool The address of the liquidity pool
     */
    function removeLiquidityPool(address pool) external onlyOwner {
        require(liquidityPools[pool], "Not a registered pool");
        liquidityPools[pool] = false;
        emit LiquidityPoolRemoved(pool);
    }
    
    /**
     * @dev Updates a user's contribution score.
     * @param user The address of the user
     * @param newScore The new contribution score
     */
    function updateContributionScore(address user, uint256 newScore) external onlyOwner {
        contributionScores[user] = newScore;
        emit ContributionScoreUpdated(user, newScore);
    }
    
    /**
     * @dev Pauses all token transfers.
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpauses all token transfers.
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Hook that is called before any transfer of tokens.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    /**
     * @dev Hook that is called after any transfer of tokens.
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }
    
    /**
     * @dev Hook that is called before minting tokens.
     */
    function _mint(address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }
    
    /**
     * @dev Hook that is called before burning tokens.
     */
    function _burn(address account, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
