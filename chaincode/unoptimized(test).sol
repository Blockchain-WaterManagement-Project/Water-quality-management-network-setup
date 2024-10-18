// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.11;

contract WaterQualityManagementUnoptimized {
    struct QualityEvent {
        uint256 timestamp;
        int256 qualityLevel;
    }
    mapping(address => QualityEvent[]) public recentQualityRecords;
    mapping(address => QualityEvent[]) public historicalQualityData;

    function reportQuality(address user, int256 qualityLevel) public {
        uint256 currentTimestamp = block.timestamp;
        QualityEvent memory newEvent = QualityEvent(
            currentTimestamp,
            qualityLevel
        );
        recentQualityRecords[user].push(newEvent);
    }

    function getRecentQualityRecords(
        address user
    ) public view returns (QualityEvent[] memory) {
        return recentQualityRecords[user];
    }

    function migrateToHistorical(address user, uint256 beforeTimestamp) public {
        QualityEvent[] storage recentEvents = recentQualityRecords[user];
        for (uint256 i = 0; i < recentEvents.length; i++) {
            if (recentEvents[i].timestamp < beforeTimestamp) {
                historicalQualityData[user].push(recentEvents[i]);
                removeEvent(recentEvents, i);
                i--;
            }
        }
    }

    function removeEvent(
        QualityEvent[] storage events,
        uint256 index
    ) internal {
        require(index < events.length, "Index out of bounds");
        for (uint256 i = index; i < events.length - 1; i++) {
            events[i] = events[i + 1];
        }
        events.pop();
    }
}
