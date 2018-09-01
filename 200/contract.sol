pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Contract {
    using SafeMath for uint;

    address owner;

    mapping (address => uint) deposit;
    mapping (address => uint) withdrawn;
    mapping (address => uint) lastTimeWithdraw;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
    }

    function getInfo() public view returns(uint Deposit, uint Withdrawn, uint AmountToWithdraw) {
        Deposit = deposit[msg.sender];
        Withdrawn = withdrawn[msg.sender];
        AmountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].mul(3).div(100)).div(1 days);
    }

    constructor() public {
        owner = msg.sender;
    }

    function() external payable {
        invest();
    }

    function invest() public payable {
        require(msg.value > 10000000000000000);
        owner.transfer(msg.value.div(5));
        if (deposit[msg.sender] > 0) {
            uint amountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].mul(3).div(100)).div(1 days);
            if (amountToWithdraw != 0) {
                withdrawn[msg.sender] = withdrawn[msg.sender].add(amountToWithdraw);
                msg.sender.transfer(amountToWithdraw);
            }
            lastTimeWithdraw[msg.sender] = block.timestamp;
            deposit[msg.sender] = deposit[msg.sender].add(msg.value);
            return;
        }
        lastTimeWithdraw[msg.sender] = block.timestamp;
        deposit[msg.sender] = (msg.value);
    }

    function withdraw() public {
        uint amountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].mul(3).div(100)).div(1 days);
        if (amountToWithdraw == 0) {
            revert();
        }
        withdrawn[msg.sender] = withdrawn[msg.sender].add(amountToWithdraw);
        lastTimeWithdraw[msg.sender] = block.timestamp.sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days));
        msg.sender.transfer(amountToWithdraw);
    }
}



