//pragma solidity >=0.4.12<=0.8.7;
//import "hardhat/console.sol";
////Ownable
//import "../Common/Ownable.sol";
////SafeMath
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//
//
///**
// * @title Pausable
// * @dev Base contract which allows children to implement an emergency stop mechanism.
// */
//contract Pausable is Ownable {
//    event Pause();
//    event Unpause();
//
//    bool public paused = false;
//
//
//    /**
//     * @dev modifier to allow actions only when the contract IS paused
//   */
//    modifier whenNotPaused() {
//        if (paused) revert();
//        _;
//    }
//
//    /**
//     * @dev modifier to allow actions only when the contract IS NOT paused
//   */
//    modifier whenPaused {
//        if (!paused) revert();
//        _;
//    }
//
//    /**
//     * @dev called by the owner to pause, triggers stopped state
//   */
//    function pause() public onlyOwner whenNotPaused returns (bool) {
//        paused = true;
//        Pause();
//        return true;
//    }
//
//    /**
//     * @dev called by the owner to unpause, returns to normal state
//   */
//    function unpause() public onlyOwner whenPaused returns (bool) {
//        paused = false;
//        Unpause();
//        return true;
//    }
//}
//
///**
// * @title ERC20Basic
// * @dev Simpler version of ERC20 interface
// * @dev see https://github.com/ethereum/EIPs/issues/20
// */
//abstract contract ERC20Basic {
//    uint public _totalSupply;
//    function totalSupply()  public returns (uint);
//    function balanceOf(address who) public returns (uint);
//    function transfer(address to, uint value)public;
//    event Transfer(address indexed from, address indexed to, uint value);
//}
//
///**
// * @title ERC20 interface
// * @dev see https://github.com/ethereum/EIPs/issues/20
// */
//contract ERC20 is ERC20Basic {
//    function allowance(address owner, address spender)  public returns (uint);
//    function transferFrom(address from, address to, uint value)public;
//    function approve(address spender, uint value)public;
//    event Approval(address indexed owner, address indexed spender, uint value);
//}
//
///**
// * @title Basic token
// * @dev Basic version of StandardToken, with no allowances.
// */
//contract BasicToken is Ownable, ERC20Basic {
//    using SafeMath for uint;
//
//    mapping(address => uint) balances;
//
//    // additional variables for use if transaction fees ever became necessary
//    uint public basisPointsRate = 0;
//    uint public maximumFee = 0;
//
//    /**
//     * @dev Fix for the ERC20 short address attack.
//   */
//    modifier onlyPayloadSize(uint size) {
//        if(msg.data.length < size + 4) {
//            revert();
//        }
//        _;
//    }
//
//    /**
//    * @dev transfer token for a specified address
//  * @param _to The address to transfer to.
//  * @param _value The amount to be transferred.
//  */
//    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
//        uint fee = (_value.mul(basisPointsRate)).div(10000);
//        if (fee > maximumFee) {
//            fee = maximumFee;
//        }
//        uint sendAmount = _value.sub(fee);
//        balances[msg.sender] = balances[msg.sender].sub(_value);
//        balances[_to] = balances[_to].add(sendAmount);
//        balances[owner] = balances[owner].add(fee);
//        Transfer(msg.sender, _to, sendAmount);
//        Transfer(msg.sender, owner, fee);
//    }
//
//    /**
//    * @dev Gets the balance of the specified address.
//  * @param _owner The address to query the the balance of.
//  * @return mybalance An uint representing the amount owned by the passed address.
//  */
//    function balanceOf(address _owner)  public returns (uint mybalance) {
//        uint mybalance= balances[_owner];
//        return mybalance;
//    }
//
//}
//
//
///**
// * @title Standard ERC20 token
// *
// * @dev Implementation of the basic standard token.
// * @dev https://github.com/ethereum/EIPs/issues/20
// * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
// */
//contract StandardToken is BasicToken, ERC20 {
//
//    mapping (address => mapping (address => uint)) allowed;
//
//    uint  MAX_UINT = 2**256 - 1;
//
//    /**
//     * @dev Transfer tokens from one address to another
//   * @param _from address The address which you want to send tokens from
//   * @param _to address The address which you want to transfer to
//   * @param _value uint the amount of tokens to be transferred
//   */
//    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
//        int _allowance = allowed[_from][msg.sender];
//         //storage _allowance=allowed[_from][msg.sender];
//
//        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
//        // if (_value > _allowance) revert();
//
//        uint fee = (_value.mul(basisPointsRate)).div(10000);
//        if (fee > maximumFee) {
//            fee = maximumFee;
//        }
//        uint sendAmount = _value.sub(fee);
//
//        balances[_to] = balances[_to].add(sendAmount);
//        balances[owner] = balances[owner].add(fee);
//        balances[_from] = balances[_from].sub(_value);
//        if (_allowance < MAX_UINT) {
//            allowed[_from][msg.sender] = _allowance.sub(_value);
//        }
//        Transfer(_from, _to, sendAmount);
//        Transfer(_from, owner, fee);
//    }
//
//    /**
//     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
//   * @param _spender The address which will spend the funds.
//   * @param _value The amount of tokens to be spent.
//   */
//    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
//
//        // To change the approve amount you first have to reduce the addresses`
//        //  allowance to zero by calling `approve(_spender, 0)` if it is not
//        //  already 0 to mitigate the race condition described here:
//        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
//        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();
//
//        allowed[msg.sender][_spender] = _value;
//        Approval(msg.sender, _spender, _value);
//    }
//
//    /**
//     * @dev Function to check the amount of tokens than an owner allowed to a spender.
//   * @param _owner address The address which owns the funds.
//   * @param _spender address The address which will spend the funds.
//   * @return remaining A uint specifying the amount of tokens still available for the spender.
//   */
//    function allowance(address _owner, address _spender)  public view returns (int remaining) {
//        return allowed[_owner][_spender];
//    }
//
//}
//
//contract UpgradedStandardToken is StandardToken{
//    // those methods are called by the legacy contract
//    // and they must ensure msg.sender to be the contract address
//    function transferByLegacy(address from, address to, uint value)public ;
//    function transferFromByLegacy(address sender, address from, address spender, uint value)public ;
//    function approveByLegacy(address from, address spender, uint value)public ;
//}
//
//
///// @title - Tether Token Contract - Tether.to
///// @author Enrico Rubboli - <enrico@bitfinex.com>
///// @author Will Harborne - <will@ethfinex.com>
//
//contract TetherToken.json is Pausable, StandardToken {
//
//    string public name;
//    string public symbol;
//    uint public decimals;
//    address public upgradedAddress;
//    bool public deprecated;
//
//    //  The contract can be initialized with a number of tokens
//    //  All the tokens are deposited to the owner address
//    //
//    // @param _balance Initial supply of the contract
//    // @param _name Token Name
//    // @param _symbol Token symbol
//    // @param _decimals Token decimals
//     constructor(uint _initialSupply, string memory _name, string memory _symbol, uint _decimals){
//        _totalSupply = _initialSupply;
//        name = _name;
//        symbol = _symbol;
//        decimals = _decimals;
//        balances[owner] = _initialSupply;
//        deprecated = false;
//    }
//
//    // Forward ERC20 methods to upgraded contract if this one is deprecated
//    function transfer(address _to, uint _value)public  whenNotPaused {
//        if (deprecated) {
//            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
//        } else {
//            return super.transfer(_to, _value);
//        }
//    }
//
//    // Forward ERC20 methods to upgraded contract if this one is deprecated
//    function transferFrom(address _from, address _to, uint _value) public whenNotPaused {
//        if (deprecated) {
//            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
//        } else {
//            return super.transferFrom(_from, _to, _value);
//        }
//    }
//
//    // Forward ERC20 methods to upgraded contract if this one is deprecated
//    function balanceOf(address who) public returns (uint){
//        if (deprecated) {
//            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
//        } else {
//            return super.balanceOf(who);
//        }
//    }
//
//    // Forward ERC20 methods to upgraded contract if this one is deprecated
//    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {
//        if (deprecated) {
//            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
//        } else {
//            return super.approve(_spender, _value);
//        }
//    }
//
//    // Forward ERC20 methods to upgraded contract if this one is deprecated
//    function allowance(address _owner, address _spender)public  returns (uint remaining) {
//        if (deprecated) {
//            return StandardToken(upgradedAddress).allowance(_owner, _spender);
//        } else {
//            return super.allowance(_owner, _spender);
//        }
//    }
//
//    // deprecate current contract in favour of a new one
//    function deprecate(address _upgradedAddress) public onlyOwner {
//        deprecated = true;
//        upgradedAddress = _upgradedAddress;
//        Deprecate(_upgradedAddress);
//    }
//
//    // deprecate current contract if favour of a new one
//    function totalSupply()public  returns (uint){
//        if (deprecated) {
//            return StandardToken(upgradedAddress).totalSupply();
//        } else {
//            return _totalSupply;
//        }
//    }
//
//    // Issue a new amount of tokens
//    // these tokens are deposited into the owner address
//    //
//    // @param _amount Number of tokens to be issued
//    function issue(uint amount)public onlyOwner {
//        if (_totalSupply + amount < _totalSupply) revert();
//        if (balances[owner] + amount < balances[owner]) revert();
//
//        balances[owner] += amount;
//        _totalSupply += amount;
//        Issue(amount);
//    }
//
//    // Redeem tokens.
//    // These tokens are withdrawn from the owner address
//    // if the balance must be enough to cover the redeem
//    // or the call will fail.
//    // @param _amount Number of tokens to be issued
//    function redeem(uint amount) public onlyOwner {
//        if (_totalSupply < amount) revert();
//        if (balances[owner] < amount) revert();
//
//        _totalSupply -= amount;
//        balances[owner] -= amount;
//        Redeem(amount);
//    }
//
//    function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner {
//        // Ensure transparency by hardcoding limit beyond which fees can never be added
//        if (newBasisPoints > 20) revert();
//        if (newMaxFee > 50) revert();
//
//        basisPointsRate = newBasisPoints;
//        maximumFee = newMaxFee.mul(10**decimals);
//
//        Params(basisPointsRate, maximumFee);
//    }
//
//    // Called when new token are issued
//    event Issue(uint amount);
//
//    // Called when tokens are redeemed
//    event Redeem(uint amount);
//
//    // Called when contract is deprecated
//    event Deprecate(address newAddress);
//
//    // Called if contract ever adds fees
//    event Params(uint feeBasisPoints, uint maxFee);
//}
