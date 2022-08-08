pragma solidity ^0.8.0;
import "hardhat/console.sol";
contract ImplementationV1 {
    address public owner;
    mapping (address => uint) internal points;

    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }

    function initOwner() external {
        require (owner == address(0));
        owner = msg.sender;
    }

    function addPlayer(address _player, uint _points)
    public onlyOwner virtual
    {
        console.log("_player:=%s  _points:=%s ", _player, _points);
        require (points[_player] == 0);
        points[_player] = _points;
    }

    function setPoints(address _player, uint _points)
    public onlyOwner
    {
        require (points[_player] != 0);
        points[_player] = _points;
    }
    //test方法
    function test() public virtual {
        console.log("+++++++++++++++++++++++++++++++++++++++test");
    }
}

