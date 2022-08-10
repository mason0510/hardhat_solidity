///**
// *Submitted for verification at Etherscan.io on 2019-03-11
//*/
//
//pragma solidity ^0.4.23;
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
//    uint internal _result = 0;
//
//
//
//    //投注结构体
//    struct Bet {
//        uint betType;
//        uint amount;//总金额
//        address player;//投注者
//        address referer;//邀请人
//    }
//
//    //当前赌局所有投注
//    Bet[] public _bets;
//
//    //日志
//    event RoundStart(uint indexed roundId, bytes32 seed);//每场游戏种子
//    event RoundResult(uint64 indexed roundId, uint result);//每场游戏结果
//    event Payment(address indexed beneficiary, uint amount, uint64 betId);//每场胜利记录
//
//    // Standard modifier on methods invokable only by contract owner.
//    modifier onlyActor {
//        require(msg.sender == _revealKey, "onlyActor methods called by non-actor.");
//        _;
//    }
//
//    // Constructor.
//    constructor () public Ownable() {
//        _revealKey = msg.sender;
//        doStartRound();
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
//    function deposit() external payable {
//
//    }
//
//    function extract(address addr, uint amount) external onlyOwner {
//        require(addr != address(0));
//        addr.transfer(amount);
//    }
//
//    //下注
//    // function bet(uint64 betRoundId, uint[] types, uint[] amounts) external payable {
//    function makeBet(uint64 betRoundId, uint[] types, uint[] amounts, address referer) external payable {
//        require(betRoundId == _roundId, "can not make bet for round");
//        // require(now < _roundEndTime - BET_CUTOFF, "Round already finished, can not make bet");
//
//        _betId++;
//
//        uint total = 0;
//
//        for (uint i = 0; i < types.length; i++) {
//            total = SafeMath.add(amounts[i], total);
//            _bets.push(Bet(types[i], amounts[i], msg.sender, referer));
//        }
//        require(total == msg.value, "Amount incorrect");
//    }
//
//    //开奖
//    function reveal(uint8 v, bytes32 r, bytes32 s) external onlyActor {
//        require(now > _roundEndTime - BET_CUTOFF, "Can not reveal yet");
//        //require(_revealKey == ecrecover(_seedHash, v, r, s), "ECDSA signature is not valid.");
//
//
//        makeResult(uint(keccak256(abi.encodePacked(r, s))));
//
//        for (uint i = 0; i < _bets.length; i++) {
//            getPayout(_bets[i]);
//        }
//
//        emit RoundResult(_roundId, _result);
//
//        _bets.length = 0;
//        doStartRound();
//    }
//
//    function makeResult(uint seed) internal {
//
//    }
//
//
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
//    function currentRound() public view returns (uint, bytes32, uint, uint) {
//        return (_roundId, _seedHash, _roundStartTime, _roundEndTime);
//    }
//}
//
//contract Roulette is Ownable, RoundBasedGame{
//    using SafeMath for *;
//
//
//    uint public MAX_NUM = 37;//结果取值范围[0-36]
//    uint public SP = 36;//赔率
//    uint public REFERER_REWARD = 5;//推荐人奖励（%）
//
//
//    // function bet(uint64 betRoundId, uint[] types, uint[] amounts, address referer) external payable {
//
//    // referer = address(0);
//    // makeBet(betRoundId, types, amounts, referer);
//
//    // }
//
//    function getPayout(Bet storage bet) internal returns (uint){
//        uint amount = 0;//奖金
//        if (_result == bet.betType) {
//            amount = SafeMath.add(SafeMath.mul(bet.amount, SP), amount);
//
//            bet.player.transfer(amount);
//            emit Payment(bet.player, amount, _betId);
//        }
//
//        if(bet.referer != address(0)){
//            bet.referer.transfer(SafeMath.mul(bet.amount, REFERER_REWARD)/100);
//        }
//        return amount;
//    }
//
//
//    function makeResult(uint seed) internal {
//        _result = seed % MAX_NUM;
//    }
//
//
//
//
//}
