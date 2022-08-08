pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract Demo is Initializable {
    //define public a
    uint256 public a;

    //define initinalize    function
    function initialize(uint256 _a) public {
        a = _a;
    }

    //define increaseA external
    function increaseA() external {
        a = a + 10;
    }
    //need to change the function name

}
