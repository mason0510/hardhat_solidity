/**
 *Submitted for verification at Etherscan.io on 2019-03-07
*/

pragma solidity ^0.4.0;

// import "../common/Ownalbe.sol";

// contract Dice is Ownable{
contract Dice {

    //所有者
    // address private owner;
    //开奖人(开奖签名用)
    address public secretSigner;


    //构造
    constructor (address _secretSigner) public {
        // owner = msg.sender;
        secretSigner = _secretSigner;
    }

    //货币汇率 18
    uint currency = 1000000000000000000;
    //最小投注
    uint public minBet = 1 * 1000000000000000000 /100;

    //推荐人奖励%
    uint public refererReward = 5;


    //赌局信息（记录）
    // mapping(address => Bet) public betMap;
    Bet[] public betArr;

    //赌局结构体
    struct Bet {
        uint betId;//赌局id
        address player;//游戏者
        uint betNum;//投注金额
        uint payout;//获奖金额
        bytes32 seed;//种子
        uint betVal;//投注方案
        uint rollVal;//开奖结果
        address referer;//邀请者
        bool isReveal;//是否已开奖
    }

    //日志记录
    // event BetMsg (
    //     uint betId,//赌局id
    //     address player,//游戏者
    //     uint betNum,//投注金额
    //     uint payout,//获奖金额
    //     uint seed,//种子
    //     uint8_t betVal,//投注方案
    //     uint8_t rollVal,//开奖结果
    //     address referer//邀请者
    // );

    /*
        投注
        @params
            betVal 投注方案
            referer 邀请者
    */
    function bet(uint betVal, address referer) public payable {
        require(msg.value >= minBet, "Amount should be within range.");

        //分发邀请人奖励
        if(referer != address(0x0)){
            msg.sender.transfer(msg.value * refererReward / 100);
        }

        createBet(msg.sender, msg.value, betVal, referer);
    }

    //创建赌局
    function createBet(address player, uint betNum, uint betVal, address referer) private{
        uint betId = betArr.length;

        bytes32 seed = createSeed(betId);

        Bet memory bet = Bet(
            betId,//赌局id
            player,//游戏者
            betNum,//投注金额
            0,//获奖金额
            seed,//种子
            betVal,//投注方案
            0,//开奖结果
            referer,//邀请者
            false//是否已开奖
        );

        betArr.push(bet);
    }

    //创建种子
    function createSeed(uint betId) private returns(bytes32){
        // bytes32 seed = keccak256(abi.encode("dice", betId, block.difficulty));
        bytes32 seed = keccak256(abi.encode("dice", betId, blockhash(block.number)));



        return seed;
    }





    /*
        开奖
        @params
            betId 赌局id
            signature 签名
    */
    function reveal(uint betId ,bytes32 r, bytes32 s) public {
        validateSign(betId, r, s);

        random(r, s, 100);
    }

    //游戏id
    bytes32 public aaa;
    address public bbb;

    function reveal1(bytes32 hash, bytes memory signature) public {
        // Note: this only verifies that signer is correct.
        // You'll also need to verify that the hash of the data
        // is also correct.
        bytes32  r = bytesToBytes32(slice(signature, 0, 32));
        bytes32  s = bytesToBytes32(slice(signature, 32, 32));

        bbb = ecrecover(hash, 27, r, s);

        require(secretSigner == ecrecover(hash, 27, r, s), "ECDSA signature is not valid.");

    }

    //产生随机数（开奖结果）
    function random(bytes32 r, bytes32 s, uint maxNum) private returns(uint){
        uint randomNum = (uint(keccak256(abi.encodePacked(r, s))) % maxNum) + 1;
        return randomNum;
    }

    //验证签名
    function validateSign(uint betId ,bytes memory signature) private{
        Bet memory bet = betArr[betId];

        bytes32  r = bytesToBytes32(slice(signature, 0, 32));
        bytes32  s = bytesToBytes32(slice(signature, 32, 32));

        bbb = ecrecover(bet.seed, 27, r, s);

        require(secretSigner == ecrecover(bet.seed, 27, r, s), "ECDSA signature is not valid.");
    }

    //验证签名
    function validateSign(uint betId ,bytes32 r, bytes32 s) private{
        Bet memory bet = betArr[betId];


        bbb = ecrecover(bet.seed, 27, r, s);

        require(secretSigner == ecrecover(bet.seed, 27, r, s), "ECDSA signature is not valid.");
    }

    //将原始数据按段切割出来指定长度
    function slice(bytes memory data, uint start, uint len) private returns (bytes memory){
        bytes memory b = new bytes(len);

        for(uint i = 0; i < len; i++){
            b[i] = data[i + start];
        }

        return b;
    }

    //bytes转换为bytes32
    function bytesToBytes32(bytes memory source) private returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }



}
