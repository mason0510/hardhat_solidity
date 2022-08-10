//pragma solidity ^0.4.25;
//
//import "./BaseContracts.sol";
//import "./SafeMath.sol";
//import "./Croupier.sol";
//
//
//contract GalaxyLotto is Croupier, BaseContracts {
//
//    // ----------------------- constant -----------------------
//    uint private constant PERCENT_DIVIDER = 10000;
//
//    // ----------------------- variate -----------------------
//
//    // record
//    Game[] private games;
//    uint64 public gameIndex = 0;// Current game index
//
//    Ticket[] private tickets;
//    uint64 public ticketCount = 0;// Current tickets index
//    uint64[] public resultStat;
//
//    uint64 public betId = 0;
//    uint64 public payId = 0;
//
//    uint256 jackpot = 0;
//
//
//    // game config
//    uint8 public numbersCountMax;// Bet the maximum number
//    uint256[] public winPercent;// Distribution of winning funds
//    uint64 public ticketCountMax;// The maximum number of tickets purchased per round
//
//    uint8 public numbersCount;// The number of betting Numbers
//
//    // asset allocation
//    uint256 public dividendsPercent;// The money is used to pay dividends to users
//    uint256 public technicalPercent;// The money was used to develop the team's technology and to market it
//    uint256 public noFirstPrizePercent;// If no one wins the first prize, part of the money will be withdrawn into a reserve fund
//
//
//
//    // time
//    uint32 public disableBuyingTime;// No purchase is allowed xx hours before the drawing
//    uint32 public intervalTime;// The amount of time between tickets
//
//    // other
//    bool public isPause;// Game pause or not
//    uint256 public nextPrice;// Lottery ticket price
//
//
//    // ----------------------- struct -----------------------
//    struct Game {// Details of each game
//        uint256 startTime;
//        uint256 jackpot;
//        uint256 price;
//        uint256[] winNumbers;
//        uint256 bitcoinBlockIndex;
//        string bitcoinBlockHash;
//
//        uint256 toJackpot;// Withdraw money from the prize pool to the reserve account
//        uint256 toReserve;// Withdraw money from the reserve account to the prize pool
//        uint256 toPay;// Money to reward users
//        uint256 toManager;
//    }
//
//    struct Ticket {
//        uint64 betId;
//        address player;
//        uint256[] betNumbers;// Betting number
//        uint256[] rightNumber;// Guess the right number
//        uint256 winnings;
//    }
//
//
//    // ----------------------- event logs -----------------------
//    event BetLog(uint64 indexed gameIndex, uint64 betId, address player, uint256[] betNumbers, address referer);
//    event PayLog(uint64 indexed gameIndex, uint64 payId, uint64 betId, uint256 winnings);
//    event DrawLog(uint64 indexed gameIndex, uint256[] result);
//
//
//    // ----------------------- constructor function -----------------------
//    constructor (uint8 _numbersCount) public Ownable() {
//        numbersCount = _numbersCount;
//        resultStat.length = numbersCount + 1;
//
//        dividendsPercent = 2000;
//        technicalPercent = 2000;
//        noFirstPrizePercent = 1000;
//
//        disableBuyingTime = 1 hours;
//        intervalTime = 24 hours;
//
//        if (numbersCount == 4) {
//            numbersCountMax = 20;
//            winPercent = [0, 0, 3400, 3300, 3300];
//        } else if (numbersCount == 5) {
//            numbersCountMax = 36;
//            winPercent = [0, 0, 0, 3400, 3300, 3300];
//        } else if (numbersCount == 6) {
//            numbersCountMax = 45;
//            winPercent = [0, 0, 2000, 2000, 2000, 2000, 2000];
//        }
//
//        ticketCountMax = 1000000;
//        nextPrice = 0.01 ether;
//
//        // isPause = true;
//
//
//        games.length = 1;
//        gameIndex = 0;
//        games[gameIndex].price = nextPrice;
//        games[gameIndex].startTime = now;
//
//        ticketCount = 0;
//
//        isPause = false;
//
//        // startNewGame();
//    }
//
//
//
//    // ----------------------- game write function -----------------------
//
//    // ------------ common ------------
//    function() external payable {
//        require(msg.value > 0, "Invalid amount");
//
//        Game storage game = games[gameIndex];
//        game.toJackpot += msg.value;
//        jackpot += msg.value;
//    }
//
//    function withdrawJackpotToReserve(uint payout) external onlyOwner {
//        require(payout > 0 && jackpot >= payout, "Invalid amount");
//        _owner.transfer(payout);
//
//        Game storage game = games[gameIndex];
//        game.toReserve += payout;
//        jackpot -= payout;
//    }
//
//    function buyTickets(uint256[] memory _betNumbers, address _referer) public payable {
//        require(tx.origin == msg.sender, "No contract bet accepted");
//
//        require(!isPause, "Game suspended, no betting allowed");
//        require(now < game.startTime + intervalTime - disableBuyingTime, "No betting near the draw");
//        require(_betNumbers.length % numbersCount == 0 && _betNumbers.length > 0, "Invalid betting plan");
//
//        Game storage game = games[gameIndex];
//        uint256 buyTicketCount = _betNumbers.length / numbersCount;
//        require(msg.value >= buyTicketCount * game.price, "Invalid amount");
//        require(buyTicketCount + ticketCount <= ticketCountMax, "The maximum number of tickets purchased has been exceeded");
//
//        if (_referer == msg.sender && _referer == address(this)) {
//            _referer = address(0);
//        }
//
//        for (uint256 i = 0; i < buyTicketCount; i++) {
//            uint256[] memory betNumbersTmp = new uint256[](numbersCount);
//            uint256 betNumbersTmpIndex = 0;
//            for (uint256 j = i * numbersCount; j < (i + 1) * numbersCount; j++) {
//                betNumbersTmp[betNumbersTmpIndex] = _betNumbers[j];
//                betNumbersTmpIndex++;
//            }
//            buyTicket(betNumbersTmp, _referer);
//        }
//    }
//
//
//
//
//
//
//    // ------------ admin ------------
//
//    function drawGame(uint bitcoinBlockIndex, string bitcoinBlockHash) public onlyCroupier {
//        Game storage game = games[gameIndex];
//
//        require(isNeedDrawGame(bitcoinBlockIndex));
//
//        game.bitcoinBlockIndex = bitcoinBlockIndex;
//        game.bitcoinBlockHash = bitcoinBlockHash;
//        game.winNumbers = getWinNumbers(bitcoinBlockHash);
//
//        emit DrawLog(gameIndex, game.winNumbers);
//
//        if (ticketCount > 0) {
//            selectWiners();
//            pay();
//        }
//
//        startNewGame();
//    }
//
//    function selectWiners() private {
//        Game storage game = games[gameIndex];
//        uint256[] storage winNumbers = game.winNumbers;
//
//        for (uint256 i = 0; i < ticketCount; i++) {
//            Ticket storage _ticket = tickets[i];
//            uint256[] storage betNumbers = _ticket.betNumbers;
//            uint256[] storage rightNumber = _ticket.rightNumber;
//            for (uint256 j = 0; j < betNumbers.length; j++) {
//                for (uint256 m = 0; m < winNumbers.length; m++) {
//                    if (betNumbers[j] == winNumbers[m]) {
//                        rightNumber.length++;
//                        rightNumber[rightNumber.length - 1] = winNumbers[m];
//                    }
//                }
//            }
//            resultStat[rightNumber.length]++;
//        }
//    }
//
//    function pay() private {
//        Game storage game = games[gameIndex];
//
//        // game.jackpot = address(this).balance;
//        uint256 ticketsAmount = ticketCount * game.price;
//        uint256 technicalAmount = ticketsAmount * technicalPercent / PERCENT_DIVIDER;
//        uint256 dividendsAmount = ticketsAmount * dividendsPercent / PERCENT_DIVIDER;
//        uint256 toManagerAmount = technicalAmount + dividendsAmount;
//
//        uint256 bonuses = ticketsAmount - toManagerAmount;
//        uint256 noFirstPrizeAmount = bonuses * winPercent[winPercent.length - 1] / PERCENT_DIVIDER * noFirstPrizePercent / PERCENT_DIVIDER;
//
//        _owner.transfer(toManagerAmount);
//        game.toManager = toManagerAmount;
//
//
//        for (uint8 i = 0; i < winPercent.length; i++) {
//            uint256 playerNumber = resultStat[i];
//            if (winPercent[i] != 0 && playerNumber != 0) {
//                uint256 winnings = bonuses * winPercent[i] / PERCENT_DIVIDER / playerNumber;
//                for (uint256 j = 0; j < ticketCount; j++) {
//                    if (tickets[j].rightNumber.length == i) {
//                        if (tickets[j].rightNumber.length != ticketCount) {
//                            tickets[j].player.transfer(winnings);
//                            ticketsAmount -= winnings;
//                            game.toPay += winnings;
//                            emit PayLog(gameIndex, payId, tickets[j].betId, winnings);
//                        } else {
//                            tickets[j].player.transfer(winnings + jackpot);
//                            game.toPay += (winnings + jackpot);
//                            emit PayLog(gameIndex, payId, tickets[j].betId, winnings + jackpot);
//                            jackpot = 0;
//                        }
//                        payId++;
//                    }
//                }
//            }
//        }
//        if (ticketsAmount > 0) {
//            if (resultStat[resultStat.length - 1] == 0) {
//                // If no one wins the first prize, part of the money will be withdrawn into a reserve fund
//                _owner.transfer(noFirstPrizeAmount);
//                game.toReserve += noFirstPrizeAmount;
//                bonuses -= noFirstPrizeAmount;
//            }
//
//            jackpot += bonuses;
//            game.toJackpot += bonuses;
//        }
//
//
//    }
//
//    function startNewGame() public onlyCroupier {
//        games.length++;
//        gameIndex++;
//        games[gameIndex].price = nextPrice;
//        games[gameIndex].startTime = now;
//
//        ticketCount = 0;
//
//        for (uint256 i = 0; i < resultStat.length; i++) {
//            resultStat[i] = 0;
//        }
//
//        isPause = false;
//    }
//
//    function setNextPrice(uint256 _nextPrice) public onlyCroupier {
//        require(_nextPrice > 0, "Invalid betting plan");
//        nextPrice = _nextPrice;
//    }
//
//    function setWinPercent(uint256[] _winPercent) public onlyCroupier {
//        winPercent = _winPercent;
//    }
//
//    function setIsPause(bool _isPause) public onlyCroupier {
//        isPause = _isPause;
//    }
//
//    function setDividendsPercent(uint256 _dividendsPercent) public onlyCroupier {
//        dividendsPercent = _dividendsPercent;
//    }
//
//    function setTechnicalPercent(uint256 _technicalPercent) public onlyCroupier {
//        technicalPercent = _technicalPercent;
//    }
//
//    function setNoFirstPrizePercent(uint256 _noFirstPrizePercent) public onlyCroupier {
//        noFirstPrizePercent = _noFirstPrizePercent;
//    }
//
//
//
//    // ----------------------- game read function -----------------------
//    function getWinNumbers(string bitcoinBlockHash) public view returns (uint256[]){
//        // bytes32 random = keccak256(bitcoinBlockHash);
//        bytes32 random = keccak256(abi.encodePacked(bitcoinBlockHash));
//        bytes memory allNumbers = new bytes(numbersCountMax);
//        bytes memory winNumbers = new bytes(numbersCount);
//
//        for (uint i = 0; i < numbersCountMax; i++) {
//            allNumbers[i] = byte(i + 1);
//        }
//
//        for (i = 0; i < numbersCount; i++) {
//            uint n = numbersCountMax - i;
//
//            uint r = (uint(random[i * 4]) + (uint(random[i * 4 + 1]) << 8) + (uint(random[i * 4 + 2]) << 16) + (uint(random[i * 4 + 3]) << 24)) % n;
//
//            winNumbers[i] = allNumbers[r];
//
//            allNumbers[r] = allNumbers[n - 1];
//        }
//        return winNumberstoUint(winNumbers);
//    }
//
//    function getGameTime() public view returns (
//        uint256 startTime,
//        uint256 closeTime,
//        uint256 drawTime
//    ){
//        Game storage game = games[gameIndex];
//        startTime = game.startTime;
//        drawTime = startTime + intervalTime;
//        closeTime = drawTime - disableBuyingTime;
//    }
//
//    function getCurrentGameSummary() public view returns (
//        uint64 _gameIndex,
//        uint256 startTime,
//        uint256 price,
//        uint256 _jackpot
//    ){
//        _gameIndex = gameIndex;
//        Game storage game = games[gameIndex];
//        startTime = game.startTime;
//        price = game.price;
//        _jackpot = jackpot;
//    }
//
//    function getGameInfo(uint64 _gameIndex) public view returns (
//        uint256 startTime,
//        uint256[] winNumbers,
//        uint256 price,
//        uint256 bitcoinBlockIndex,
//        string bitcoinBlockHash,
//        uint256 jackpot,
//        uint256 toJackpot,
//        uint256 toReserve,
//        uint256 toPay,
//        uint256 toManager
//    ){
//        Game storage game = games[_gameIndex];
//        startTime = game.startTime;
//        price = game.price;
//        winNumbers = game.winNumbers;
//        bitcoinBlockIndex = game.bitcoinBlockIndex;
//        bitcoinBlockHash = game.bitcoinBlockHash;
//        jackpot = game.jackpot;
//        toJackpot = game.toJackpot;
//        toReserve = game.toReserve;
//        toPay = game.toPay;
//        toManager = game.toManager;
//    }
//
//    function getTicketInfo(uint256 _ticketIndex) public view returns (
//        uint64 betId, address player, uint256[] betNumbers, uint256[] rightNumber, uint256 winnings
//    ){
//        Ticket storage ticket = tickets[_ticketIndex];
//
//        betId = ticket.betId;
//        player = ticket.player;
//        betNumbers = ticket.betNumbers;
//        rightNumber = ticket.rightNumber;
//        winnings = ticket.winnings;
//    }
//
//
//
//
//    // ----------------------- base function -----------------------
//    function buyTicket(uint256[] memory _betNumbers, address _referer) private {
//        require(checkRepeat(_betNumbers), "Invalid betting plan");
//
//        ticketCount++;
//        tickets.length = ticketCount;
//        tickets[ticketCount - 1].betId = betId;
//        tickets[ticketCount - 1].player = msg.sender;
//        tickets[ticketCount - 1].betNumbers = _betNumbers;
//        tickets[ticketCount - 1].rightNumber.length = 0;
//        tickets[ticketCount - 1].winnings = 0;
//
//        emit BetLog(gameIndex, betId, msg.sender, _betNumbers, _referer);
//        betId++;
//    }
//
//    function checkRepeat(uint256[] betNumbers) private view returns (bool){
//        Game storage game = games[gameIndex];
//
//        for (uint i = 0; i < betNumbers.length - 1; i++) {
//            for (uint j = i + 1; j < betNumbers.length; j++) {
//                if (betNumbers[i] == betNumbers[j]) return false;
//            }
//        }
//        return true;
//    }
//
//    function winNumberstoUint(bytes _winNumbers) private pure returns (uint256[]){
//        uint256[] memory winNumbers = new uint256[](_winNumbers.length);
//        for (uint256 m = 0; m < _winNumbers.length; m++) {
//            winNumbers[m] = uint256(_winNumbers[m]);
//        }
//
//        uint256 temp;
//        uint256 min;
//        for (uint256 i = 0; i < winNumbers.length - 1; i++) {
//            min = i;
//            for (uint256 j = i + 1; j < winNumbers.length; j++) {
//                if (winNumbers[j] < winNumbers[min]) {
//                    min = j;
//                }
//            }
//            if (min != i) {
//                temp = winNumbers[min];
//                winNumbers[min] = winNumbers[i];
//                winNumbers[i] = temp;
//            }
//        }
//        return winNumbers;
//    }
//
//    function isNeedDrawGame(uint bitcoinBlockIndex) private view returns (bool){
//        if (bitcoinBlockIndex <= 0) {
//            return false;
//        }
//
//        if (gameIndex > 0) {
//            Game storage game = games[gameIndex - 1];
//            return bitcoinBlockIndex > game.bitcoinBlockIndex;
//        }
//
//        return true;
//    }
//}
