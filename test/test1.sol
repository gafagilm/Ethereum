pragma solidity ^0.4.12;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal returns (uint256) {
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
    function div(uint256 _a, uint256 _b) internal returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]); // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;

    } /** * @dev Gets the balance of the specified address. * @param _owner The address to query the the balance of. * @return An uint256 representing the amount owned by the passed address. */

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}
/** * @title Standard ERC20 token * * @dev Implementation of the basic standard token. * @dev https://github.com/ethereum/EIPs/issues/20 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol */

contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint256)) internal allowed;
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /** * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. * * Beware that changing an allowance with this method brings the risk that someone may use both the old * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards: * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 * @param _spender The address which will spend the funds. * @param _value The amount of tokens to be spent. */
    function approve(address _spender, uint256 _value) public returns (bool) { allowed[msg.sender][_spender] = _value; Approval(msg.sender, _spender, _value); return true; } /** * @dev Function to check the amount of tokens that an owner allowed to a spender. * @param _owner address The address which owns the funds. * @param _spender address The address which will spend the funds. * @return A uint256 specifying the amount of tokens still available for the spender. */ function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];

}

    /** * approve should be called when allowed[_spender] == 0. To increment * allowed value is better to use this function to avoid 2 calls (and wait until * the first transaction is mined) * From MonolithDAO Token.sol */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;

    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function () public payable {
        revert();
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
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
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;

    address public saleAgent;

    function setSaleAgent(address newSaleAgnet) public {
        require(msg.sender == saleAgent || msg.sender == owner);
        saleAgent = newSaleAgnet;
    }

    function mint(address _to, uint256 _amount) public returns (bool) {
        require(msg.sender == saleAgent && !mintingFinished);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() public returns (bool) {
        require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function burn(uint _value) public {
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }


    event Burn(address indexed burner, uint indexed value);


}

contract SimpleTokenCoin is MintableToken {

    string public constant name = "Simple Coin Token";

    string public constant symbol = "SCT";

    uint32 public constant decimals = 18;

    uint256 public INITIAL_SUPPLY = 1000000 * 1 ether;

    function SimpleTokenCoin() {
        totalSupply = INITIAL_SUPPLY;
    }

    function transferTotalSupplyToSaleAgent() onlyOwner {
        balances[saleAgent] = totalSupply;
    }



}

contract Crowdsale is Ownable {

    using SafeMath for uint;

    address multisig;

    uint restrictedPercent;

    address restricted;

    SimpleTokenCoin token;

    uint start;

    uint period;

    uint hardcap;

    uint rate;


    function Crowdsale(address tokenAddress) {
        multisig = 0x583031d1113ad414f02576bd6afabfb302140225;
        restricted = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
        restrictedPercent = 40;
        rate = 100000000000000000000;
        start = 1533924000;
        period = 28;
        hardcap = 10000000000000000000000;
        token = SimpleTokenCoin(tokenAddress);
    }


    modifier saleIsOn() {
        require(now > start && now < start + period * 24 * 60 * 60);
        _;
    }

    modifier isUnderHardCap() {
        require(multisig.balance <= hardcap);
        _;
    }

    function finishMinting() public onlyOwner {
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
        token.mint(restricted, restrictedTokens);
        token.finishMinting();
    }

    function createTokens() isUnderHardCap saleIsOn payable {
        multisig.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if(now < start + (period * 1 days).div(4)) {
            bonusTokens = tokens.div(4);
        } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
            bonusTokens = tokens.div(10);
        } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
            bonusTokens = tokens.div(20);
        }
        tokens += bonusTokens;
        token.transfer(msg.sender, tokens);
    }

    function() external payable {
        createTokens();
    }



}
