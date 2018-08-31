// Проблемы критического уровня: 0
// Проблемы среднего уровня: 1
// Оптимизация: 5
// Примечания: 8



// EW Ok:
pragma solidity ^0.4.18;

// EW Ok:
library SafeMath {
    // EW Ok:
    function add(uint a, uint b) internal pure returns (uint c) {
        // EW Ok:
        c = a + b;
        // EW Ok:
        require(c >= a);
    }
    // EW Ok:
    function sub(uint a, uint b) internal pure returns (uint c) {
        // EW Ok:
        require(b <= a);
        // EW Ok:
        c = a - b;
    }

    // EW Ok:
    function mul(uint a, uint b) internal pure returns (uint c) {
        // EW Ok:
        c = a * b;
        // EW Ok:
        require(a == 0 || c / a == b);
    }
    // EW Оптимизация: можно снизить стоимость транзакций преобразовав функцию

    //    function mul(uint a, uint b) internal pure returns (uint c) {
    //        if (a == 0) {
    //            return 0;
    //        }
    //        c = a * b;
    //        require(c / a == b);
    //}


    // EW Ok:
    function div(uint a, uint b) internal pure returns (uint c) {
        // EW Ok:
        require(b > 0);
        // EW Ok:
        c = a / b;
    }
    // EW Примечание: библиотека отличается от стандартной отстутствием функции mod
}

// EW Ok:
contract STokenInterface {
    // EW Ok:
    function totalSupply() public constant returns (uint);
    // EW Ok:
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    // EW Ok:
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    // EW Ok:
    function transfer(address to, uint tokens) public returns (bool success);
    // EW Ok:
    function approve(address spender, uint tokens) public returns (bool success);
    // EW Ok:
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // EW Ok:
    event Transfer(address indexed from, address indexed to, uint tokens);
    // EW Ok:
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// EW Оптимизация: функции и модификаторы данного контракта не используются в последующем, используется только переменная owner в конструкторе токена, где ее можно заменить на msg.sender
contract Owned {
    // EW Ok:
    address public owner;

    // EW Примечание: конструктор можно обозначить как constructor()
    function Owned() public {
        // EW Ok:
        owner = msg.sender;
    }

    // EW Ok:
    modifier onlyOwner {
        // EW Ok:
        require(msg.sender == owner);
        // EW Ok:
        _;
    }

    // EW Ok:
    function transferOwnership(address _newOwner) public onlyOwner {
        // EW Проблема: не хватает проверки на наличие адреса
//        require(_newOwner != address(0));

        // EW Ok:
        owner = _newOwner;
    }
    // EW Оптимизация: из соображений безопасности можно преобразовать функцию следующим образом:
//    function transferOwnership(address _newOwner) public onlyOwner {
//        _transferOwnership(_newOwner);
//    }
//    function _transferOwnership(address _newOwner) internal {
//        require(_newOwner != address(0));
//        owner = _newOwner;
//    }


}

// EW Ok:
contract TST is STokenInterface, Owned {
    // EW Ok:
    using SafeMath for uint;

    // EW Оптимизация: данная переменная не используется
    bool public running = true;
    // EW Ok:
    string public symbol;
    // EW Ok:
    string public name;
    // EW Ok:
    uint8 public decimals;
    // EW Ok:
    uint _totalSupply;

    // EW Ok:
    mapping(address => uint) balances;
    // EW Ok:
    mapping(address => mapping(address => uint)) allowed;


    // EW Примечание: конструктор можно обозначить как constructor()
    function TST() public {
        // EW Ok:
        symbol = "TST";
        // EW Ok:
        name = "TEST";
        // EW Ok:
        decimals = 18;
        // EW Ok:
        _totalSupply = 1000000000 * 10**uint(decimals);
        // EW Примечание: если заменить переменную owner на msg.sender можно убрать весь контракт Owned
        balances[owner] = _totalSupply;
        // EW Примечание: можно использовать маркер emit
        Transfer(address(0), owner, _totalSupply);
    }


    // EW Ok:
    function totalSupply() public constant returns (uint) {
        // EW Оптимизация: по умолчанию вычитание баланса нулевого адреса не требуется.
        return _totalSupply.sub(balances[address(0)]);
    }


    // EW Ok:
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        // EW Ok:
        return balances[tokenOwner];
    }


    // EW Ok:
    function transfer(address to, uint tokens) public returns (bool success) {
        // EW Ok:
        require(tokens <= balances[msg.sender]);
        // EW Ok:
        require(tokens != 0);
        // EW Ok:
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        // EW Ok:
        balances[to] = balances[to].add(tokens);
        // EW Примечание: можно использовать маркер emit
        Transfer(msg.sender, to, tokens);
        // EW Ok:
        return true;
    }


    // EW Ok:
    function approve(address spender, uint tokens) public returns (bool success) {
        // EW Ok:
        allowed[msg.sender][spender] = tokens;
        // EW Примечание: можно использовать маркер emit
        Approval(msg.sender, spender, tokens);
        // EW Ok:
        return true;
    }


    // EW Ok:
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        // EW Ok:
        require(tokens <= balances[from]);
        // EW Ok:
        require(tokens <= allowed[from][msg.sender]);
        // EW Ok:
        require(tokens != 0);
        // EW Ok:
        balances[from] = balances[from].sub(tokens);
        // EW Ok:
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        // EW Ok:
        balances[to] = balances[to].add(tokens);
        // EW Примечание: можно использовать маркер emit
        Transfer(from, to, tokens);
        // EW Ok:
        return true;
    }


    // EW Ok:
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        // EW Ok:
        return allowed[tokenOwner][spender];
    }
}
