/**
 *Submitted for verification at Etherscan.io on 2019-03-07
*/

// pragma solidity ^0.5.0;
pragma solidity ^0.4.23;



//temp
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// import "./Ownalbe.sol";
// import "./SafeMath.sol";


// contract RoundBasedGame is Ownable {
contract RoundBasedGame is Ownable {
    // using SafeMath for *;

    address private _actor;

    uint private constant ROUND_TIME = 40 seconds;//每回合时间总时长
    uint private constant BETWEEN_ROUND_TIME = 10 seconds;

    uint64 private _roundId = 0;//游戏id，递增
    uint64 private _betId = 0;//同回合投注id，递增
    bytes32 private _seedHash;//种子
    bool private _roundActive = false;//游戏flag，默认 未开始
    uint private _roundEndTime = 0;//开奖时间，比如大于才可开奖


    struct BetItem {
        uint8 betType;//投注类型
        uint80 amount;//数量
    }

    //投注结构体
    struct Bet {
        uint80 amount;
        BetItem[] bets;
        address player;//投注者
        address referer;//邀请人
    }

    //当前赌局所有投注
    Bet[] public _bets;

    //
    event GameResult(uint64 indexed roundId, uint result);
    event Payment(address indexed beneficiary, uint amount, uint64 betId);

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyActor {
        require(msg.sender == _actor, "onlyActor methods called by non-actor.");
        _;
    }

    // Constructor.
    constructor () public Ownable() {

    }


    function setActor(address actor) external onlyOwner {
        _actor = actor;
    }

    function kill() external onlyOwner {
        require(_bets.length == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner());
    }

    function startRound() external onlyActor {
        require(_bets.length == 0, "All bets should be processed before new round");
        require(_roundActive == false && now > _roundEndTime, "Can not start a new round yet");

        _roundId += 1;
        _roundActive = true;
        _seedHash = keccak256(address(this), _roundId, abi.encodePacked(blockhash(block.number)));
        _roundEndTime = now + ROUND_TIME;
    }

    function bet(uint64 betRoundId, uint8[] types, uint80[] amounts) external payable {
        require(betRoundId == _roundId && _roundActive == true, "can not make bet for round");
        require(types.length == amounts.length, "number of types and amounts does not match");

        uint256 amount = 0;
        Bet storage newBet = _bets[_betId];
        _betId++;

        for (uint i = 0; i < types.length; i++) {
            amount = SafeMath.add(amounts[i], amount);
            BetItem storage item = newBet.bets[i];
            item.betType = types[i];
            item.amount = amounts[i];
        }

        require(amount == msg.value, "bet amount does not match");

    }

    function reveal(bytes32 r, bytes32 s) external onlyActor returns (bytes32 entropy) {
        require(_roundActive == true && now > _roundEndTime, "can not reveal yet");
        require(_actor == ecrecover(_seedHash, 27, r, s), "ECDSA signature is not valid.");

        _roundActive = false;
        delete _seedHash;

        return keccak256(abi.encodePacked(r, s));
    }

    function roundStatus() external view returns (uint roundId, bytes32 seedHash, bool roundActive, uint roundEndTime) {
        return (_roundId, _seedHash, _roundActive, _roundEndTime);
    }
}
