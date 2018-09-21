pragma solidity ^0.4.24;
import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract Ya is ERC20, Ownable {
    using SafeMath for uint256;

    string name = "Lawtest Token #1";
    string symbol ="LT1";
    uint256 decimals = 0;

    uint256 initialSupply = 40000;
    uint256 saleBeginTime = 1539561600;
    uint256 saleEndTime = 1540857600;
    uint256 tokensDestructTime = 1667088000;
    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;
    uint256 private _amountForSale;

    event Mint(address indexed to, uint256 amount, uint256 amountForSale);
    event TokensDestroyed();

    constructor() {
        _balances[this] = initialSupply;
        _amountForSale = initialSupply;
        _totalSupply = initialSupply;
        saleBeginTime = block.timestamp + 60;
        saleEndTime = block.timestamp + 360;
        tokensDestructTime = block.timestamp + 660;
    }

    /**
		* @dev Total number of tokens in existence
		*/
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function amountForSale() public view returns (uint256) {
        return _amountForSale;
    }

    /**
		* @dev Gets the balance of the specified address.
		* @param owner The address to query the balance of.
		* @return An uint256 representing the amount owned by the passed address.
		*/
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
		* @dev Transfer token for a specified address
		* @param to The address to transfer to.
		* @param amount The amount to be transferred.
		*/
    function transfer(address to, uint256 amount) external returns (bool) {
        require(block.timestamp < tokensDestructTime);
        _transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
		 * @dev External function that mints an amount of the token and assigns it to
		 * an account. This encapsulates the modification of balances such that the
		 * proper events are emitted.
		 * @param account The account that will receive the created tokens.
		 * @param amount The amount that will be created.
		 */
    function mint(address account, uint256 amount) external onlyOwner {
        require(saleBeginTime < block.timestamp);
        require(saleEndTime > block.timestamp);
        _transfer(this,  account, amount);
        emit Mint(account, amount, _amountForSale);
    }

    /**
        *@dev This sends all the funds to owner's address and destroys the contract.
    **/

    function destructContract() external onlyOwner {
        selfdestruct(owner());
    }

    /**
        * @dev Internal function that transfers an amount of the token
        * from `from` to `to`
        * This encapsulates the modification of balances such that the
        * proper events are emitted.
        * @param from The account tokens are transferred from.
        * @param to The account tokens are transferred to.
        * @param amount The amount that will be created.
    */
    function _transfer(address from, address to, uint256 amount) internal {
        require(amount <= _balances[from]);
        require(to != address(0));
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        if(saleEndTime > block.timestamp)
            _amountForSale = _balances[this];
    }

    function hasSaleBeginTimeCome() public view returns(bool) {
        return (block.timestamp > saleBeginTime);
    }

    function hasSaleEndTimeCome() public view returns(bool) {
        return (block.timestamp > saleEndTime);
    }

    function hasTokensDestructTimeCome() public view returns(bool) {
        return (block.timestamp > tokensDestructTime);
    }

}

