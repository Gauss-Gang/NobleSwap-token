/*  _____________________________________________________________________________

    Gauss (Gang) Contract

    Deployed to      : TODO
    Name             : Gauss
    Symbol           : GANG
    Total supply     : 250000000
    Transaction Fee  : 12%

    (c) TODO. MIT Licence.
    
    _____________________________________________________________________________
*/

pragma solidity >=0.8.4 <0.9.0;

// SPDX-License-Identifier: GPL-3.0-or-later



// Provides information about the current execution context, including the sender of the transaction and its data.
contract Context {
    
    
    // Empty internal constructor, to prevent people from mistakenly deploying an instance of this contract, which should be used via inheritance.
    constructor () { }


    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    
    
    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



// Provides a basic access control mechanism, where an account '_owner' can be granted exclusive access to specific functions by using the modifier `onlyOwner`
contract Ownable is Context {
    
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    // Initializes the contract, setting the deployer as the initial owner.
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    

    // Returns the address of the current owner.
    function owner() public view returns (address) {
        return _owner;
    }

    
    // Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    // Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    // Internal function, transfers ownership of the contract to a new account (`newOwner`).
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



// library that creates wrappers over Solidity's arithmetic operations with added overflow protection
library SafeMath {
 
 
    // Returns the addition of two unsigned integers, reverting on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }


    // Returns the subtraction of two unsigned integers, reverting on overflow (when the result is negative).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    

    // Returns the subtraction of two unsigned integers, reverting with custom message on overflow (when the result is negative).  
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    
    
    // Returns the multiplication of two unsigned integers, reverting on overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    

    // Returns the integer division of two unsigned integers. Reverts on division by zero. The result is rounded towards zero.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    // Returns the integer division of two unsigned integers. Reverts with custom message on division by zero. The result is rounded towards zero.
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    

    // Returns the remainder of dividing two unsigned integers. (unsigned integer modulo), Reverts when dividing by zero.
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    // Returns the remainder of dividing two unsigned integers. (unsigned integer modulo), Reverts with custom message when dividing by zero.
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



// BEP20 Interface that creates basic functions for a BEP20 token. The Gauss Contract inherits it's core functions from this interface.
interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    
    
    // Returns balance of the referenced 'account' address
    function balanceOf(address account) external view returns (uint256);


    // Transfers an 'amount' of tokens from callers account to the referenced 'recipient' address. Emits a {Transfer} event. 
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    
    // Transfers an 'amount' of tokens from the 'sender' address to the 'recipient' address. Emits a {Transfer} event.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    /* Returns the remaining tokens that the 'spender' address can spend on behalf of the 'owner' address through the {transferFrom} function.
        -TODO: Consider use of aforementioned solution ->
        IMPORTANT: Beware that changing an allowance with this method brings the risk
        that someone may use both the old and the new allowance by unfortunate
        transaction ordering. One possible solution to mitigate this race
        condition is to first reduce the spender's allowance to 0 and set the
        desired value afterwards:
        https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729  */
    function allowance(address _owner, address spender) external view returns (uint256);
   
    
    /* Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
        -TODO: Consider use of the aforementioned solution ->
        IMPORTANT: Beware that changing an allowance with this method brings the risk
        that someone may use both the old and the new allowance by unfortunate
        transaction ordering. One possible solution to mitigate this race
        condition is to first reduce the spender's allowance to 0 and set the
        desired value afterwards:
        https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729  */
    function approve(address spender, uint256 amount) external returns (bool);

  
    // Emitted when `value` tokens are moved from one account address (`from`) to another (`to`). Note that `value` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);


    // Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



// Factory Method used to create a token pair on the Pancakeswap Exchange
interface IPancakeswapV2Factory {
    
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}



// TODO: Write comment for Interface
interface IPancakeswapV2Pair {
    
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}



// TODO: Write comment for Interface
interface IPancakeswapV2Router01 {
    
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    
    
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    
    
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    
    
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
    
    
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    
    
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
    
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    
    
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    
    
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}



// TODO: Write comment for Interface
interface IPancakeswapV2Router02 is IPancakeswapV2Router01 {
    
    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    
    
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    
    
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



contract Gauss is Context, IBEP20, Ownable {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;
    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    uint256 public _redistributionFee;
    uint256 public _charitableFundFee;
    uint256 public _liquidityFee;
    uint256 public _gangFee;
    uint256 public _totalFee;
    address private _redistributionWallet;
    address private _charitableFundWallet;
    address private _liquidityWallet;
    address private _gangWallet;
    
    address public pancakeswapV2Pair;
    IPancakeswapV2Router02 public pancakeswapV2Router;


    constructor() {
        _name = "Gauss";
        _symbol = "GANG";
        _decimals = 9;
        _totalSupply = 250000000 * (10 ** _decimals);
        _balances[msg.sender] = _totalSupply;
        _redistributionFee = 3;
        _charitableFundFee = 3;
        _liquidityFee = 3;
        _gangFee = 3;
        _totalFee = 12;
        
        // TODO: Add actual wallet addresses to initialized wallet variables
        // Sets Pancakeswap Router Address, as well as wallet addresses for each of the Pools spliting the Transaction Fee
        setRouterAddress(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //  _redistributionWallet = (Address);
    //  _charitableFundWallet = (Address);
    //  _liquidityWallet = (Address);
    //  _gangWallet = (Address);
    
        
        // TODO: Add more exclusions if needed
        // Excludes the wallets that compose the Transaction Fee from the Fee itself
        _excludedFromFee[owner()] = true;
        _excludedFromFee[_redistributionWallet] = true;
        _excludedFromFee[_charitableFundWallet] = true;
        _excludedFromFee[_liquidityWallet] = true;
        _excludedFromFee[_gangWallet] = true;


        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
    
    // The next block of of code, from line 518-591, contains Inherited Functions from the BEP20 Interface
    // (Explanations and comments for each can be found above, beginning at line 160)
    function getOwner() external override view returns (address) {
        return owner();
    }
    
    
    function decimals() public override view returns (uint8) {
        return _decimals;
    }
    
    
    function symbol() public override view returns (string memory) {
        return _symbol;
    }
    
    
    function name() public override view returns (string memory) {
        return _name;
    }
    
    
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    
    
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }
    
    
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue)); 
        return true;
    }
    
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount); return true;
    }
    
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount); 
        return true;
    }
    
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")); 
        return true;
    }
    
    
    // TODO: May or may not remove, left as template for now
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount); 
        return true;
    }
    
    
    // TODO: May or may not remove, left as template for now
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address"); 
        
        _totalSupply = _totalSupply.add(amount);_balances[account] = _balances[account].add(amount); 
        emit Transfer(address(0), account, amount);
    }
    

    // TODO: May or may not remove, left as template for now
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    // TODO: May or may not remove, left as template for now
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }
    
    

    /* Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'
          -Currently set to a 12% transaction fee, but will be lowered over time
          -Fee is evenly split between 4 Pools: 
                    The Redistribution pool,        (Currently, 3%) 
                    the Charitable Fund pool,       (Currently, 3%)
                    the Liquidity pool,             (Currently, 3%)
                    and Gauss Gang pool             (Currently, 3%)                             */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        
        if (_excludedFromFee[msg.sender] == true) {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        
        
        else {
            uint256 redistributionAmount = amount.mul(_redistributionFee) / 100;
            uint256 charitableFundAmount = amount.mul(_charitableFundFee) / 100;
            uint256 liquidityAmount = amount.mul(_liquidityFee) / 100;
            uint256 gangAmount = amount.mul(_gangFee) / 100;
            uint256 finalAmount = amount.sub(redistributionAmount).sub(charitableFundAmount).sub(liquidityAmount).sub(gangAmount);
            
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(finalAmount);
            _balances[_redistributionWallet] = _balances[_redistributionWallet].add(redistributionAmount);
            _balances[_charitableFundWallet] = _balances[_charitableFundWallet].add(charitableFundAmount);
            _balances[_liquidityWallet] = _balances[_liquidityWallet].add(liquidityAmount);
            _balances[_gangWallet] = _balances[_gangWallet].add(gangAmount);
            
            emit Transfer(sender, recipient, finalAmount);
            emit Transfer(sender, _redistributionWallet, redistributionAmount);
            emit Transfer(sender, _charitableFundWallet, charitableFundAmount);
            emit Transfer(sender, _liquidityWallet, liquidityAmount);
            emit Transfer(sender, _gangWallet, gangAmount);
        }
    }
    
    
    // Returns the current total Transaction Fee
    function totalTransactionFee() public view returns (uint256) {
        return _totalFee;
    }
    
    
    // TODO: Considering a TimeLock of 1 month
    /* Allows 'owner' to change the transaction fees at a later time, so long as the total Transaction Fee is lower than 12% (the initial fee ceiling)
            -An amount for each Pool is required to be entered, even if the specific fee amount won't be changed         
            -Each variable should be entered as a single or double digit number to represent the intended percentage; i.e.: 
                    entering a 3 for newRedistributionFee would set the Redistribution fee to 3% of the Transaction Amount                          */      
    function changeTransactionFees(uint256 newRedistributionFee, uint256 newCharitableFundFee, uint256 newLiquidityFee, uint256 newGangFee) public onlyOwner() {
        
        uint256 newTotalFee = newRedistributionFee.add(newCharitableFundFee).add(newLiquidityFee).add(newGangFee);
        
    
        if (newTotalFee < 12) {
            _redistributionFee = newRedistributionFee;
            _charitableFundFee = newCharitableFundFee;
            _liquidityFee = newLiquidityFee;
            _gangFee = newGangFee;
            _totalFee = newTotalFee;
        }
    }
    

    // Allows 'owner' to change the Pancakeswap Router Address, should a new version become available in the future
    function setRouterAddress(address newRouter) public onlyOwner() {
        
        IPancakeswapV2Router02 _newPancakeswapRouter = IPancakeswapV2Router02(newRouter);
        pancakeswapV2Pair = IPancakeswapV2Factory(_newPancakeswapRouter.factory()).createPair(address(this),_newPancakeswapRouter.WBNB());
        pancakeswapV2Router = _newPancakeswapRouter;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the Redistribution Wallet
    function changeRedistributionWallet(address newRedistributionAddress) public onlyOwner() {
        _redistributionWallet = newRedistributionAddress;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the charitable Fund Wallet
    function changeCharitableWallet(address newCharitableAddress) public onlyOwner() {
        _charitableFundWallet = newCharitableAddress;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the Liquidity Pool Wallet
    function changeLiquidityWallet(address newLiquidityAddress) public onlyOwner() {
        _liquidityWallet = newLiquidityAddress;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the Liquidity Pool Wallet
    function changeGaussGangWallet(address newGaussGangAddress) public onlyOwner() {
        _gangWallet = newGaussGangAddress;
    }
}