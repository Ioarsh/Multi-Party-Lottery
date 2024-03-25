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
    uint private stage=1;
    uint private timestamp=0;
    uint private revealcount=0;
    uint private reward=0;
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
        T1=0;
        T2=0;
        N=0;
        stage = 1;
        timestamp = 0;
        revealcount = 0;
        for(uint i=0;i<numPlayer;i++){
            PlayerIndex[player[i].addr] = 0;
            player[i].addr = address(0);
            player[i].choice = 7777;
        }
        numPlayer = 0;
        reward=0;
        delete validUser;
    }

    function ChangeStage(uint st) public{
        if(st==2){
            require(stage==1);
            require(timestamp+T1 < block.timestamp);
            stage=2;
            timestamp=block.timestamp;
        }
        else if(st==3){
            require(stage==2);
            require(timestamp+T2 < block.timestamp);
            stage=3;
            timestamp=block.timestamp;
        }
        else if(st==4){
            require(stage==3);
            require(timestamp+T3 < block.timestamp);
            stage=4;
        }
    }


    function addPlayer(uint transaction,uint salt) public payable {
        require(numPlayer < N);
        require(msg.value==0.001 ether);
        require(transaction>=0 && transaction<=999);
        require(stage==1);
        if(timestamp==0){
            timestamp = block.timestamp;
        }
        else if(timestamp+T1 < block.timestamp){
            ChangeStage(2);
            return();
        }
        player[numPlayer].addr = msg.sender;
        PlayerIndex[msg.sender] = numPlayer;
        uint idx = PlayerIndex[msg.sender];
        uint HashedData = uint(getSaltedHash(bytes32(transaction),bytes32(salt)));
        player[idx].choice = HashedData;
        player[idx].good = false;
        commit(bytes32(HashedData));
        numPlayer++;
        reward+=msg.value;
    }

    function RevealAns(uint transaction,uint saltz) public{
        require(stage == 2);
        if(timestamp+T2 < block.timestamp){
            ChangeStage(3);
            return();
        }
        revealAnswer(bytes32(transaction),bytes32(saltz));
        uint idx = PlayerIndex[msg.sender];
        player[idx].choice = transaction;
        player[idx].good = true;
        revealcount++;
        validUser.push(player[idx].addr);
    }


    function checkWinnerAndPay() public {
        require(owner == msg.sender);
        require(stage==3);
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
        require(stage==4);
        uint idx = PlayerIndex[msg.sender];
        require(player[idx].good = true);
        address payable acc = payable (msg.sender);
        acc.transfer(0.001 ether);
        player[idx].good = false;
    }
}
