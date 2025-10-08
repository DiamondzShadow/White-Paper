// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title YouTubeMilestone
 * @dev Contract for recording YouTube channel milestones on-chain
 */
contract YouTubeMilestone is Ownable {
    // Milestone types
    enum MilestoneType { SUBSCRIBERS, VIEWS, VIDEOS }
    
    // Milestone structure
    struct Milestone {
        string channelId;
        MilestoneType milestoneType;
        uint256 threshold;
        uint256 count;
        uint256 timestamp;
        uint8 validationConfidence; // 0-100 representing AI validation confidence
        bool verified;
    }
    
    // Mapping from channel ID to array of milestones
    mapping(string => Milestone[]) public channelMilestones;
    
    // Events
    event MilestoneRecorded(
        string indexed channelId,
        MilestoneType milestoneType,
        uint256 threshold,
        uint256 count,
        uint256 timestamp,
        uint8 validationConfidence
    );
    
    event MilestoneVerified(
        string indexed channelId,
        MilestoneType milestoneType,
        uint256 threshold,
        uint256 timestamp
    );
    
    /**
     * @dev Record a new milestone for a channel
     * @param channelId YouTube channel ID
     * @param milestoneType Type of milestone (0=Subscribers, 1=Views, 2=Videos)
     * @param threshold Milestone threshold that was reached
     * @param count Current count at the time of reaching the milestone
     * @param timestamp Time when the milestone was reached
     * @param validationConfidence AI validation confidence score (0-100)
     */
    function recordMilestone(
        string memory channelId,
        uint8 milestoneType,
        uint256 threshold,
        uint256 count,
        uint256 timestamp,
        uint8 validationConfidence
    ) external onlyOwner {
        require(bytes(channelId).length > 0, "Channel ID cannot be empty");
        require(milestoneType <= uint8(MilestoneType.VIDEOS), "Invalid milestone type");
        require(threshold > 0, "Threshold must be greater than zero");
        require(count >= threshold, "Count must be at least the threshold");
        require(validationConfidence <= 100, "Validation confidence must be 0-100");
        
        // Create the milestone
        Milestone memory newMilestone = Milestone({
            channelId: channelId,
            milestoneType: MilestoneType(milestoneType),
            threshold: threshold,
            count: count,
            timestamp: timestamp,
            validationConfidence: validationConfidence,
            verified: false
        });
        
        // Add to the channel's milestones
        channelMilestones[channelId].push(newMilestone);
        
        // Emit event
        emit MilestoneRecorded(
            channelId,
            MilestoneType(milestoneType),
            threshold,
            count,
            timestamp,
            validationConfidence
        );
    }
    
    /**
     * @dev Verify a previously recorded milestone (e.g., by a trusted oracle)
     * @param channelId YouTube channel ID
     * @param milestoneIndex Index of the milestone in the channel's array
     */
    function verifyMilestone(string memory channelId, uint256 milestoneIndex) external onlyOwner {
        require(milestoneIndex < channelMilestones[channelId].length, "Milestone index out of bounds");
        
        Milestone storage milestone = channelMilestones[channelId][milestoneIndex];
        require(!milestone.verified, "Milestone already verified");
        
        milestone.verified = true;
        
        emit MilestoneVerified(
            channelId,
            milestone.milestoneType,
            milestone.threshold,
            milestone.timestamp
        );
    }
    
    /**
     * @dev Get the number of milestones for a channel
     * @param channelId YouTube channel ID
     * @return Number of milestones
     */
    function getMilestoneCount(string memory channelId) external view returns (uint256) {
        return channelMilestones[channelId].length;
    }
    
    /**
     * @dev Get a specific milestone for a channel
     * @param channelId YouTube channel ID
     * @param index Index of the milestone
     * @return Milestone data
     */
    function getMilestone(string memory channelId, uint256 index) external view returns (
        string memory,
        MilestoneType,
        uint256,
        uint256,
        uint256,
        uint8,
        bool
    ) {
        require(index < channelMilestones[channelId].length, "Index out of bounds");
        
        Milestone memory milestone = channelMilestones[channelId][index];
        
        return (
            milestone.channelId,
            milestone.milestoneType,
            milestone.threshold,
            milestone.count,
            milestone.timestamp,
            milestone.validationConfidence,
            milestone.verified
        );
    }
    
    /**
     * @dev Check if a specific milestone has been reached and recorded
     * @param channelId YouTube channel ID
     * @param milestoneType Type of milestone
     * @param threshold Milestone threshold
     * @return bool Whether the milestone has been reached
     */
    function hasMilestone(
        string memory channelId,
        uint8 milestoneType,
        uint256 threshold
    ) external view returns (bool) {
        Milestone[] memory milestones = channelMilestones[channelId];
        
        for (uint256 i = 0; i < milestones.length; i++) {
            if (
                uint8(milestones[i].milestoneType) == milestoneType &&
                milestones[i].threshold == threshold
            ) {
                return true;
            }
        }
        
        return false;
    }
}
