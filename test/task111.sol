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


contract DividendManager {
    using SafeMath for uint256;

    function payDividend() public payable {
        address(this).balance.add(msg.value);
    }

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
}

contract Escrow is Ownable {
    using SafeMath for uint256;

    address public manager;

    DividendManager public Contract;

    constructor(address _contract) public{
        Contract = DividendManager(_contract);
    }

    function () public payable {
        address(this).balance.add(msg.value);
    }

    function setManager(address _newManager) public onlyOwner {
        require(_newManager != address(0));
        manager = _newManager;
    }

    function transferDividends() public {
        require((msg.sender == owner) || (msg.sender == manager));
        address(Contract).call.value(address(this).balance)(bytes4(keccak256("payDividend()")));
    }
}