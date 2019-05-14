pragma solidity ^0.4.25;

contract ROI {
    address public owner = msg.sender;
    uint public tokenId = 1002398;

    mapping (address => uint256) invested;
    mapping (address => uint256) atBlock;

    function getPercent(address investor) public view returns (uint) {
        uint balance = investor.tokenBalance(tokenId);
        if (balance > 50000000000) {
            balance = 50000000000;
        }
        return 2 + 8 * balance / 50000000000;
    }

    function interact() external payable {
        require(msg.value >= 100000000);
        if (invested[msg.sender] != 0) {
            // amount = (amount invested) * percent * (blocks since last transaction) / 28800 / 100
            uint256 amount = invested[msg.sender] * getPercent(msg.sender) * (block.number - atBlock[msg.sender]) / 2880000;

            msg.sender.send(amount);
        }

        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;

        owner.transfer(msg.value / 10);
    }
}
