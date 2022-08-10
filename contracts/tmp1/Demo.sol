pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

//第一次
//contract Demo is Initializable {
//    //define public a
//    uint256 public a;
//
//    //define initinalize    function
//    function initialize(uint256 _a) public {
//        a = _a;
//    }
//
//    //define increaseA external
//    function increaseA() external {
//        a = a + 10;
//    }
//    //need to change the function name
//
//}

//第二次 业务升级 存储结构不变
//主要步骤为 调用upgradeProxy 部署新合约 同时将新合约和代理合约地址传入交给ProxyAdmin 管理
contract Demo is Initializable {
    //define public a
    uint256 public a;

    //define initinalize    function
    function initialize(uint256 _a) public {
        a = _a;
    }

    //define increaseA external
    function increaseA() external {
        a = a + 100;
    }
    //need to change the function name

}
