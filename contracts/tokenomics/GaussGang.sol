/*  _____________________________________________________________________________

    Gauss(Gang) Contract

    Deployed to      : TODO
    Name             : Gauss
    Symbol           : GANG
    Total supply     : 250,000,000 (250 Million)
    Transaction Fee  : 12%

    MIT License. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "../dependencies/contracts/Context.sol";
import "../dependencies/contracts/Ownable.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/libraries/Address.sol";
// import "./TimeLock/FunctionLockController.sol";



// TODO: Create Comment
contract GaussGang is Context, IBEP20, Ownable {
    
    // Dev-Note: Solidity 0.8.0 has added built-in support for checked math, therefore the "SafeMath" library is no longer needed.
    using Address for address;
    
    // TODO: Reword
    // Creates mapping for the collections of balances, allowances, and addresses excluded from the Transaction Fee for the Gauss(GANG) token
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;
    
    // Initializes variables for the total Supply, name, symbol, and decimals of Gauss(GANG) token.
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8  private _decimals;
    
    // TODO: Consider making private
    // Initializes variables representing the seperate fees that comprise the Transaction Fee.
    uint256 public _redistributionFee;
    uint256 public _charitableFundFee;
    uint256 public _liquidityFee;
    uint256 public _ggFee;
    uint256 private _totalFee;
    
    // TODO: Consider making private
    // Initializes variables representing the seperate wwallets that receive the Transaction Fee.
    address public _redistributionWallet;
    address public _charitableFundWallet;
    address public _liquidityWallet;
    address public _ggWallet;
    
    
    
    // TODO: Expand and reword
    // The constructor sets the state variables, listed above, to their initial states at launch.
    constructor() {
        _name = "Gauss";
        _symbol = "GANG";
        _decimals = 9;
        _totalSupply = 250000000 * (10 ** _decimals);
        _balances[msg.sender] = _totalSupply;
        _redistributionFee = 3;
        _charitableFundFee = 3;
        _liquidityFee = 3;
        _ggFee = 3;
        _totalFee = 12;
        
        // Sets wallet addresses for each of the Pools spliting the Transaction Fee.
        _redistributionWallet = (0x9C34db8a1467c0F0F152C13Db098d7e0Ca0CE918);
        _charitableFundWallet = (0x765696087d95A84cbFa6FEEE857570A6eae19A14);
        _liquidityWallet = (0x3f8c6910124F32aa5546a7103408FA995ab45f65);
        _ggWallet = (0x206F10F88159590280D46f607af976F6d4d79Ce3);
        
        // TODO: Add more exclusions if needed; Possibly reword comment
        // Excludes the wallets that compose the Transaction Fee from the Fee itself.
        _excludedFromFee[owner()] = true;
        _excludedFromFee[_redistributionWallet] = true;
        _excludedFromFee[_charitableFundWallet] = true;
        _excludedFromFee[_liquidityWallet] = true;
        _excludedFromFee[_ggWallet] = true;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
    // Returns the token name.
    function name() public override view returns (string memory) {
        return _name;
    }
    
    
    // Returns the token symbol.
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

 
    // Returns the token decimals.
    function decimals() public override view returns (uint8) {
        return _decimals;
    }


    // Returns the total supply of token.
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    
    
    // Returns the token owner.
    function getOwner() external override view returns (address) {
        return owner();
    }
    
    
    // Returns balance of the referenced 'account' address.
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }


    // Returns the remaining tokens that the 'spender' address can spend on behalf of the 'owner' address through the {transferFrom} function.
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    
    // Atomically increases the allowance granted to `spender` by the caller.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));
        return true;
    }
    
    
    // Atomically decreases the allowance granted to `spender` by the caller.
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require((_allowances[_msgSender()][spender] - subtractedValue) >= 0, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));
        return true;
    }


    // Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    
    // Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    /*  Transfers an 'amount' of tokens from the callers account to the referenced 'recipient' address. Emits a {Transfer} event.
            - NOTE: This calls the internal function {_transfer}, which may subtract a Transaction Fee from "amount".
    */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    /*  Transfers an 'amount' of tokens from the 'sender' address to the 'recipient' address. Emits a {Transfer} event.
            - NOTE: This calls the internal function {_transfer}, which may subtract a Transaction Fee from "amount".
    */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        
        require(amount <= _allowances[sender][_msgSender()], "BEP20: transfer amount exceeds allowance");
        
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));
        return true;
    }
    
    
    // Returns the current total Transaction Fee.
    function totalTransactionFee() public view returns (uint256) {
        return _totalFee;
    }
    

    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the Redistribution Wallet.
    function changeRedistributionWallet(address newRedistributionAddress) public onlyOwner() {
        _redistributionWallet = newRedistributionAddress;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the charitable Fund Wallet.
    function changeCharitableWallet(address newCharitableAddress) public onlyOwner() {
        _charitableFundWallet = newCharitableAddress;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the Liquidity Pool Wallet.
    function changeLiquidityWallet(address newLiquidityAddress) public onlyOwner() {
        _liquidityWallet = newLiquidityAddress;
    }
    
    
    // TODO: TimeLock the function, 4 - 6 months
    // Allows 'owner' to change the wallet address for the Liquidity Pool Wallet.
    function changeGaussGangWallet(address newGaussGangAddress) public onlyOwner() {
        _ggWallet = newGaussGangAddress;
    }
    
    
    // TODO: Considering a TimeLock of 1 or more months
    /*  Allows 'owner' to change the transaction fees at a later time, so long as the total Transaction Fee is lower than 12% (the initial fee ceiling).
            -An amount for each Pool is required to be entered, even if the specific fee amount won't be changed.         
            -Each variable should be entered as a single or double digit number to represent the intended percentage; 
                Example: Entering a 3 for newRedistributionFee would set the Redistribution fee to 3% of the Transaction Amount.
    */      
    function changeTransactionFees(uint256 newRedistributionFee, uint256 newCharitableFundFee, uint256 newLiquidityFee, uint256 newGGFee) public onlyOwner() {
        uint256 newTotalFee;
        
        newTotalFee = newRedistributionFee + newCharitableFundFee + newLiquidityFee + newGGFee;

        if (newTotalFee <= 12) {
            _redistributionFee = newRedistributionFee;
            _charitableFundFee = newCharitableFundFee;
            _liquidityFee = newLiquidityFee;
            _ggFee = newGGFee;
            _totalFee = newTotalFee;
        }
    }
    
    
    /*  Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'.
            -At launch, the transaction fee is set to 12%, but will be lowered over time.
            -The max transaction fee is also 12%, never raising beyond the intital fee set at launch.
            -Fee is evenly split between 4 Pools: 
                    The Redistribution pool,        (Initially, 3%) 
                    the Charitable Fund pool,       (Initially, 3%)
                    the Liquidity pool,             (Initially, 3%)
                    and Gauss Gang pool             (Initially, 3%)
    */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        // Checks to see if "sender" is excluded from the transaction fee, attempts the transaction without fees if found true.
        if (_excludedFromFee[msg.sender] == true) {
            
            require(amount <= _balances[sender], "BEP20: transfer amount exceeds balance");
            
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + amount;
            
            emit Transfer(sender, recipient, amount);
        }
        
        else {
            
            // This section calculates the number of tokens, for the pools that comprise the transaction fee, that get pulled out of "amount" for the transaction fee.
            uint256 redistributionAmount = (amount * _redistributionFee) / 100;
            uint256 charitableFundAmount = (amount * _charitableFundFee) / 100;
            uint256 liquidityAmount = (amount * _liquidityFee) / 100;
            uint256 ggAmount = (amount * _ggFee) / 100;
            uint256 finalAmount = amount - (redistributionAmount + charitableFundAmount + liquidityAmount + ggAmount);
            
            /*  This section performs the balance transfer from "sender" to "recipient".
                    - First ensuring the original "amount" is removed from the "sender" and the "finalAmount" ("amount" - transaction fee)
                        is sent to the "recipient".
                    - After that transaction is complete, the transaction fee is divided up and sent to the respective pool addresses.
            */
            require(finalAmount <= _balances[sender], "BEP20: transfer amount exceeds balance");
            
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] = _balances[recipient] + finalAmount;
            _balances[_redistributionWallet] = _balances[_redistributionWallet] + redistributionAmount;
            _balances[_charitableFundWallet] = _balances[_charitableFundWallet] + charitableFundAmount;
            _balances[_liquidityWallet] = _balances[_liquidityWallet] + liquidityAmount;
            _balances[_ggWallet] = _balances[_ggWallet] + ggAmount;
            
            emit Transfer(sender, recipient, finalAmount);
            emit Transfer(sender, _redistributionWallet, redistributionAmount);
            emit Transfer(sender, _charitableFundWallet, charitableFundAmount);
            emit Transfer(sender, _liquidityWallet, liquidityAmount);
            emit Transfer(sender, _ggWallet, ggAmount);
        }
    }
}