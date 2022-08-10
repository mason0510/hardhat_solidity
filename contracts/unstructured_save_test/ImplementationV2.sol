pragma solidity ^0.8.4;

import "./ImplementationV1.sol";


contract ImplementationV2 is ImplementationV1{
    //add new uint public totalPlayers;
    uint public totalPlayers;
    function addPlayer(address _player, uint _points) public override  {
       // require (points[_player] == 0);
        points[_player] = _points;
        totalPlayers++;
    }
    //getTotalPlayers
    function getTotalPlayers() public view returns (uint) {
        return totalPlayers;
    }
    //get owner
    function getOwner() public view returns (address) {
        return owner;
    }
    //test方法
    function test() public override virtual {
        console.log("+++++++++++++++++++++++++++++++++++++++test2");
    }
}
