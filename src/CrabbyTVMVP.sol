// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ICrabbyRewardToken {
    function mint(address account, uint256 amount) external;
}

/**
 * @title CrabbyTVMVP
 * @notice Echo Creator Nest MVP for CrabbyTV social milestone validation.
 * @dev Tracks creator milestones and progression:
 *      Sparks -> cPoints -> Beats -> Wavz score.
 */
contract CrabbyTVMVP is Ownable, Pausable, ReentrancyGuard {
    enum MetricType {
        FOLLOWERS,
        VIEWS,
        WATCH_HOURS,
        CONTENT_COUNT,
        ENGAGEMENT
    }

    struct CreatorProfile {
        string creatorId;
        string handle;
        uint256 createdAt;
        uint256 verifiedMilestones;
        uint256 cumulativeConfidence;
        bool active;
    }

    struct Milestone {
        address creator;
        MetricType metricType;
        uint256 threshold;
        uint256 actualValue;
        uint256 timestamp;
        uint8 validationConfidence;
        bool verified;
        bool rejected;
        bytes32 proofHash;
        uint256 sparkUnits;
        uint256 rewardAmount;
    }

    error ZeroAddress();
    error EmptyValue();
    error InvalidMetricType();
    error InvalidConfidence();
    error InvalidMilestone();
    error DuplicateMilestone();
    error UnauthorizedOracle();
    error CreatorNotActive();
    error InvalidBasisPoints();
    error AlreadyProcessed();

    event OracleUpdated(address indexed oracle, bool enabled);
    event RewardTokenUpdated(address indexed oldToken, address indexed newToken);
    event RewardsEnabledUpdated(bool enabled);
    event BaseRewardUpdated(uint256 oldAmount, uint256 newAmount);
    event AutoVerifyConfidenceUpdated(uint8 oldConfidence, uint8 newConfidence);
    event MetricRewardBpsUpdated(MetricType indexed metricType, uint256 oldBps, uint256 newBps);

    event CreatorRegistered(address indexed creator, string creatorId, string handle, uint256 timestamp);
    event CreatorStatusUpdated(address indexed creator, bool active);

    event MilestoneRecorded(
        uint256 indexed milestoneId,
        address indexed creator,
        MetricType metricType,
        uint256 threshold,
        uint256 actualValue,
        uint256 timestamp,
        uint8 validationConfidence,
        bytes32 proofHash,
        bool autoVerified
    );
    event MilestoneVerified(uint256 indexed milestoneId, address indexed verifier);
    event MilestoneRejected(uint256 indexed milestoneId, address indexed verifier);

    event ProgressUpdated(
        address indexed creator,
        uint256 totalSparks,
        uint256 pendingSparks,
        uint256 cPoints,
        uint256 beats
    );
    event RewardMinted(address indexed creator, uint256 indexed milestoneId, uint256 rewardAmount);
    event RewardMintFailed(address indexed creator, uint256 indexed milestoneId, uint256 rewardAmount);

    uint256 public constant BASIS_POINTS = 10_000;
    uint256 public constant SPARKS_PER_CPOINT = 10;
    uint256 public constant CPOINTS_PER_BEAT = 100;

    // Reward token is expected to be a mint-authorized token (e.g. BurnMintERC677).
    address public rewardToken;
    bool public rewardsEnabled;
    uint256 public baseRewardPerSpark;
    uint8 public autoVerifyConfidence;

    uint256 public milestoneCount;

    mapping(address => bool) public isOracle;
    mapping(address => CreatorProfile) public creators;
    mapping(address => uint256[]) private creatorMilestoneIds;
    mapping(uint256 => Milestone) public milestones;
    mapping(bytes32 => bool) public seenMilestones;

    mapping(uint8 => uint256) public metricRewardBps;
    mapping(address => uint256) public totalSparks;
    mapping(address => uint256) public pendingSparks;
    mapping(address => uint256) public unconvertedSparks;
    mapping(address => uint256) public cPointsBalance;
    mapping(address => uint256) public cPointsCommittedForBeats;
    mapping(address => uint256) public beatsBalance;

    modifier onlyOracleOrOwner() {
        if (msg.sender != owner() && !isOracle[msg.sender]) revert UnauthorizedOracle();
        _;
    }

    constructor(address initialRewardToken, uint256 initialBaseRewardPerSpark) {
        rewardToken = initialRewardToken;
        baseRewardPerSpark = initialBaseRewardPerSpark;
        autoVerifyConfidence = 95;
        rewardsEnabled = initialRewardToken != address(0);

        // Default reward multipliers by metric.
        metricRewardBps[uint8(MetricType.FOLLOWERS)] = 10_000;
        metricRewardBps[uint8(MetricType.VIEWS)] = 7_500;
        metricRewardBps[uint8(MetricType.WATCH_HOURS)] = 9_000;
        metricRewardBps[uint8(MetricType.CONTENT_COUNT)] = 8_000;
        metricRewardBps[uint8(MetricType.ENGAGEMENT)] = 11_000;
    }

    function registerCreator(string calldata creatorId, string calldata handle) external whenNotPaused {
        _registerCreator(msg.sender, creatorId, handle);
    }

    function registerCreatorFor(address creator, string calldata creatorId, string calldata handle)
        external
        onlyOwner
        whenNotPaused
    {
        _registerCreator(creator, creatorId, handle);
    }

    function setCreatorStatus(address creator, bool active) external onlyOwner {
        if (creator == address(0)) revert ZeroAddress();
        if (bytes(creators[creator].creatorId).length == 0) revert CreatorNotActive();
        creators[creator].active = active;
        emit CreatorStatusUpdated(creator, active);
    }

    function setOracle(address oracle, bool enabled) external onlyOwner {
        if (oracle == address(0)) revert ZeroAddress();
        isOracle[oracle] = enabled;
        emit OracleUpdated(oracle, enabled);
    }

    function setRewardToken(address newRewardToken) external onlyOwner {
        address oldToken = rewardToken;
        rewardToken = newRewardToken;
        emit RewardTokenUpdated(oldToken, newRewardToken);
    }

    function setRewardsEnabled(bool enabled) external onlyOwner {
        rewardsEnabled = enabled;
        emit RewardsEnabledUpdated(enabled);
    }

    function setBaseRewardPerSpark(uint256 newBaseRewardPerSpark) external onlyOwner {
        uint256 old = baseRewardPerSpark;
        baseRewardPerSpark = newBaseRewardPerSpark;
        emit BaseRewardUpdated(old, newBaseRewardPerSpark);
    }

    function setAutoVerifyConfidence(uint8 newConfidence) external onlyOwner {
        if (newConfidence > 100) revert InvalidConfidence();
        uint8 old = autoVerifyConfidence;
        autoVerifyConfidence = newConfidence;
        emit AutoVerifyConfidenceUpdated(old, newConfidence);
    }

    function setMetricRewardBps(uint8 metricType, uint256 newBps) external onlyOwner {
        if (metricType > uint8(MetricType.ENGAGEMENT)) revert InvalidMetricType();
        if (newBps > 20_000) revert InvalidBasisPoints();
        uint256 old = metricRewardBps[metricType];
        metricRewardBps[metricType] = newBps;
        emit MetricRewardBpsUpdated(MetricType(metricType), old, newBps);
    }

    function quoteReward(uint8 metricType, uint256 threshold, uint8 validationConfidence)
        public
        view
        returns (uint256 sparkUnits, uint256 rewardAmount)
    {
        if (metricType > uint8(MetricType.ENGAGEMENT)) revert InvalidMetricType();
        if (validationConfidence > 100) revert InvalidConfidence();
        if (threshold == 0) revert InvalidMilestone();

        sparkUnits = _deriveSparkUnits(MetricType(metricType), threshold);
        uint256 metricBps = metricRewardBps[metricType];
        rewardAmount = (baseRewardPerSpark * sparkUnits * metricBps) / BASIS_POINTS;
        rewardAmount = (rewardAmount * validationConfidence) / 100;
    }

    function recordMilestone(
        address creator,
        uint8 metricType,
        uint256 threshold,
        uint256 actualValue,
        uint256 observedAt,
        uint8 validationConfidence,
        bytes32 proofHash
    ) external onlyOracleOrOwner whenNotPaused nonReentrant returns (uint256 milestoneId) {
        if (creator == address(0)) revert ZeroAddress();
        if (metricType > uint8(MetricType.ENGAGEMENT)) revert InvalidMetricType();
        if (validationConfidence > 100) revert InvalidConfidence();
        if (!creators[creator].active) revert CreatorNotActive();
        if (threshold == 0 || actualValue < threshold || observedAt == 0 || observedAt > block.timestamp) {
            revert InvalidMilestone();
        }

        bytes32 milestoneHash =
            keccak256(abi.encodePacked(creator, metricType, threshold, actualValue, observedAt, proofHash));
        if (seenMilestones[milestoneHash]) revert DuplicateMilestone();
        seenMilestones[milestoneHash] = true;

        (uint256 sparkUnits, uint256 rewardAmount) = quoteReward(metricType, threshold, validationConfidence);

        milestoneId = ++milestoneCount;
        Milestone storage item = milestones[milestoneId];
        item.creator = creator;
        item.metricType = MetricType(metricType);
        item.threshold = threshold;
        item.actualValue = actualValue;
        item.timestamp = observedAt;
        item.validationConfidence = validationConfidence;
        item.proofHash = proofHash;
        item.sparkUnits = sparkUnits;
        item.rewardAmount = rewardAmount;

        creatorMilestoneIds[creator].push(milestoneId);

        bool autoVerified = validationConfidence >= autoVerifyConfidence;
        if (autoVerified) {
            item.verified = true;
            _applyVerifiedMilestone(creator, milestoneId);
        } else {
            pendingSparks[creator] += sparkUnits;
        }

        emit MilestoneRecorded(
            milestoneId,
            creator,
            MetricType(metricType),
            threshold,
            actualValue,
            observedAt,
            validationConfidence,
            proofHash,
            autoVerified
        );
    }

    function verifyMilestone(uint256 milestoneId) external onlyOwner whenNotPaused nonReentrant {
        Milestone storage item = milestones[milestoneId];
        if (item.creator == address(0)) revert InvalidMilestone();
        if (item.verified || item.rejected) revert AlreadyProcessed();

        item.verified = true;
        _applyVerifiedMilestone(item.creator, milestoneId);
        emit MilestoneVerified(milestoneId, msg.sender);
    }

    function rejectMilestone(uint256 milestoneId) external onlyOwner whenNotPaused {
        Milestone storage item = milestones[milestoneId];
        if (item.creator == address(0)) revert InvalidMilestone();
        if (item.verified || item.rejected) revert AlreadyProcessed();

        item.rejected = true;
        uint256 pending = pendingSparks[item.creator];
        if (pending >= item.sparkUnits) {
            pendingSparks[item.creator] = pending - item.sparkUnits;
        } else {
            pendingSparks[item.creator] = 0;
        }
        emit MilestoneRejected(milestoneId, msg.sender);
        emit ProgressUpdated(
            item.creator,
            totalSparks[item.creator],
            pendingSparks[item.creator],
            cPointsBalance[item.creator],
            beatsBalance[item.creator]
        );
    }

    function getCreatorMilestoneIds(address creator) external view returns (uint256[] memory) {
        return creatorMilestoneIds[creator];
    }

    function getCreatorProgress(address creator)
        external
        view
        returns (
            uint256 sparks,
            uint256 pending,
            uint256 cPoints,
            uint256 beats,
            uint256 wavzScore,
            uint256 averageConfidence
        )
    {
        sparks = totalSparks[creator];
        pending = pendingSparks[creator];
        cPoints = cPointsBalance[creator];
        beats = beatsBalance[creator];
        wavzScore = getWavzScore(creator);

        CreatorProfile memory profile = creators[creator];
        if (profile.verifiedMilestones == 0) return (sparks, pending, cPoints, beats, wavzScore, 0);
        averageConfidence = profile.cumulativeConfidence / profile.verifiedMilestones;
    }

    function getWavzScore(address creator) public view returns (uint256) {
        uint256 sparks = totalSparks[creator];
        uint256 cPoints = cPointsBalance[creator];
        uint256 beats = beatsBalance[creator];
        if (sparks == 0 || cPoints == 0 || beats == 0) return 0;

        CreatorProfile memory profile = creators[creator];
        if (profile.verifiedMilestones == 0) return 0;

        uint256 avgConfidence = profile.cumulativeConfidence / profile.verifiedMilestones;
        // Wavz = Sparks × cPoints × Beats × confidence / 100
        return ((sparks * cPoints * beats) * avgConfidence) / 100;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _registerCreator(address creator, string calldata creatorId, string calldata handle) internal {
        if (creator == address(0)) revert ZeroAddress();
        if (bytes(creatorId).length == 0 || bytes(handle).length == 0) revert EmptyValue();

        CreatorProfile storage profile = creators[creator];
        profile.creatorId = creatorId;
        profile.handle = handle;
        profile.active = true;
        if (profile.createdAt == 0) {
            profile.createdAt = block.timestamp;
        }

        emit CreatorRegistered(creator, creatorId, handle, block.timestamp);
    }

    function _applyVerifiedMilestone(address creator, uint256 milestoneId) internal {
        Milestone memory item = milestones[milestoneId];

        uint256 pending = pendingSparks[creator];
        if (pending >= item.sparkUnits) {
            pendingSparks[creator] = pending - item.sparkUnits;
        } else {
            pendingSparks[creator] = 0;
        }

        totalSparks[creator] += item.sparkUnits;
        unconvertedSparks[creator] += item.sparkUnits;

        CreatorProfile storage profile = creators[creator];
        profile.verifiedMilestones += 1;
        profile.cumulativeConfidence += item.validationConfidence;

        uint256 newCPoints = unconvertedSparks[creator] / SPARKS_PER_CPOINT;
        if (newCPoints > 0) {
            cPointsBalance[creator] += newCPoints;
            unconvertedSparks[creator] = unconvertedSparks[creator] % SPARKS_PER_CPOINT;
        }

        uint256 availableCPoints = cPointsBalance[creator] - cPointsCommittedForBeats[creator];
        uint256 newBeats = availableCPoints / CPOINTS_PER_BEAT;
        if (newBeats > 0) {
            beatsBalance[creator] += newBeats;
            cPointsCommittedForBeats[creator] += newBeats * CPOINTS_PER_BEAT;
        }

        _mintRewardIfConfigured(creator, milestoneId, item.rewardAmount);

        emit ProgressUpdated(
            creator, totalSparks[creator], pendingSparks[creator], cPointsBalance[creator], beatsBalance[creator]
        );
    }

    function _deriveSparkUnits(MetricType metricType, uint256 threshold) internal pure returns (uint256) {
        uint256 rawUnits;
        if (metricType == MetricType.FOLLOWERS) {
            rawUnits = threshold / 100;
        } else if (metricType == MetricType.VIEWS) {
            rawUnits = threshold / 1_000;
        } else if (metricType == MetricType.WATCH_HOURS) {
            rawUnits = threshold / 100;
        } else if (metricType == MetricType.CONTENT_COUNT) {
            rawUnits = threshold / 10;
        } else {
            rawUnits = threshold / 100;
        }

        return rawUnits == 0 ? 1 : rawUnits;
    }

    function _mintRewardIfConfigured(address creator, uint256 milestoneId, uint256 rewardAmount) internal {
        if (!rewardsEnabled || rewardToken == address(0) || rewardAmount == 0) return;

        try ICrabbyRewardToken(rewardToken).mint(creator, rewardAmount) {
            emit RewardMinted(creator, milestoneId, rewardAmount);
        } catch {
            emit RewardMintFailed(creator, milestoneId, rewardAmount);
        }
    }
}
