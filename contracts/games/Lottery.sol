/**
 *Submitted for verification at Etherscan.io on 2019-01-17
*/

pragma solidity ^0.4.8;


contract Lottery {

    mapping (uint8 => address[]) playersByNumber ;
    mapping (address => bytes32) playersHash;

    uint8[] public numbers;

    address owner;

    function Lottery() public {
        owner = msg.sender;
        state = LotteryState.FirstRound;
    }

    enum LotteryState { FirstRound, SecondRound, Finished }

    LotteryState state;

    function enterHash(bytes32 x) public payable {
        require(state == LotteryState.FirstRound);
        require(msg.value > .001 ether);
        playersHash[msg.sender] = x;
    }

    function runSecondRound() public {
        // _runSecondRound();
        require(msg.sender == owner);
        require(state == LotteryState.FirstRound);
        require(numbers.length > 0);
        state = LotteryState.SecondRound;
    }

    function enterNumber(uint8 number) public {
        require(number<=250);
        require(state == LotteryState.SecondRound);
        require(keccak256(number, msg.sender) == playersHash[msg.sender]);
        playersByNumber[number].push(msg.sender);
        numbers.push(number);
    }

    function determineWinner() public {
        require(msg.sender == owner);

        state = LotteryState.Finished;

        uint8 winningNumber = random();

        distributeFunds(winningNumber);

        selfdestruct(owner);
    }

    function distributeFunds(uint8 winningNumber) private returns(uint256) {
        uint256 winnerCount = playersByNumber[winningNumber].length;
        require(winnerCount == 1);
        if (winnerCount > 0) {
            uint256 balanceToDistribute = this.balance/(2*winnerCount);
            for (uint i = 0; i<winnerCount; i++) {
                require(i==0);
                playersByNumber[winningNumber][i].transfer(balanceToDistribute*9/10);
            }
        }

        return this.balance;
    }

    function random() private view returns (uint8) {
        uint8 randomNumber = numbers[0];
        for (uint8 i = 1; i < numbers.length; ++i) {
            randomNumber ^= numbers[i];
        }
        return randomNumber;
    }

}
