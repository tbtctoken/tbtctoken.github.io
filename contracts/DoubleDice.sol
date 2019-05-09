pragma solidity ^0.4.25;

contract DoubleDice {
    address public owner = msg.sender;
    address private lastSender;
    address private lastOrigin;
    uint public jackpot;

    uint public tokenId = 1002398;
    uint public jackpotRange = 100000;
    
    event Dice(address indexed from, uint256 bet, uint256 prize, uint256 number, uint256 rollUnder, bool playForJackpot, uint256 jackpot);
    
    uint private seed;
 
    modifier notContract() {
        lastSender = msg.sender;
        lastOrigin = tx.origin;
        require(lastSender == lastOrigin);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
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

    function getMaxBet() public view returns (uint) {
        uint maxBet = (address(this).balance - jackpot) / 98;
        return maxBet > 10000000000 ? 10000000000 : maxBet;
    }

    function getProfit() external onlyOwner {
        owner.transfer((address(this).balance - jackpot) / 2);
    }
    
    function dice(uint rollUnder) external payable notContract {
        require(msg.value <= getMaxBet());
        require(rollUnder >= 2 && rollUnder <= 97);
        
        bool playForJackpot = msg.sender.tokenBalance(tokenId) >= 10000000000;
        uint number = random(100);
        if (number < rollUnder) {
            uint prize = msg.value * 98 / rollUnder;
            uint winJackpot;
            if (playForJackpot && random(jackpotRange) == 0) {
                winJackpot += jackpot;
            }
            msg.sender.transfer(prize + winJackpot);
            emit Dice(msg.sender, msg.value, prize, number, rollUnder, playForJackpot, winJackpot);
        } else {
            jackpot += msg.value / 100;
            emit Dice(msg.sender, msg.value, 0, number, rollUnder, playForJackpot, 0);
        }
    }

    function () external payable onlyOwner {

    }
}
