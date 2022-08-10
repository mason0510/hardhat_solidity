///**
// *Submitted for verification at Etherscan.io on 2019-03-14
//*/
//
//pragma solidity ^0.4.23;
//
//
///**
// * @title SafeMath
// * @dev Unsigned math operations with safety checks that revert on error
// */
//library SafeMath {
//    /**
//     * @dev Multiplies two unsigned integers, reverts on overflow.
//     */
//    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
//        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
//        // benefit is lost if 'b' is also tested.
//        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
//        if (a == 0) {
//            return 0;
//        }
//
//        uint256 c = a * b;
//        require(c / a == b);
//
//        return c;
//    }
//
//    /**
//     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
//     */
//    function div(uint256 a, uint256 b) internal pure returns (uint256) {
//        // Solidity only automatically asserts when dividing by 0
//        require(b > 0);
//        uint256 c = a / b;
//        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
//
//        return c;
//    }
//
//    /**
//     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
//     */
//    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
//        require(b <= a);
//        uint256 c = a - b;
//
//        return c;
//    }
//
//    /**
//     * @dev Adds two unsigned integers, reverts on overflow.
//     */
//    function add(uint256 a, uint256 b) internal pure returns (uint256) {
//        uint256 c = a + b;
//        require(c >= a);
//
//        return c;
//    }
//
//    /**
//     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
//     * reverts when dividing by zero.
//     */
//    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
//        require(b != 0);
//        return a % b;
//    }
//}
//
//
//
//contract Ownable {
//    address private _owner;
//
//    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//
//    constructor () internal {
//        _owner = msg.sender;
//        emit OwnershipTransferred(address(0), _owner);
//    }
//
//    /**
//     * @return the address of the owner.
//     */
//    function owner() public view returns (address) {
//        return _owner;
//    }
//
//    /**
//     * @dev Throws if called by any account other than the owner.
//     */
//    modifier onlyOwner() {
//        require(isOwner());
//        _;
//    }
//
//    /**
//     * @return true if `msg.sender` is the owner of the contract.
//     */
//    function isOwner() public view returns (bool) {
//        return msg.sender == _owner;
//    }
//
//    /**
//     * @dev Allows the current owner to transfer control of the contract to a newOwner.
//     * @param newOwner The address to transfer ownership to.
//     */
//    function transferOwnership(address newOwner) public onlyOwner {
//        _transferOwnership(newOwner);
//    }
//
//    /**
//     * @dev Transfers control of the contract to a newOwner.
//     * @param newOwner The address to transfer ownership to.
//     */
//    function _transferOwnership(address newOwner) internal {
//        require(newOwner != address(0));
//        emit OwnershipTransferred(_owner, newOwner);
//        _owner = newOwner;
//    }
//}
//
//
//
////【Currently only TRX is supported, waiting for updates】
//interface House {
//
//    function addGame(address _gameContract, uint _id) public;
//
//    function setActive(address _gameContract, bool _active) public;
//
//    function deposit(
//        address _gameContract,
//        address _from,
//        address _tokenContract,
//        uint _quantity
//    ) public payable;
//
//    function pay(
//        address _gameContract,
//        address _to,
//        uint _bet,
//        uint _payout,
//        address _tokenContract,
//        address _referer
//    ) public;
//
//    function updateToken(
//        address _gameContract,
//        string _sym,
//        address _tokenContract,
//        uint _min,
//        uint _maxPayout,
//        uint _balance
//    ) public;
//
//    function clearToken(address _gameContract) public;
//
//}
//
//
//contract RoundBasedGame is Ownable {
//    using SafeMath for *;
//
//    address private _revealKey;
//
//    uint private constant BET_CUTOFF = 5 seconds;//截止时间
//    uint private constant ROUND_TIME = 45 seconds;//每回合时间总时长
//    uint private constant BETWEEN_ROUND_TIME = 10 seconds;//游戏间隔
//
//    uint64 internal _roundId = 0;//游戏id，递增
//    uint64 internal _betId = 0;//投注id，递增
//    bytes32 internal _seedHash;//种子
//    uint internal _roundStartTime = 0;
//    uint internal _roundEndTime = 0;//开奖时间，比如大于才可开奖
//    uint8 internal _result = 0;
//
//    House public house;
//
//
//    //投注结构体
//    struct Bet {
//        uint64 betId;
//        uint8 betType;
//        uint amount;//金额
//        address player;//投注者
//        address referer;//邀请人
//        uint time;
//    }
//
//    //当前赌局所有投注
//    Bet[] public _bets;
//
//    //日志
//    event RoundStart(uint64 indexed roundId, bytes32 seed);//每场游戏种子
//    event RoundResult(uint64 indexed roundId, uint result);//每场游戏结果
//    event BetPlaced(uint64 betId, uint64 gameId, address player, uint8 betType, uint bet, uint time);//每场胜利记录
//    event BetResult(uint64 betId, uint64 gameId, address player, uint8 betType,
//        uint8 result, uint bet, uint payout, uint time);//每场胜利记录
//
//    // Constructor.
//    constructor () public Ownable() {
//        _revealKey = msg.sender;
//        doStartRound();
//    }
//
//    function setHouse(address _houseAddr) external onlyOwner {
//        house = House(_houseAddr);
//    }
//
//    function setRevealKey(address revealKey) external onlyOwner {
//        _revealKey = revealKey;
//    }
//
//    function kill() external onlyOwner {
//        // require(_bets.length == 0, "All bets should be processed (settled or refunded) before self-destruct.");
//        selfdestruct(owner());
//    }
//
//    // function deposit() external payable {
//
//    // }
//
//    // function extract(address addr, uint amount) external onlyOwner {
//    //     require(addr != address(0));
//    //     addr.transfer(amount);
//    // }
//
//    //下注
//    function makeBet(uint64 betRoundId, uint8[] types, uint[] amounts, address referer) external payable {
//        require(betRoundId == _roundId, "can not make bet for round");
//        // require(now < _roundEndTime - BET_CUTOFF, "Round already finished, can not make bet");
//
//        _betId++;
//
//        uint total = 0;
//
//        for (uint i = 0; i < types.length; i++) {
//            total = SafeMath.add(amounts[i], total);
//            _bets.push(Bet(_betId, types[i], amounts[i], msg.sender, referer, now));
//            emit BetPlaced(_betId, _roundId, msg.sender, types[i], amounts[i], now);
//        }
//
//        require(total == msg.value, "Amount incorrect");
//
//
//        house.deposit(
//            address(this),
//            msg.sender,
//            address(0),
//            msg.value
//        );
//        if(!address(house).send(msg.value)){
//            throw;
//        }
//    }
//
//    //开奖
//    function reveal(uint8 v, bytes32 r, bytes32 s) {
//        // require(now > _roundEndTime - BET_CUTOFF, "Can not reveal yet");
//        // require(_revealKey == ecrecover(_seedHash, v, r, s), "ECDSA signature is not valid.");
//
//        makeResult(uint(keccak256(abi.encodePacked(r, s))));
//        for (uint i = 0; i < _bets.length; i++) {
//            Bet storage bet = _bets[i];
//            uint payout = getPayout(bet);
//            if (payout > 0) {
//                //bet.player.transfer(payout);
//
//
//                house.pay(
//                    address(this),
//                    bet.player,
//                    bet.amount,
//                    payout,
//                    address(0),
//                    bet.referer
//                );
//            }
//            emit BetResult(bet.betId, _roundId, bet.player, bet.betType, _result, bet.amount, payout, bet.time);
//        }
//        emit RoundResult(_roundId, _result);
//
//        _bets.length = 0;
//        doStartRound();
//    }
//
////    function makeResult(uint seed) internal {
////
////    }
////
////
////    function getPayout(Bet storage bet) internal returns (uint){
////
////    }
//
//    //开始游戏
//    function doStartRound() private {
//        require(_bets.length == 0, "All bets should be processed before new round");
//
//        _roundId += 1;
//        _seedHash = keccak256(abi.encodePacked(address(this), _roundId, blockhash(block.number)));
//        _roundStartTime = now + BETWEEN_ROUND_TIME;
//        _roundEndTime = _roundStartTime + ROUND_TIME;
//        emit RoundStart(_roundId, _seedHash);
//    }
//
//
//}
//
//contract Baccarat is RoundBasedGame {
//    using SafeMath for *;
//
//    uint8 constant private CARD_COUNT = 52;
//    uint8 constant private BET_BANKER_WIN = 1;
//    uint8 constant private BET_PLAYER_WIN = 2;
//    uint8 constant private BET_TIE = 4;
//    uint8 constant private BET_BANKER_PAIR = 8;
//    uint8 constant private BET_PLAYER_PAIR = 16;
//
//    uint8[3] private _playerCards;
//    uint8[3] private _bankerCards;
//
//    function currentRound() public view returns (uint64, bytes32, uint, uint, uint, uint8[3], uint8[3]) {
//        uint8[3] memory playerCards;
//        uint8[3] memory bankerCards;
//        for (uint i = 0; i < 3; i++) {
//            playerCards[i] = _playerCards[i];
//            bankerCards[i] = _bankerCards[i];
//        }
//        return (_roundId, _seedHash, _roundStartTime, _roundEndTime, _result, playerCards, bankerCards);
//    }
//
//    function makeResult(uint seed) internal {
//        uint8 roundResult = 0;
//        (uint8 playerPoint, uint8 bankerPoint) = drawCards(seed);
//        if (bankerPoint > playerPoint) {
//            roundResult = BET_BANKER_WIN;
//        } else if (playerPoint > bankerPoint) {
//            roundResult = BET_PLAYER_WIN;
//        } else {
//            roundResult = BET_TIE;
//        }
//
//        if (_bankerCards[0] % 13 == _bankerCards[1] % 13) {
//            roundResult |= BET_BANKER_PAIR;
//        }
//        if (_playerCards[0] % 13 == _playerCards[1] % 13) {
//            roundResult |= BET_PLAYER_PAIR;
//        }
//        _result = roundResult;
//    }
//
//    function getPayout(Bet storage bet) internal returns (uint) {
//        uint8 betType = bet.betType;
//        if (betType & _result != 0) {
//            if (betType == BET_BANKER_WIN) {
//                return SafeMath.div(SafeMath.mul(bet.amount, 195), 100);
//            } else if (betType == BET_PLAYER_WIN) {
//                return SafeMath.mul(bet.amount, 2);
//            } else if (betType == BET_TIE) {
//                return SafeMath.mul(bet.amount, 9);
//            } else if (betType == BET_BANKER_PAIR || betType == BET_PLAYER_PAIR) {
//                return SafeMath.mul(bet.amount, 12);
//            }
//        }
//        return 0;
//    }
//
//    function drawCards(uint seed) private returns (uint8, uint8) {
//        uint8 playerPoint = 0;
//        uint8 bankPoint = 0;
//        uint8 cardDrawn = 0;
//        uint8 drawnValue = 0;
//
//        (seed, cardDrawn, drawnValue, playerPoint) = drawCard(playerPoint, seed);
//        _playerCards[0] = cardDrawn;
//
//        (seed, cardDrawn, drawnValue, playerPoint) = drawCard(playerPoint, seed);
//        _playerCards[1] = cardDrawn;
//
//        (seed, cardDrawn, drawnValue, bankPoint) = drawCard(bankPoint, seed);
//        _bankerCards[0] = cardDrawn;
//
//        (seed, cardDrawn, drawnValue, bankPoint) = drawCard(bankPoint, seed);
//        _bankerCards[1] = cardDrawn;
//
//        if (bankPoint < 8 && playerPoint < 8) {
//            if (playerPoint < 6) {
//                (seed, cardDrawn, drawnValue, playerPoint) = drawCard(playerPoint, seed);
//                _playerCards[2] = cardDrawn;
//
//                if (bankerDrawThirdCard(bankPoint, drawnValue)) {
//                    (seed, cardDrawn, drawnValue, bankPoint) = drawCard(bankPoint, seed);
//                    _bankerCards[2] = cardDrawn;
//                }
//            } else if (bankPoint < 6) {
//                (seed, cardDrawn, drawnValue, playerPoint) = drawCard(bankPoint, seed);
//                _bankerCards[2] = cardDrawn;
//            }
//        }
//        return (playerPoint, bankPoint);
//    }
//
//    function bankerDrawThirdCard(uint8 bankerPoint, uint8 playerThirdCard) private pure returns (bool) {
//        if (bankerPoint <= 2) {
//            return true;
//        } else if (bankerPoint == 3) {
//            return playerThirdCard != 8;
//        } else if (bankerPoint == 4) {
//            return playerThirdCard >= 2 && playerThirdCard <= 7;
//        } else if (bankerPoint == 5) {
//            return playerThirdCard >= 4 && playerThirdCard <= 7;
//        } else if (playerThirdCard == 6) {
//            return playerThirdCard == 6 || playerThirdCard == 7;
//        }
//        return false;
//    }
//
//    function drawCard(uint8 point, uint seed) private pure returns (uint, uint8, uint8, uint8) {
//        uint8 card = uint8(seed % CARD_COUNT);
//        seed = seed / CARD_COUNT;
//        uint8 cardPoint = (card % 13) + 1;
//        if (cardPoint >= 10) {
//            cardPoint = 0;
//        }
//        point = (point + cardPoint) % 10;
//        return (seed, card, cardPoint, point);
//    }
//}
