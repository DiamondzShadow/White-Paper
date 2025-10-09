import { ethers } from "ethers"
import type { MilestoneEvent } from "@/types/youtube"

// ABI for the token contract (simplified to include only what we need)
const TOKEN_CONTRACT_ABI = [
  "function mint(address to, uint256 amount, bytes data) external payable",
  "function name() external view returns (string)",
  "function symbol() external view returns (string)",
]

/**
 * Record a milestone event on the blockchain and mint a token reward
 */
export async function recordMilestoneOnChain(milestone: MilestoneEvent): Promise<string> {
  try {
    console.log(`Recording milestone on chain: ${milestone.type} - ${milestone.threshold}`)

    // Initialize provider and signer
    const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL)
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider)

    // Connect to the token contract
    const tokenContract = new ethers.Contract(
      "0x2eEe2880F8bC24aeBad3B3c22Dd7541c7D846676", // Your provided token address
      TOKEN_CONTRACT_ABI,
      wallet,
    )

    // Get token details
    const tokenName = await tokenContract.name()
    const tokenSymbol = await tokenContract.symbol()
    console.log(`Connected to token: ${tokenName} (${tokenSymbol})`)

    // Prepare milestone data for the token metadata
    const milestoneData = ethers.utils.defaultAbiCoder.encode(
      ["string", "string", "uint256", "uint256", "uint256", "uint8"],
      [
        milestone.metrics.channelId,
        milestone.type,
        milestone.threshold,
        milestone.type === "subscribers" ? milestone.metrics.subscriberCount : milestone.metrics.viewCount,
        Math.floor(milestone.timestamp / 1000),
        Math.floor(milestone.validationResult!.confidence * 100),
      ],
    )

    // Calculate token amount based on milestone type and threshold
    // This is a simple example - you can customize this logic
    const tokenAmount = calculateTokenReward(milestone)

    // Get the user's wallet address from the request or database
    // For this example, we'll use the admin wallet, but in production
    // you would get the user's wallet address
    const recipientAddress = process.env.RECIPIENT_ADDRESS || wallet.address

    // Mint tokens to the recipient
    const tx = await tokenContract.mint(recipientAddress, tokenAmount, milestoneData, {
      gasLimit: 300000, // Adjust as needed
    })

    console.log(`Token minting transaction submitted: ${tx.hash}`)

    // Wait for transaction confirmation
    const receipt = await tx.wait()
    console.log(`Tokens minted successfully. Transaction confirmed in block ${receipt.blockNumber}`)

    return tx.hash
  } catch (error) {
    console.error("Error minting tokens for milestone:", error)
    throw error
  }
}

/**
 * Calculate token reward amount based on milestone
 */
function calculateTokenReward(milestone: MilestoneEvent): ethers.BigNumber {
  // Base reward amount
  let baseReward = 0

  // Adjust reward based on milestone type and threshold
  switch (milestone.type) {
    case "subscribers":
      // Higher rewards for subscriber milestones
      if (milestone.threshold >= 10000) baseReward = 1000
      else if (milestone.threshold >= 5000) baseReward = 500
      else if (milestone.threshold >= 1000) baseReward = 100
      else if (milestone.threshold >= 500) baseReward = 50
      else if (milestone.threshold >= 100) baseReward = 20
      else baseReward = 10
      break

    case "views":
      // Rewards for view milestones
      if (milestone.threshold >= 100000) baseReward = 500
      else if (milestone.threshold >= 50000) baseReward = 250
      else if (milestone.threshold >= 10000) baseReward = 100
      else if (milestone.threshold >= 5000) baseReward = 50
      else baseReward = 10
      break

    case "videos":
      // Rewards for video count milestones
      baseReward = milestone.threshold * 5
      break

    default:
      baseReward = 10
  }

  // Convert to token amount with 18 decimals (adjust if your token uses different decimals)
  return ethers.utils.parseUnits(baseReward.toString(), 18)
}

/**
 * Check if a user has received a milestone token
 */
export async function hasReceivedMilestoneToken(
  userAddress: string,
  channelId: string,
  milestoneType: string,
  threshold: number,
): Promise<boolean> {
  try {
    // This would require additional logic to check if a specific milestone token
    // has been minted to the user. This could be done by:
    // 1. Checking token transfer events
    // 2. Using a separate tracking mechanism in your database
    // 3. Adding a function to your token contract to check this

    // For now, we'll return a placeholder implementation
    return false
  } catch (error) {
    console.error("Error checking if user has received milestone token:", error)
    return false
  }
}
