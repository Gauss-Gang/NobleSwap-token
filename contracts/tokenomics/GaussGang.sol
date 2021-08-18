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
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapRouter01.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapRouter02.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapPair.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapFactory.sol";
import "./TimeLock/TokenLock.sol";
import "./TimeLock/CommunityTokenLock.sol";
import "./TimeLock/LiquidityTokenLock.sol";
import "./TimeLock/CharitableFundTokenLock.sol";
import "./TimeLock/AdvisorTokenLock.sol";
import "./TimeLock/CoreTeamTokenLock.sol";
// import "./TimeLock/FunctionLockController.sol";



contract GaussGang is BEP20 {
    
    using SafeMath for uint256;
    using Address for address;
    
    
    // TODO: Create comment
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

    
    // TODO: Create comment
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
        
        
        // Vests the Community, Liquidity, Company, Core Team, and Advisor wallets. Vesting schedule is explained in detail in each TimeLock Contract
        _initializeTokenDistribution();


        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
    
    /* Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'
          -Currently set to a 12% transaction fee, but will be lowered over time
          -The max transaction fee is set to a ceiling of 12%
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
    
    
    // Returns the current total Transaction Fee
    function totalTransactionFee() public view returns (uint256) {
        return _totalFee;
    }
    
    
    
    // TODO: Considering a TimeLock of 1 or more months
    /* Allows 'owner' to change the transaction fees at a later time, so long as the total Transaction Fee is lower than 12% (the initial fee ceiling)
            -An amount for each Pool is required to be entered, even if the specific fee amount won't be changed         
            -Each variable should be entered as a single or double digit number to represent the intended percentage; i.e.: 
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
    

    // TODO: Write out comment for function
    // TODO: Write in actual wallet addresses
    // Time-Locks the specified wallet address for the given time, Function can only be called by owner, 
    function _vestWallet(address sender, address beneficiary, uint256 amount, uint256 releaseTime) public onlyOwner() {
        TokenLock newVestedWallet = new TokenLock(IBEP20(address(this)), sender, beneficiary, amount, releaseTime);
        newVestedWallet.lockTokens();
    }
    
    
    // Initializes the Community, Liquidity, Charity, and Company Pools with their alotted number of tokens over their specified vesting period.
    function _initializeTokenDistribution() internal onlyOwner() {
        
        IBEP20 gaussToken = IBEP20(address(this));
        
        // Sets the addresses for each wallet used for and by the company
        address communityWallet;
        address liquidityWallet;
        address charitableFundWallet;
        address advisorWallet;
        address coreTeamWallet;
        address marketingWallet;
        address operationsAndDevelopementWallet;
        address vestingIncentiveWallet;
        
        
        // Sets each of the Company's wallets initial amount
        uint256 communityAmount = 112500000;
        uint256 liquidityAmount = 20000000;
        uint256 charitableFundAmount = 15000000;
        uint256 advisorAmount = 35000000;
        uint256 coreTeamAmount = 15000000;
        uint256 marketingAmount = 15000000;
        uint256 opsDevAmount = 15000000;
        uint256 incentiveAmount = 12500000;
        
        
        // Creates instance of of each TokenLock contract
        CommunityTokenLock communityLock = new CommunityTokenLock(gaussToken, owner(), communityWallet, communityAmount);
        LiquidityTokenLock liquidityLock = new LiquidityTokenLock(gaussToken, owner(), liquidityWallet, liquidityAmount);
        CharitableFundTokenLock charitableFundLock = new CharitableFundTokenLock(gaussToken, owner(), charitableFundWallet, charitableFundAmount);
        AdvisorTokenLock advisorLock = new AdvisorTokenLock(gaussToken, owner(), advisorWallet, advisorAmount);
        CoreTeamTokenLock coreTeamLock = new CoreTeamTokenLock(gaussToken, owner(), coreTeamWallet, coreTeamAmount);
        
 
        // Transfers the tokens to the respective TokenLock contracts for each pool
        communityLock.lockTokens();
        liquidityLock.lockTokens();
        charitableFundLock.lockTokens();
        advisorLock.lockTokens();
        coreTeamLock.lockTokens();
        

        // Transfers initial tokens to Company Wallets
        _balances[owner()] = _balances[owner()].sub(marketingAmount, "BEP20: transfer amount exceeds balance");
        _balances[marketingWallet] = _balances[marketingWallet].add(marketingAmount);
        
        _balances[owner()] = _balances[owner()].sub(opsDevAmount, "BEP20: transfer amount exceeds balance");
        _balances[operationsAndDevelopementWallet] = _balances[operationsAndDevelopementWallet].add(opsDevAmount);
        
        _balances[owner()] = _balances[owner()].sub(incentiveAmount, "BEP20: transfer amount exceeds balance");
        _balances[vestingIncentiveWallet] = _balances[vestingIncentiveWallet].add(incentiveAmount);
        
        emit Transfer(owner(), marketingWallet, marketingAmount);
        emit Transfer(owner(), operationsAndDevelopementWallet, opsDevAmount);
        emit Transfer(owner(), vestingIncentiveWallet, incentiveAmount);
        
    }
}