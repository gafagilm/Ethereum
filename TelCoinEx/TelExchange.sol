pragma solidity 0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

contract Telcoin {
    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    string public constant name = "Telcoin";
    string public constant symbol = "TEL";
    uint8 public constant decimals = 2;

    /// The ERC20 total fixed supply of tokens.
    uint256 public constant totalSupply = 100000000000 * (10 ** uint256(decimals));

    /// Account balances.
    mapping(address => uint256) balances;

    /// The transfer allowances.
    mapping (address => mapping (address => uint256)) internal allowed;

    /// The initial distributor is responsible for allocating the supply
    /// into the various pools described in the whitepaper. This can be
    /// verified later from the event log.
    function Telcoin(address _distributor) public {
        balances[_distributor] = totalSupply;
        Transfer(0x0, _distributor, totalSupply);
    }

    /// ERC20 balanceOf().
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /// ERC20 transfer().
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// ERC20 transferFrom().
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

    /// ERC20 approve(). Comes with the standard caveat that an approval
    /// meant to limit spending may actually allow more to be spent due to
    /// unfortunate ordering of transactions. For safety, this method
    /// should only be called if the current allowance is 0. Alternatively,
    /// non-ERC20 increaseApproval() and decreaseApproval() can be used.
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// ERC20 allowance().
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /// Not officially ERC20. Allows an allowance to be increased safely.
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /// Not officially ERC20. Allows an allowance to be decreased safely.
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library NewSafeMath {

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

/**
 * @title TelExchange
 * @dev The main contract of the project.
 */
  /**
    * @title TelExchange
    * @dev Контракт проекта;
    */
contract TelExchange {
    // Connecting SafeMath for safe calculations.
      // Подключает библиотеку безопасных вычислений к контракту.
    using NewSafeMath for uint;

    // A variable for address of the owner;
      // Переменная для хранения адреса владельца контракта;
    address owner;

    // A variable for address of the ERC20 token;
      // Переменная для хранения адреса токена ERC20;
    Telcoin public token = Telcoin(0x85e076361cc813A908Ff672F9BAd1541474402b2);

    // A variable for decimals of the token;
      // Переменная для количества знаков после запятой у токена;
    uint private decimals = 2;

    // A variable for storing deposits of investors.
      // Переменная для хранения записей о сумме инвестиций инвесторов.
    mapping (address => uint) deposit;

    // A variable for storing amount of withdrawn money of investors.
      // Переменная для хранения записей о сумме снятых средств.
    mapping (address => uint) withdrawn;
    
    // A variable for storing reference point to count available money to withdraw.
      // Переменная для хранения времени отчета для инвесторов.
    mapping (address => uint) lastTimeWithdraw;

    // A constructor function for the contract. It used single time as contract is deployed.
      // Единоразовая функция вызываемая при деплое контракта.
    function TelExchange() public {
        // Sets an owner for the contract;
          // Устанавливает владельца контракта;
        owner = msg.sender;
    }

    // A function for transferring ownership of the contract (available only for the owner).
      // Функция для переноса права владения контракта (доступна только для владельца).
    function transferOwnership(address _newOwner) external {
        require(msg.sender == owner);
        require(_newOwner != address(0));
        owner = _newOwner;
    }

    // A function for getting key info for investors.
      // Функция для вызова ключевой информации для инвестора.
    function getInfo(address _address) public view returns(uint Deposit, uint Withdrawn, uint AmountToWithdraw) {

        // 1) Amount of invested tokens;
          // 1) Сумма вложенных токенов;
        Deposit = deposit[_address].div(10**decimals);
        // 2) Amount of withdrawn tokens;
          // 3) Сумма снятых средств;
        Withdrawn = withdrawn[_address].div(10**decimals);
        // 3) Amount of tokens which is available to withdraw;
        // Formula without SafeMath: ((Current Time - Reference Point) - ((Current Time - Reference Point) % 1 period)) * (Deposit / 30) / decimals / 1 period
          // 4) Сумма токенов доступных к выводу;
          // Формула без библиотеки безопасных вычислений: ((Текущее время - Отчетное время) - ((Текущее время - Отчетное время) % 1 period)) * (Сумма депозита / 30) / decimals / 1 period
        AmountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[_address]).sub((block.timestamp.sub(lastTimeWithdraw[_address])).mod(1 days))).mul(deposit[_address].div(30)).div(10**decimals).div(1 days);
    }

    // A "fallback" function. It is automatically being called when anybody sends ETH to the contract. Even if the amount of ETH is ecual to 0;
      // Функция автоматически вызываемая при получении ETH контрактом (даже если было отправлено 0 эфиров);
    function() external payable {

        // If investor accidentally sent ETH then function send it back;
          // Если инвестором был отправлен ETH то средства возвращаются отправителю;
        msg.sender.transfer(msg.value);
        // If the value of sent ETH is equal to 0 then function executes special algorithm:
        // 1) Gets amount of intended deposit (approved tokens).
        // 2) If there are no approved tokens then function "withdraw" is called for investors;
          // Если было отправлено 0 эфиров то исполняется следующий алгоритм:
          // 1) Заправшивается количество токенов для инвестирования (кол-во одобренных к выводу токенов).
          // 2) Если одобрены токенов нет, для действующих инвесторов вызывается функция инвестирования (после этого действие функции прекращается);
        uint _approvedTokens = token.allowance(msg.sender, address(this));
        if (_approvedTokens == 0 && deposit[msg.sender] > 0) {
            withdraw();
            return;
        // If there are some approved tokens to invest then function "invest" is called;
          // Если были одобрены токены то вызывается функция инвестирования (после этого действие функции прекращается);
        } else {
            invest();
            return;
        }
    }

    // A function which accepts tokens of investors.
      // Функция для перевода токенов на контракт.
    function invest() public {

        // Gets amount of deposit (approved tokens);
          // Заправшивает количество токенов для инвестирования (кол-во одобренных к выводу токенов);
        uint _value = token.allowance(msg.sender, address(this));
        // Transfers approved ERC20 tokens from investors address;
          // Переводит одобренные к выводу токены ERC20 на данный контракт;
        token.transferFrom(msg.sender, address(this), _value);
        // Transfers a fee to the owner of the contract. The fee is 5% of the deposit (or Deposit / 20)
          // Переводит комиссию владельцу (5%);
        token.transfer(owner, _value.div(20));

        // The special algorithm for investors who increases their deposits:
          // Специальный алгоритм для инвесторов увеличивающих их вклад;
        if (deposit[msg.sender] > 0) {
            // Amount of tokens which is available to withdraw;
            // Formula without SafeMath: ((Current Time - Reference Point) - ((Current Time - Reference Point) % 1 period)) * (Deposit / 30) / 1 period
              // Расчет количества токенов доступных к выводу;
              // Формула без библиотеки безопасных вычислений: ((Текущее время - Отчетное время) - ((Текущее время - Отчетное время) % 1 period)) * (Сумма депозита / 30) / 1 period
            uint amountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].div(30)).div(1 days);
            // The additional algorithm for investors who need to withdraw available dividends:
              // Дополнительный алгоритм для инвесторов которые имеют средства к снятию;
            if (amountToWithdraw != 0) {
                // Increasing the withdrawn tokens by the investor.
                  // Увеличение количества выведенных средств инвестором;
                withdrawn[msg.sender] = withdrawn[msg.sender].add(amountToWithdraw);
                // Transferring available dividends to the investor.
                  // Перевод доступных к выводу средств на кошелек инвестора;
                token.transfer(msg.sender, amountToWithdraw);
            }
            // Setting the reference point to the current time.
              // Установка нового отчетного времени для инвестора;
            lastTimeWithdraw[msg.sender] = block.timestamp;
            // Increasing of the deposit of the investor.
              // Увеличение Суммы депозита инвестора;
            deposit[msg.sender] = deposit[msg.sender].add(_value);
            // End of the function for investors who increases their deposits.
              // Конец функции для инвесторов увеличивающих свои депозиты;
            return;
        }
        // The algorithm for new investors:
        // Setting the reference point to the current time.
          // Алгоритм для новых инвесторов:
          // Установка нового отчетного времени для инвестора;
        lastTimeWithdraw[msg.sender] = block.timestamp;
        // Storing the amount of the deposit for new investors.
        // Установка суммы внесенного депозита;
        deposit[msg.sender] = (_value);
    }

    // A function for getting available dividends of the investor.
      // Функция для вывода средств доступных к снятию;
    function withdraw() public {

        // Amount of tokens which is available to withdraw.
        // Formula without SafeMath: ((Current Time - Reference Point) - ((Current Time - Reference Point) % 1 period)) * (Deposit / 30) / 1 period
          // Расчет количества токенов доступных к выводу;
          // Формула без библиотеки безопасных вычислений: ((Текущее время - Отчетное время) - ((Текущее время - Отчетное время) % 1 period)) * (Сумма депозита / 30) / 1 period
        uint amountToWithdraw = (block.timestamp.sub(lastTimeWithdraw[msg.sender]).sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days))).mul(deposit[msg.sender].div(30)).div(1 days);
        // Reverting the whole function for investors who got nothing to withdraw yet.
          // В случае если к выводу нет средств то функция отменяется;
        if (amountToWithdraw == 0) {
            revert();
        }
        // Increasing the withdrawn tokens by the investor.
          // Увеличение количества выведенных средств инвестором;
        withdrawn[msg.sender] = withdrawn[msg.sender].add(amountToWithdraw);
        // Updating the reference point.
        // Formula without SafeMath: Current Time - ((Current Time - Previous Reference Point) % 1 period)
          // Обновление отчетного времени инвестора;
          // Формула без библиотеки безопасных вычислений: Текущее время - ((Текущее время - Предыдущее отчетное время) % 1 period)
        lastTimeWithdraw[msg.sender] = block.timestamp.sub((block.timestamp.sub(lastTimeWithdraw[msg.sender])).mod(1 days));
        // Transferring the available dividends to the investor.
          // Перевод выведенных средств;
        token.transfer(msg.sender, amountToWithdraw);
    }
}
