//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


/**
@author aymane

@title contract that demonstrate how we can transform traditional voting(Ballot, election...) to blockchain using solidity

*/


contract Ballot {
    //Variables
    /**
    @notice declaring the Vote as a Struct
    */
    struct Vote{
        bool choice;
        address VoterAddress;
    }

    /**
    @notice declaring the Voter as a struct
     */

    struct Voter{
        string name;
        bool Voted;
    }

    uint private countResult = 0;

    uint public finalResult = 0;

    uint public totalVoter = 0;

    uint public totalVote = 0;

    address public ballotAddress;

    string public ballotName;

    //proposal is the description of the ballot contract

    string public proposal;

    mapping(uint => Vote) private votes;

    mapping(address => Voter) public voterRegister;

    //creating an enumuration the check the current state of the ballot

    enum State{started, voting, ended} State public state;

    //Modifier

    modifier condition(bool condition_){
        require(!condition_, "not authorized to re-vote");
        _;
    }

    modifier Authorization(){
        require(msg.sender == ballotAddress, "action not allowed!");
        _;
    }

    modifier inState(State state_){
        require(state_ == state, "current state different than the given state!");
        _;
    }

    //Functions

    constructor(string memory _ballotName, string memory _proposal){
        ballotAddress = msg.sender;
        ballotName = _ballotName;
        proposal = _proposal;
        state = State.started;
    }

    function addVoter(address _voterAddress, string memory name) public  inState(State.voting) Authorization{
        Voter memory tmp_voter;
        tmp_voter.name = name;
        tmp_voter.Voted = false;
        voterRegister[_voterAddress] = tmp_voter;
        totalVoter++;
    }

    function startVote() public inState(State.started) Authorization{
        state = State.voting;
    }

    function doVote(bool _choice) public inState(State.voting) condition(voterRegister[msg.sender].Voted) returns(bool){
        bool found = false;

        if(bytes(voterRegister[msg.sender].name).length != 0 && !voterRegister[msg.sender].Voted){
            found = true;
            Vote memory tmp_vote;
            tmp_vote.VoterAddress = msg.sender;
            tmp_vote.choice = _choice;
            voterRegister[msg.sender].Voted = true;
            if(_choice){
                countResult++;
            }
            votes[totalVote++] = tmp_vote;
        }
        return found;
    }

    function endVote() public inState(State.voting) Authorization{
        state = State.ended;
        finalResult = countResult;
    }

}
