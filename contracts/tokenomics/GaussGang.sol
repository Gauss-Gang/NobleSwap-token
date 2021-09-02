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

import "../dependencies/contracts/BEP20.sol";
import "../dependencies/libraries/SafeMath.sol";
import "../dependencies/libraries/Address.sol";
import "../dependencies/interfaces/IBEP20.sol";
// import "./TimeLock/FunctionLockController.sol";



contract GaussGang is BEP20 {
    
    using SafeMath for uint256;
    using Address for address;
    
    
    // TODO: Expand comment
    // Initializes state variables
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _excludedFromFee;
    uint256 private _totalSupply;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _redistributionFee;
    uint256 public _charitableFundFee;
    uint256 public _liquidityFee;
    uint256 public _gangFee;
    uint256 public _totalFee;
    address private _redistributionWallet;
    address private _charitableFundWallet;
    address private _liquidityWallet;
    address private _gangWallet;        // TODO: Change variable name
    
    
    
    // TODO: Create comment
    constructor() {
        _name = "Gauss";
        _symbol = "GANG";
        _decimals = 9;
        _totalSupply = 250000000 * (10 ** _decimals);       // TODO: Double check if correct syntax
        _balances[msg.sender] = _totalSupply;
        _redistributionFee = 3;
        _charitableFundFee = 3;
        _liquidityFee = 3;
        _gangFee = 3;
        _totalFee = 12;
        
        
        // Sets wallet addresses for each of the Pools spliting the Transaction Fee
        _redistributionWallet = (0x9C34db8a1467c0F0F152C13Db098d7e0Ca0CE918);
        _charitableFundWallet = (0x765696087d95A84cbFa6FEEE857570A6eae19A14);
        _liquidityWallet = (0x3f8c6910124F32aa5546a7103408FA995ab45f65);
        _gangWallet = (0x206F10F88159590280D46f607af976F6d4d79Ce3);
    
        
        // TODO: Add more exclusions if needed
        // Excludes the wallets that compose the Transaction Fee from the Fee itself
        _excludedFromFee[owner()] = true;
        _excludedFromFee[_redistributionWallet] = true;
        _excludedFromFee[_charitableFundWallet] = true;
        _excludedFromFee[_liquidityWallet] = true;
        _excludedFromFee[_gangWallet] = true;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
    
    /* Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'
          -At launch, the transaction fee is set to 12%, but will be lowered over time
          -The max transaction fee is also 12%, never raising beyond the intital fee set at launch
          -Fee is evenly split between 4 Pools: 
                    The Redistribution pool,        (Initially, 3%) 
                    the Charitable Fund pool,       (Initially, 3%)
                    the Liquidity pool,             (Initially, 3%)
                    and Gauss Gang pool             (Initially, 3%)
    */
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        
        // Checks to see if "sender" is excluded from the transaction fee, attempts the transaction without fees if found true
        if (_excludedFromFee[msg.sender] == true) {
           
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            
            emit Transfer(sender, recipient, amount);
        }
        
        else {
            
            // This section calculates the number of tokens, for the pools that comprise the transaction fee, that get pulled out of "amount" for the transaction fee
            uint256 redistributionAmount = amount.mul(_redistributionFee) / 100;
            uint256 charitableFundAmount = amount.mul(_charitableFundFee) / 100;
            uint256 liquidityAmount = amount.mul(_liquidityFee) / 100;
            uint256 gangAmount = amount.mul(_gangFee) / 100;
            uint256 finalAmount = amount.sub(redistributionAmount).sub(charitableFundAmount).sub(liquidityAmount).sub(gangAmount);
            
            
            /* This section performs the balance transfer from "sender" to "recipient" 
                    - First ensuring the original "amount" is removed from the "sender" and the "finalAmount" ("amount" - transaction fee)
                        is sent to the "recipient"
                    - After that transaction is complete, the transaction fee is divided up and sent to the respective pool addresses
            */
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

    
    
    // TODO: Considering a TimeLock of 1 or more months
    /* Allows 'owner' to change the transaction fees at a later time, so long as the total Transaction Fee is lower than 12% (the initial fee ceiling)
            -An amount for each Pool is required to be entered, even if the specific fee amount won't be changed         
            -Each variable should be entered as a single or double digit number to represent the intended percentage; example: 
                    entering a 3 for newRedistributionFee would set the Redistribution fee to 3% of the Transaction Amount
    */      
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
    
    
    // Returns the current total Transaction Fee
    function totalTransactionFee() public view returns (uint256) {
        return _totalFee;
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