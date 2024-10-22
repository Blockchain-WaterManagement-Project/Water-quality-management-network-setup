pragma solidity ^0.8.0;

contract DataMigration {
    mapping(uint256 => string) public onchainA;
    mapping(uint256 => string) public onchainB;

    // Function to copy data from Onchain A to Onchain B
    function migrateData(uint256 key) public {
        string memory data = onchainA[key];
        onchainB[key] = data; // Copying data to Onchain B
    }

    // Event for off-chain transfer via Oracle
    event DataCopiedToOffChain(uint256 indexed key, string data);

    // Function to trigger off-chain data migration using an Oracle
    function migrateDataToOffChain(uint256 key) public {
        string memory data = onchainA[key];
        emit DataCopiedToOffChain(key, data); // Oracle listens to this event and transfers the data off-chain
    }
}
