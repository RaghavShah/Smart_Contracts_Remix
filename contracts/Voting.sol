// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;
contract Voting{

    struct Voter{
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate{
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes; 
    }

    uint nextVoterId=1;
    uint nextCandidateId=1;

    uint startTime;
    uint endTime;
    bool stopVoting;
    address winner;
    address electionComision;

    mapping(uint=>Voter) public voterDetails;
    mapping(uint=>Candidate) public candidateDetails;

    constructor(){
        electionComision=msg.sender;
    }
    modifier isVotingOver(){
        require(block.timestamp>endTime && stopVoting==false,"Voting is over");
        _;
    }

    modifier onlyCommisioner(){
        require(electionComision==msg.sender,"Not form Election Commision");
        _;
    }


    function candidateRegister(string calldata _name,string calldata _party,uint _age, string calldata _gender) internal {
        require(candidateVerification(msg.sender)==true,"You have already registered");
        require(_age>=18,"You are not eligible");
        require(nextCandidateId<3,"Candidate registration full"); //We have limited the candidate registrations
        candidateDetails[nextCandidateId]=Candidate(_name,_party,_age,_gender,nextCandidateId,msg.sender,0);
        nextCandidateId++;
    }

    function candidateVerification(address _person) public view returns(bool){
        for(uint i=0;i<nextCandidateId;i++){
            if(candidateDetails[i].candidateAddress==_person){
                return false;
            }
        }
        return true;
    }

    function candidateList() public view returns(Candidate[] memory) {
        Candidate[] memory candidates = new Candidate[](nextCandidateId-1);
        //New empty arrat candidates containing candidate details;
        for(uint i=1;i<nextCandidateId;i++){
            candidates[i-1]=candidateDetails[i];
        }
        return candidates;
    }

    function voteRegister(string calldata _name,uint _age,string calldata _gender) public {
        require(_age>=18,"You are not eligible for voting");
        require(voterVerification(msg.sender)==true,"You have already voted");
        voterDetails[nextVoterId]=Voter(_name,_age,nextVoterId,_gender,0,msg.sender);
        nextVoterId++;
    }

    function voterVerification(address _person) internal view returns(bool) {
        for(uint i=1;i<nextVoterId;i++){
            if(voterDetails[i].voterAddress  == _person){
                return false;
            }
        }
        return true;
    }

    function voterList() public view returns(Voter[] memory){
        Voter[] memory voters = new Voter[](nextVoterId-1);
        for(uint i=0;i<nextVoterId;i++){
            voters[i-1]=voterDetails[i];
        }
        return voters;
    }

    function vote(uint _voterId,uint _id) external isVotingOver {
        require(voterDetails[_voterId].voteCandidateId==0,"You have already voted");
        require(voterDetails[_voterId].voterAddress==msg.sender,"You are not a voter");
        require(startTime!=0,"Voting have not started yet");
        require(nextCandidateId==3,"All candidate registration have not done yet");
        require(_id>0 && _id<3,"Invalid candidate id");
        voterDetails[_voterId].voteCandidateId=_id;
        candidateDetails[_id].votes++;
    }

    function startVoting(uint _startTime,uint _endTime) external onlyCommisioner(){
        startTime=block.timestamp+_startTime;
        endTime=startTime + _endTime;
        stopVoting=false;
    }

    function emergency() public onlyCommisioner(){
        stopVoting=true;
    }

    function VotingStatus() public view returns(string memory){
        if(startTime==0){
            return "Voting has not started";
        }
        else if((startTime!=0 && endTime>block.timestamp)&& stopVoting==false){
            return "Voting in progress";
        }else{
            return "Ended";
        }
    }
    function result() external view onlyCommisioner() isVotingOver(){
        require(nextCandidateId>1,"No Candidate register");
        uint maxvotes=0;
        address currentWinner;
        for(uint i=1;i<nextCandidateId;i++){
            if(candidateDetails[i].votes>maxvotes){
                maxvotes=candidateDetails[i].votes;
                currentWinner=candidateDetails[i].candidateAddress;
            }
        }
    }
    
}