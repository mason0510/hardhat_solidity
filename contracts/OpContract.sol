pragma solidity ^0.8.0;

import "./Common/Ownable.sol";

contract OpContract is Ownable {
    constructor() public payable {
    }

    function createProxy(address masterCopy, bytes memory data)
    public
    returns (Proxy proxy)
    {
        proxy = new Proxy(masterCopy);
        if (data.length > 0)
        // solium-disable-next-line security/no-inline-assembly
            assembly {
                if eq(call(gas, proxy, 0, add(data, 0x20), mload(data), 0, 0), 0) { revert(0, 0) }
            }
        emit ProxyCreation(proxy);
    }

    //withdraw(address _to, uint _value)
    function withdraw(address _to, uint _value) external only_owner{
        //要求_to为contract address(0x0)
        if(_to.isContract()){
            revert(0, 0);
        }
        if(_value > 0){
            address(this).transfer(_to, _value);
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}
