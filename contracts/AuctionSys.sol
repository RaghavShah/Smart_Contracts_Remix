// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract AuctionSystem{

    struct Item{
        string name;
        string discription;
        uint highestBid;
        address payable highestBidder;
    }

    mapping(uint=>Item) public items;

    address internal manager;
    uint internal nextitem;
    address payable winner;

    constructor(){
        manager=msg.sender;
    }

    modifier onlyManager(){
        require(manager==msg.sender,"You are not manager");
        _;
    }

    function createItem(string calldata name, string calldata discription) public onlyManager(){
        items[nextitem] = Item(name,discription,0,payable(msg.sender));
        nextitem++;
    }

    function placeBid(uint id, uint amount) public payable{
        require(id>0 && id<=nextitem,"Invalid Id");
        Item storage item = items[id];
        require(amount>item.highestBid,"Amount should be greater than the current highest bid");

        if(item.highestBidder!=address(0)){
            item.highestBidder.transfer(item.highestBid);
        }
        item.highestBidder=payable(msg.sender);
        item.highestBid=amount;
    }

    function DeclareWinner(uint id) public view onlyManager() returns(address,uint){
        require(id>0 && id<=nextitem,"Invalid Id");
        Item storage item = items[id];
        return (item.highestBidder,item.highestBid);
    }

}