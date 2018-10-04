pragma solidity ^0.4.24;

contract Election {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    event votedEvent(uint candidateId, string candidateName);
    event candidateVoteCount(uint candidateId, string candidateName, uint candidateCount);

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;

    uint public candidatesCount;

    constructor() public {
        addCandidate("Equipo 1");
        addCandidate("Equipo 2");
        addCandidate("Equipo 3");
    }

    modifier isValidCandidate(uint _candidateId) {
        require(_candidateId > 0 && _candidateId <= candidatesCount);
        _;
    }

    function addCandidate(string _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint _candidateId) public isValidCandidate(_candidateId) {
        require(!voters[msg.sender]);

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit votedEvent(_candidateId, candidates[_candidateId].name);
    }

    function getVotes(uint _candidateId) public view isValidCandidate(_candidateId) returns(uint, string, uint) {
        // I've commented the event in order to make this function a proper view function
        //emit candidateVoteCount(_candidateId, candidates[_candidateId].name, candidates[_candidateId].voteCount);
        return (_candidateId, candidates[_candidateId].name, candidates[_candidateId].voteCount);
    }

}