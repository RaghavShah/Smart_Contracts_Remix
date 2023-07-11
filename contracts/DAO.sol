// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract DAO{
    
    struct Proposal{
        uint id;
        string description;
        uint amount;
        address payable receipient;
        uint vote;
        uint end; 
        bool isExecuted; //status
    }

    mapping(address=>bool) private isInvestor;
    mapping(address=>uint) public noOfShares;
    mapping(address=>mapping(uint=>bool)) public isVoted;
    mapping(address=>mapping(address=>bool)) public withdraelStatus;
    mapping(uint=>Proposal) public proposals;

    address[] public investorsList;

    uint public totalShares;
    uint public availableFunds;
    uint public contributionTimeEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public manager;

    constructor(uint _contributionTimeEnd, uint _voteTime,uint _quorum){
        require(_quorum>0 && _quorum<100,"Not valid value");
        contributionTimeEnd=block.timestamp+_contributionTimeEnd;
        voteTime=_voteTime;
        quorum=_quorum;
        manager=msg.sender;
    }

    modifier onlyInvestor(){
        require(isInvestor[msg.sender]==true,"You are not investor");
        _;
    }

    modifier onlyManager(){
        require(manager==msg.sender,"You are not manager");
        _;
    }

    function contribution() public payable {
        require(contributionTimeEnd>=block.timestamp,"contribution time Ended");
        require(msg.value>0,"Send more than 1 Ether");
        isInvestor[msg.sender]=true;
        noOfShares[msg.sender]=noOfShares[msg.sender]+msg.value;
        totalShares+=msg.value;
        availableFunds+=msg.value;
        investorsList.push(msg.sender);
    }

    function reedemShares(uint amount) public onlyInvestor(){
        require(noOfShares[msg.sender]>=amount,"You dont have enough shares");
        require(availableFunds>=amount,"Not enough funds");
        noOfShares[msg.sender]-=amount;
        if(noOfShares[msg.sender]==0){
            isInvestor[msg.sender]=false;
        }  
        availableFunds-=amount;
        payable(msg.sender).transfer(amount); 
    }

    function transferShare(uint amount,address to) public payable onlyInvestor(){
        require(noOfShares[msg.sender]>=amount,"You dont have enough share to tranfer");
        require(availableFunds>=amount,"Not Enough funds");
        noOfShares[msg.sender]-=amount;
        if(noOfShares[msg.sender]==0){
        isInvestor[msg.sender]=false;
        }
        noOfShares[to]+=amount;
        isInvestor[to]=true;
    }

    function createProposal(string calldata description,uint amount,address payable receipient) public onlyManager(){
        require(availableFunds>=amount,"Not enough funds");
        proposals[nextProposalId]=Proposal(nextProposalId,description,amount,receipient,0,block.timestamp+voteTime,false);
        nextProposalId++;
    }

    function voteProposal(uint proposalId) public onlyInvestor(){
        Proposal storage proposal = proposals[proposalId];
        require(isVoted[msg.sender][proposalId]==false,"You have already voted");
        require(proposal.end>block.timestamp,"voting time has ended");
        require(proposal.isExecuted==false,"Proposal has already executed");
        isVoted[msg.sender][proposalId]==true;
        proposal.vote+=noOfShares[msg.sender];
    }

    function executeProposal(uint proposalId) public onlyManager(){
        Proposal storage proposal = proposals[proposalId];
        require((proposal.vote*100/totalShares)>=quorum,"Majority do not support");
        require(proposal.end<block.timestamp,"Proposal is not ended yet");
        proposal.isExecuted=true;
        _transfer(proposal.amount,proposal.receipient);
    }

    function _transfer(uint amount,address payable  receipient) public {
        receipient.transfer(amount);
        availableFunds-=amount;
    }

    function proosalList() public view returns(Proposal[] memory){
        Proposal[] memory arr = new Proposal[](nextProposalId - 1);
        for(uint i=0;i<nextProposalId;i++){
            arr[i]=proposals[i]; 
            //This step is done because we can not display mapping in the form of array so we put all elements of the mapping in empty array
        }
        return arr;
    }
}