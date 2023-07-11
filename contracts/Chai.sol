// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

contract chai{
    struct Memo{
        string name;
        string message;
        uint timestamp;
        address from;
    }

    Memo[] memos;
    address payable owner;
    
    constructor(){
        owner=payable(msg.sender);
    }
    function buyChai(string memory _name,string memory _message) public payable {
        require(msg.value>0,"Enter amount greater than 0");
        owner.transfer(msg.value);
        memos.push(Memo(_name,_message,block.timestamp,msg.sender));
    } 

    function getMemos() public view returns(Memo[] memory){
        return memos;
    }
}