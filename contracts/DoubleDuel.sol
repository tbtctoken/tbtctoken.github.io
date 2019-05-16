pragma solidity ^0.4.25;

contract DoubleDuel {
    address public owner = msg.sender;
    address private lastSender;
    address private lastOrigin;

    address public duelWith;

    uint public tokenId = 1002398;
    uint public tokenReward = 2000000;
    
    event Duel(address indexed from, address indexed winner);
    
    uint private seed;
 
    modifier notContract() {
        lastSender = msg.sender;
        lastOrigin = tx.origin;
        require(lastSender == lastOrigin);
        _;
    }
    
    // uint256 to bytes32
    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
    
    // returns a pseudo-random number
    function random(uint lessThan) internal returns (uint) {
        seed += block.timestamp + uint(msg.sender);
        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;
    }
    
    function duel() external payable notContract {
        require(msg.value == 10000000);
        msg.sender.transferToken(tokenReward, tokenId);
        address winner;
        if (duelWith != 0x0) {
            require(msg.sender != duelWith);
            winner = random(2) == 0 ? duelWith : msg.sender;
            duelWith = 0x0;
            winner.transfer(18000000);
            owner.transfer(address(this).balance);
        } else {
            duelWith = msg.sender;
        }
        emit Duel(msg.sender, winner);
    }
}