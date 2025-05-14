// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedIdentity {
    struct Identity {
        address owner;
        uint256 reputation;
        bool verified;
        string metadataURI; // Off-chain encrypted metadata (e.g., IPFS or Arweave)
    }

    mapping(address => Identity) public identities;
    mapping(address => bool) public verifiers; // KYC or zk-verifiers
    mapping(address => bool) public registered;

    event IdentityRegistered(address indexed user, string metadataURI);
    event IdentityVerified(address indexed user);
    event ReputationUpdated(address indexed user, uint256 newScore);

    modifier onlyVerifier() {
        require(verifiers[msg.sender], "Not authorized verifier");
        _;
    }

    function register(string memory metadataURI) external {
        require(!registered[msg.sender], "Already registered");
        identities[msg.sender] = Identity({
            owner: msg.sender,
            reputation: 0,
            verified: false,
            metadataURI: metadataURI
        });
        registered[msg.sender] = true;
        emit IdentityRegistered(msg.sender, metadataURI);
    }

    function verifyIdentity(address user) external onlyVerifier {
        require(registered[user], "User not registered");
        identities[user].verified = true;
        emit IdentityVerified(user);
    }

    function updateReputation(address user, uint256 newScore) external onlyVerifier {
        require(registered[user], "User not registered");
        identities[user].reputation = newScore;
        emit ReputationUpdated(user, newScore);
    }

    function getIdentity(address user) external view returns (
        address owner,
        uint256 reputation,
        bool verified,
        string memory metadataURI
    ) {
        Identity memory id = identities[user];
        return (id.owner, id.reputation, id.verified, id.metadataURI);
    }

    function addVerifier(address verifier) external {
        // This should be governed via DAO or admin multisig in production
        require(msg.sender == address(0x2bcb72A7008b0dfE4C78A551E3BFd279269eEc12), "Only admin can add verifiers");
        verifiers[verifier] = true;
    }

    function removeVerifier(address verifier) external {
        require(msg.sender == address(0x2bcb72A7008b0dfE4C78A551E3BFd279269eEc12), "Only admin can remove verifiers");
        verifiers[verifier] = false;
    }
}
