pragma solidity ^0.4.12;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

contract LastWill is Ownable {
    using SafeMath for uint256;

    address heir;
    uint timeStart;
    uint time;

    constructor(){
        timeStart = now;
    }

    function () public payable {
        address(this).balance.add(msg.value);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function setHeir(address _heir) public onlyOwner {
        heir = _heir;
    }

    function setTime(uint _days) public onlyOwner {
        time = _days * 1 days;
    }

    function transferMoney(address _to, uint _value) public onlyOwner {
        _to.transfer(_value);
    }

    function withdraw(address _to) public {
        require(msg.sender == heir);
        require(now > timeStart + time);
        _to.transfer(address(this).balance);
    }
}
