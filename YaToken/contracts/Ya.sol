pragma solidity ^0.4.24;
import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract Ya is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 initialSupply = 40000;
    uint256 saleBeginTime = 1539561600;
    uint256 saleEndTime = 1540857600;
    uint256 tokensDestructTime = 1667088000;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private isHolder;
    address[] holders;
    uint256 private _totalSupply;

    event Mint(address indexed to, uint256 amount);
    event TokensDestroyed();

    constructor() {
        _balances[this] = initialSupply;
        _totalSupply = initialSupply;
        isHolder[this] = true;
        holders.push(this);
        //saleBeginTime = block.timestamp + 60;
        //saleEndTime = block.timestamp + 360;
        //tokensDestructTime = block.timestamp + 660;
    }

    /**
		* @dev Total number of tokens in existence
		*/
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
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
        emit Mint(account, amount);
    }

    /**
		 * @dev Internal function that burns all the tokens
		 */
    function destroyTokens() external onlyOwner {
        require(block.timestamp > tokensDestructTime);
        _totalSupply = 0;
        for (uint i = 0; i < holders.length; ++i) {
            _balances[holders[i]] = 0;
        }
        emit TokensDestroyed();
    }

    function destructContract() external onlyOwner {
        selfdestruct(owner());
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(amount <= _balances[from]);
        require(to != address(0));
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        if(!isHolder[to]) {
            isHolder[to] = true;
            holders.push(to);
        }
    }

    //function hasTimeCome() public view returns(bool) {
    //    return (block.timestamp > saleBeginTime);
    //}
//
    //function currentTime() public view returns(uint256) {
    //    return block.timestamp;
    //}

}
