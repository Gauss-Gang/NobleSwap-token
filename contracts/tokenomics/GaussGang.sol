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

import "../dependencies/contracts/BEP20.sol";
import "../dependencies/libraries/SafeMath.sol";
import "../dependencies/libraries/Address.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapRouter01.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapRouter02.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapPair.sol";
import "../dependencies/interfaces/pancakeSwap/IPancakeSwapFactory.sol";
import "./GaussGangTokenLock.sol";


contract GaussGang is BEP20 {
    
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
        
        
        // Vests the Community, Liquidity, Company, Core Team, and Advisor wallets. Vesting schedule is explained above each internal function called
        _vestCommunityWallets;
        _vestLiquidityWallets;
        _vestCharitableFundWallets;
        _vestAdvisorWallets;
        _vestCoreWallets;
        _setCompanyWallets;


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
    
    
    
    // TODO Write in actual wallet addresses
    // TODO: Consider writing actual token amounts instead or in addition to for the comment
    /* Internal function only called by the constructor, Time-Locks each Community Pool Wallet according to a set schedule
        - Once these wallets are unlocked, the tokens will be distributed into the community supply pool
        
            Release Schedule is as follows:
                Launch, Month 0:    10% of total alloted community pool tokens released
                Month 1:            6% of total alloted community pool tokens released
                Month 2:            5% of total alloted community pool tokens released
                Month 3:            6% of total alloted community pool tokens released
                Months 5,9:         5% of total alloted community pool tokens released
                Months 13,16,19:    3% of total alloted community pool tokens released
                Month 22:           2.15% of total alloted community pool tokens released
    */
    function _vestCommunityWallets() internal onlyOwner() {
        
        // Sets each Community Wallet Address
        address[10] memory communityAddressList = 
            [   (address),      // communityWallet0
                (address),      // communityWallet1
                (address),      // communityWallet2
                (address),      // communityWallet3
                (address),      // communityWallet4
                (address),      // communityWallet5
                (address),      // communityWallet6
                (address),      // communityWallet7
                (address),      // communityWallet8
                (address)       // communityWallet9
            ];
        

        // Sets each wallet's initial amount
        uint256[] memory communityTokenAmountsList = 
            [   25000000,       // communityAmount0
                14062500,       // communityAmount1
                11250000,       // communityAmount2
                14062500,       // communityAmount3
                11250000,       // communityAmount4
                11250000,       // communityAmount5
                6750000,        // communityAmount6
                6750000,        // communityAmount7
                6750000,        // communityAmount8
                5375000         // communityAmount9
            ];


        // TODO Set the gangToken feild to an amount transfer from "owner"
        GaussGangTokenLock communityLock0 = new GaussGangTokenLock(IBEP20, communityAddressList[0], 1 days);
        GaussGangTokenLock communityLock1 = new GaussGangTokenLock(IBEP20, communityAddressList[1], 30 days);
        GaussGangTokenLock communityLock2 = new GaussGangTokenLock(IBEP20, communityAddressList[2], 60 days);
        GaussGangTokenLock communityLock3 = new GaussGangTokenLock(IBEP20, communityAddressList[3], 90 days);
        GaussGangTokenLock communityLock4 = new GaussGangTokenLock(IBEP20, communityAddressList[4], 150 days);
        GaussGangTokenLock communityLock5 = new GaussGangTokenLock(IBEP20, communityAddressList[5], 270 days);
        GaussGangTokenLock communityLock6 = new GaussGangTokenLock(IBEP20, communityAddressList[6], (1 years + 30 days));
        GaussGangTokenLock communityLock7 = new GaussGangTokenLock(IBEP20, communityAddressList[7], (1 years + 120 days));
        GaussGangTokenLock communityLock8 = new GaussGangTokenLock(IBEP20, communityAddressList[8], (1 years + 210 days));
        GaussGangTokenLock communityLock9 = new GaussGangTokenLock(IBEP20, communityAddressList[9], (1 years + 300 days));
    }
    
    
    
    // TODO: Write out comment for function
    // TODO Write in actual wallet addresses
    // Internal function only called by the constructor, Time-Locks each Liquidity Pool Wallet
    function _vestLiquidityWallets() internal onlyOwner() {
        
        // Sets each Liquidity Wallet Address
        address[] calldata liquidityAddressList = 
            [   (address),      // liquidityWallet0
                (address)       // liquidityWallet1
            ];
        

        // Sets each wallet's initial amount
        uint256[] memory liquidityTokenAmountsList = 
            [   10000000,       // liquidityAmount0
                10000000        // liquidityAmount1
            ];


        // TODO Set the gangToken feild to an amount transfer from "owner"
        GaussGangTokenLock liquidityLock0 = new GaussGangTokenLock(IBEP20, liquidityAddressList[0], 120 days);
        GaussGangTokenLock liquidityLock1 = new GaussGangTokenLock(IBEP20, liquidityAddressList[1], 240 days);
    }
    
    
    
    // TODO: Write out comment for function
    // TODO Write in actual wallet addresses
    // Internal function only called by the constructor, Time-Locks each Company Wallet
    function _vestCharitableFundWallets() internal onlyOwner() {
        
        // Sets each Charitable Fund Wallet Address
        address[] calldata charitableFundAddressList = 
            [   (address),      // charitableFundWallet0
                (address),      // charitableFundWallet1
                (address),      // charitableFundWallet2
                (address),      // charitableFundWallet3
                (address),      // charitableFundWallet4
                (address),      // charitableFundWallet5
                (address),      // charitableFundWallet6
                (address)      // charitableFundWallet7
            ];
        

        // Sets each wallet's initial amount
        uint256[] memory charitableFundTokenAmountsList = 
            [   13888889,       // charitableFundAmount0
                1,              // charitableFundAmount1
                10,             // charitableFundAmount2
                100,            // charitableFundAmount3
                1000,           // charitableFundAmount4
                10000,          // charitableFundAmount5
                100000,         // charitableFundAmount6
                1000000         // charitableFundAmount7
            ];


        // TODO Set the gangToken feild to an amount transfer from "owner"
        GaussGangTokenLock charitableFundLock0 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[0], 180 days);
        GaussGangTokenLock charitableFundLock1 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[1], (2 years + 30 days));
        GaussGangTokenLock charitableFundLock2 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[2], (2 years + 30 days));
        GaussGangTokenLock charitableFundLock3 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[3], (2 years + 30 days));
        GaussGangTokenLock charitableFundLock4 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[4], (2 years + 30 days));
        GaussGangTokenLock charitableFundLock5 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[5], (2 years + 30 days));
        GaussGangTokenLock charitableFundLock6 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[6], (2 years + 30 days));
        GaussGangTokenLock charitableFundLock7 = new GaussGangTokenLock(IBEP20, charitableFundAddressList[7], (2 years + 30 days));
    }
    
    
    
    // TODO: Write out comment for function
    // TODO Write in actual wallet addresses
    // Internal function only called by the constructor, Time-Locks each Advisor Wallet
    function _vestAdvisorWallets() internal onlyOwner() {
        
        // Sets each Advisor Wallet Address
        address[] calldata advisorAddressList = 
            [   (address),      // advisorWallet0
                (address),      // advisorWallet1
                (address),      // advisorWallet2
                (address),      // advisorWallet3
                (address),      // advisorWallet4
                (address),      // advisorWallet5
                (address)       // advisorWallet6
            ];
        

        // Sets each wallet's initial amount
        uint256[] memory advisorTokenAmountsList = 
            [   6500000,        // advisorAmount0
                4750000,        // advisorAmount1
                4750000,        // advisorAmount2
                4750000,        // advisorAmount3
                4750000,        // advisorAmount4
                4750000,        // advisorAmount5
                4750000         // advisorAmount6
            ];


        // Consider changing the vesting period for wallet 0
        // TODO Set the gangToken feild to an amount transfer from "owner"
        GaussGangTokenLock advisorLock0 = new GaussGangTokenLock(IBEP20, advisorAddressList[0], 1 days);
        GaussGangTokenLock advisorLock1 = new GaussGangTokenLock(IBEP20, advisorAddressList[1], 1 days);
        GaussGangTokenLock advisorLock2 = new GaussGangTokenLock(IBEP20, advisorAddressList[2], 120 days);
        GaussGangTokenLock advisorLock3 = new GaussGangTokenLock(IBEP20, advisorAddressList[3], 240 days);
        GaussGangTokenLock advisorLock4 = new GaussGangTokenLock(IBEP20, advisorAddressList[4], 1 years);
        GaussGangTokenLock advisorLock5 = new GaussGangTokenLock(IBEP20, advisorAddressList[5], (1 years + 120 days));
        GaussGangTokenLock advisorLock6 = new GaussGangTokenLock(IBEP20, advisorAddressList[6], (1 years + 240 days));
    }
    
    
    
    // TODO: Write out comment for function
    // TODO: Write in actual wallet addresses
    // Internal function only called by the constructor, Time-Locks each Core Team members Wallet
    function _vestCoreWallets() internal onlyOwner() {
        
        // Sets each Core Team Wallet Address
        address[] calldata coreTeamAddressList = 
            [   (address),      // coreTeamWallet0
                (address),      // coreTeamWallet1
                (address),      // coreTeamWallet2
                (address)       // coreTeamWallet3
            ];
        

        // Sets each wallet's initial amount
        uint256[] memory coreTeamTokenAmountsList = 
            [   6250000,        // coreTeamAmount0
                6250000,        // coreTeamAmount1
                6250000,        // coreTeamAmount2
                6250000         // coreTeamAmount3
            ];


        // TODO Set the gangToken feild to an amount transfer from "owner"
        GaussGangTokenLock coreTeamLock0 = new GaussGangTokenLock(IBEP20, coreTeamAddressList[0], 150 days);
        GaussGangTokenLock coreTeamLock1 = new GaussGangTokenLock(IBEP20, coreTeamAddressList[1], 300 days);
        GaussGangTokenLock coreTeamLock2 = new GaussGangTokenLock(IBEP20, coreTeamAddressList[2], (1 years + 90 days));
        GaussGangTokenLock coreTeamLock3 = new GaussGangTokenLock(IBEP20, coreTeamAddressList[3], (1 years + 240 days));
    }
    
    

    // TODO: Write out comment for function
    // TODO: Write in actual wallet addresses
    // Internal function only called by the constructor, moves an initial allotted amount to Company Wallet
    function _setCompanyWallets() internal onlyOwner() {
        
        // Sets each Company Wallet Address
        address marketingWallet;
        address operationsAndDevelopementWallet;
        address vestingIncentiveWallet;
        

        // Sets each wallet's initial amount
        uint256 marketingAmount = 15000000;
        uint256 opsDevAmount = 15000000;
        uint256 incentiveAmount = 12500000;
        
        
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
    
    
    
    // TODO: Write out comment for function
    // TODO: Write in actual wallet addresses
    // Time-Locks the specified wallet address for the given time, Function can only be called by owner, 
    function _vestWallet(address wallet, uint256 releaseTime, IBEP20 token) internal onlyOwner() {
        GaussGangTokenLock newVestedWallet = new GaussGangTokenLock(token, wallet, releaseTime);
    }
}