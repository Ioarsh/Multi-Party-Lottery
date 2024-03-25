// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./CommitReveal.sol";

contract Multi_Party_Lottery is CommitReveal{
    struct Player {
        uint choice;
        address addr;
        bool good;
    }
    mapping (uint => Player) private player;
    mapping (address => uint) private PlayerIndex;
    uint private T1=0;
    uint private T2=0;
    uint private T3=0;
    uint private N=0;
    uint private numPlayer = 0;
    uint private timestamp=0;
    uint private revealcount=0;
    address[] public validUser;
    address payable owner;
    constructor(uint t1, uint n,uint t2,uint t3){
        require(n>=2);
        T1 = t1;
        T2 = t2;
        T3 = t3;
        N = n;
        owner = payable(msg.sender);
    }

    function _reset() private{
        timestamp = 0;
        revealcount = 0;
        for(uint i=0;i<numPlayer;i++){
            PlayerIndex[player[i].addr] = 0;
            player[i].addr = address(0);
            player[i].choice = 7777;
        }
        numPlayer = 0;
        delete validUser;
    }

    function addPlayer(uint transaction,uint salt) public payable {
        if(timestamp==0){
            timestamp = block.timestamp;
        }
        require(timestamp+T1 > block.timestamp);
        require(numPlayer < N);
        require(msg.value==0.001 ether);
        require(transaction>=0 && transaction<=999);
        player[numPlayer].addr = msg.sender;
        PlayerIndex[msg.sender] = numPlayer;
        uint idx = PlayerIndex[msg.sender];
        uint HashedData = uint(getSaltedHash(bytes32(transaction),bytes32(salt)));
        player[idx].choice = HashedData;
        player[idx].good = false;
        commit(bytes32(HashedData));
        numPlayer++;
    }

    function RevealAns(uint transaction,uint saltz) public{
        require(timestamp+T1+T2 > block.timestamp && block.timestamp > timestamp+T1);
        revealAnswer(bytes32(transaction),bytes32(saltz));
        uint idx = PlayerIndex[msg.sender];
        player[idx].choice = transaction;
        player[idx].good = true;
        revealcount++;
        validUser.push(player[idx].addr);
    }


    function checkWinnerAndPay() public {
        require(timestamp+T1+T2+T3 > block.timestamp && block.timestamp > timestamp+T1+T2);
        require(owner == msg.sender);
        uint winner = uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number), block.number)));
        for(uint i=0;i<revealcount;i++){
            winner = winner ^ player[PlayerIndex[validUser[i]]].choice; 
        }
        if(revealcount > 0){
            winner = winner % revealcount;
            address payable winner_acc = payable (validUser[winner]);
            winner_acc.transfer(numPlayer*(980000000000000));
            owner.transfer(numPlayer*(20000000000000));
        }
        else{
            owner.transfer(numPlayer*(1000000000000000));
        }
        _reset();
    }
    
    function withdraw() public payable {
        require(timestamp+T1+T2+T3 < block.timestamp);
        uint idx = PlayerIndex[msg.sender];
        require(player[idx].good = true);
        address payable acc = payable (msg.sender);
        acc.transfer(0.001 ether);
        player[idx].good = false;
    }
}
