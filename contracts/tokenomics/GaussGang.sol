/*  _____________________________________________________________________________

    Gauss(Gang) Contract

    Deployed to      : TODO
    Name             : Gauss
    Symbol           : GANG
    Total supply     : 250000000
    Transaction Fee  : 12%

    MIT Licence. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "../dependencies/contracts/Context.sol";
import "../dependencies/contracts/Ownable.sol";
import "../dependencies/contracts/BEP20.sol";
import "../dependencies/libraries/SafeMath.sol";
import "../dependencies/libraries/Address.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapRouter01.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapRouter02.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapPair.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapFactory.sol";



contract Gauss is BEP20 {
    
    using SafeMath for uint256;
    using Address for address;

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
    address private _gangWallet;
    
    address public pancakeswapPair;
    IPancakeSwapRouter02 public pancakeswapRouter;


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
    
    
    
    /* Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'
          -Currently set to a 12% transaction fee, but will be lowered over time
          -Fee is evenly split between 4 Pools: 
                    The Redistribution pool,        (Currently, 3%) 
                    the Charitable Fund pool,       (Currently, 3%)
                    the Liquidity pool,             (Currently, 3%)
                    and Gauss Gang pool             (Currently, 3%)                             */
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        
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
    
    
    
    // TODO: Considering a TimeLock of 1 or more months
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
    
    
    // TODO: TimeLock the function, 6-12 months
    // Allows 'owner' to change the Pancakeswap Router Address, should a new version become available in the future
    function setRouterAddress(address newRouter) public onlyOwner() {
        IPancakeSwapRouter02 newPancakeswapRouter = IPancakeSwapRouter02(newRouter);
        pancakeswapPair = IPancakeSwapFactory(newPancakeswapRouter.factory()).createPair(address(this),newPancakeswapRouter.WBNB());
        pancakeswapRouter = newPancakeswapRouter;
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