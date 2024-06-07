// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Voting
 * @dev Implements voting process with candidate management
 */
contract Voting {

    struct Voter {
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted candidate
    }

    struct Candidate {
        uint id;       // candidate id
        string name;   // candidate name
        uint voteCount; // number of accumulated votes
    }

    address public owner;
    uint public candidatesCount;

    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;

    event CandidateAdded(uint id, string name);
    event Voted(address indexed voter, uint candidateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Add a new candidate to the election. Only callable by owner.
     * @param _name name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    /**
     * @dev Vote for a candidate. Each voter can only vote once.
     * @param _candidateId id of the candidate to vote for
     */
    function vote(uint _candidateId) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        sender.voted = true;
        sender.vote = _candidateId;
        candidates[_candidateId].voteCount++;

        emit Voted(msg.sender, _candidateId);
    }

    /**
     * @dev Get the details of a candidate.
     * @param _candidateId id of the candidate
     * @return id, name, and vote count of the candidate
     */
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    /**
     * @dev Get the details of all candidates.
     * @return array of all candidates
     */
    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory allCandidates = new Candidate[](candidatesCount);
        for (uint i = 1; i <= candidatesCount; i++) {
            allCandidates[i - 1] = candidates[i];
        }
        return allCandidates;
    }

    /**
     * @dev Computes the candidate with the most votes.
     * @return id of the winning candidate
     */
    function winningCandidate() public view returns (uint) {
        uint winningVoteCount = 0;
        uint winningCandidateId = 0;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        return winningCandidateId;
    }

    /**
     * @dev Returns the name of the winning candidate.
     * @return name of the winning candidate
     */
    function winnerName() public view returns (string memory) {
        return candidates[winningCandidate()].name;
    }
}
