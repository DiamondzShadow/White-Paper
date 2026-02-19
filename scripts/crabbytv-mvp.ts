import { ethers } from "ethers"

const CRABBY_TV_MVP_ABI = [
  "function registerCreatorFor(address creator, string creatorId, string handle) external",
  "function recordMilestone(address creator, uint8 metricType, uint256 threshold, uint256 actualValue, uint256 observedAt, uint8 validationConfidence, bytes32 proofHash) external returns (uint256)",
  "function verifyMilestone(uint256 milestoneId) external",
  "function getCreatorProgress(address creator) external view returns (uint256 sparks, uint256 pending, uint256 cPoints, uint256 beats, uint256 wavzScore, uint256 averageConfidence)",
]

export enum CrabbyMetricType {
  FOLLOWERS = 0,
  VIEWS = 1,
  WATCH_HOURS = 2,
  CONTENT_COUNT = 3,
  ENGAGEMENT = 4,
}

export type CrabbyMilestoneInput = {
  creatorAddress: string
  metricType: CrabbyMetricType
  threshold: number
  actualValue: number
  observedAtUnix: number
  validationConfidence: number
  proofHashHex: string
}

export async function registerCrabbyCreator(
  contractAddress: string,
  creatorAddress: string,
  creatorId: string,
  handle: string,
): Promise<string> {
  const contract = await getContract(contractAddress)
  const tx = await contract.registerCreatorFor(creatorAddress, creatorId, handle, { gasLimit: 300000 })
  await tx.wait()
  return tx.hash
}

export async function recordCrabbyMilestone(
  contractAddress: string,
  milestone: CrabbyMilestoneInput,
): Promise<{ txHash: string; milestoneId?: string }> {
  const contract = await getContract(contractAddress)

  const tx = await contract.recordMilestone(
    milestone.creatorAddress,
    milestone.metricType,
    milestone.threshold,
    milestone.actualValue,
    milestone.observedAtUnix,
    milestone.validationConfidence,
    milestone.proofHashHex,
    { gasLimit: 500000 },
  )

  const receipt = await tx.wait()

  // Parse milestone ID from the first event with an indexed uint256 argument.
  let milestoneId: string | undefined
  for (const log of receipt.logs ?? []) {
    try {
      const parsed = contract.interface.parseLog(log)
      if (parsed?.name === "MilestoneRecorded") {
        milestoneId = parsed.args?.milestoneId?.toString()
        break
      }
    } catch {
      // Ignore logs unrelated to this contract ABI.
    }
  }

  return { txHash: tx.hash, milestoneId }
}

export async function verifyCrabbyMilestone(
  contractAddress: string,
  milestoneId: number | string,
): Promise<string> {
  const contract = await getContract(contractAddress)
  const tx = await contract.verifyMilestone(milestoneId, { gasLimit: 250000 })
  await tx.wait()
  return tx.hash
}

export async function getCrabbyCreatorProgress(
  contractAddress: string,
  creatorAddress: string,
): Promise<{
  sparks: string
  pending: string
  cPoints: string
  beats: string
  wavzScore: string
  averageConfidence: string
}> {
  const contract = await getContract(contractAddress)
  const result = await contract.getCreatorProgress(creatorAddress)

  return {
    sparks: result.sparks.toString(),
    pending: result.pending.toString(),
    cPoints: result.cPoints.toString(),
    beats: result.beats.toString(),
    wavzScore: result.wavzScore.toString(),
    averageConfidence: result.averageConfidence.toString(),
  }
}

async function getContract(contractAddress: string) {
  if (!process.env.RPC_URL) {
    throw new Error("Missing RPC_URL env var")
  }
  if (!process.env.PRIVATE_KEY) {
    throw new Error("Missing PRIVATE_KEY env var")
  }

  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL)
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider)
  return new ethers.Contract(contractAddress, CRABBY_TV_MVP_ABI, wallet)
}
