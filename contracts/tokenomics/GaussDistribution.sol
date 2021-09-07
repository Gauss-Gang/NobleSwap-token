/*  _____________________________________________________________________________

    Gauss(Gang) Initial Token Distribution Contract

    Deployed to      : TODO

    MIT License. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.4 <0.9.0;

import "../dependencies/contracts/Context.sol";
import "../dependencies/contracts/Ownable.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/libraries/Address.sol";
import "./TimeLock/TokenLock.sol";
import "./TimeLock/ScheduledTokenLock.sol";



// TODO: Write Comment
contract GaussDistribution is Context, Ownable {
    
    // Dev-Note: Solidity 0.8.0 has added built-in support for checked math, therefore the "SafeMath" library is no longer needed.
    using Address for address;
 
    // Sets the addresses for each wallet used for and by the company
    address public communityWallet = 0x4249B05E707FeeA3FB034071C66e5A227C230C2f;
    address public liquidityWallet = 0x17cA40C901Af4C31Ed9F5d961b16deD9a4715505;
    address public charitableFundWallet = 0x7d74E237825Eba9f4B026555f17ecacb2b0d78fE;
    address public advisorWallet = 0x3e3049A80590baF63B6aC8D74F5CbB31584059bB;
    address public coreTeamWallet = 0x747dDE9cb0b8B86ef1d221077055EE9ec4E70b89;
    address public marketingWallet = 0x46ceE8F5F3e30aF7b62374249907FB97563262f5;
    address public operationsAndDevelopementWallet = 0xF9f41Bd5C7B6CF9a3C6E13846035005331ed940e;
    address public vestingIncentiveWallet = 0xe3778Db10A5E8b2Bd1B68038F2cEFA835aa46b45;
    address public reserveWallet = 0xf02fD116EEfB47E394721356B36D3350972Cc0c7;
    
    // Creates a callable address for each token lock contract, set after they are deployed
    address public communityLockAddress;
    address public liquidityLockAddress;
    address public charitableFundLockAddress;
    address public advisorLockAddress;
    address public coreTeamLockAddress;
    address public marketingLockAddress;
    address public opsDevLockAddress;
    address public incentiveLockAddress;
    address public reserveLockAddress;
    
    // Sets each of the Company's wallets initial token amount
    uint256 private _communityAmount = 112500000;
    uint256 private _liquidityAmount = 20000000;
    uint256 private _charitableFundAmount = 15000000;
    uint256 private _advisorAmount = 6500000;
    uint256 private _coreTeamAmount = 25000000;
    uint256 private _marketingAmount = 15000000;
    uint256 private _opsDevAmount = 15000000;
    uint256 private _incentiveAmount = 12500000;
    uint256 private _reserveAmount = 28500000;

    // Creates dynamic arrays for token amounts and lock times for each TokenLock contract
    uint256[] private _communityTokenAmountsList;
    uint256[] private _communityLockTimes;
    uint256[] private _liquidityTokenAmountsList;
    uint256[] private _liquidityLockTimes;
    uint256[] private _charitableFundTokenAmountsList;
    uint256[] private _charitableFundLockTimes;
    uint256[] private _advisorTokenAmountsList;
    uint256[] private _advisorLockTimes;
    uint256[] private _coreTeamTokenAmountsList;
    uint256[] private _coreTeamLockTimes;
    uint256[] private _marketingTokenAmountsList;
    uint256[] private _marketingLockTimes;
    uint256[] private _opsDevTokenAmountsList;
    uint256[] private _opsDevLockTimes;
    uint256[] private _incentiveTokenAmountsList;
    uint256[] private _incentiveLockTimes;
    uint256[] private _reserveTokenAmountsList;
    uint256[] private _reserveLockTimes;
    
    // Creates variables to hold the address of the Gauss(GANG) address as well as the "sender" of the tokens to be transferred
    address private _gaussAddress;
    address private _senderAddress;
    IBEP20  private  gaussToken;


    
    /*  The constructor sets internal the values of _gaussAddress, and _senderAddress to the variables passed in when called externally
          as well as calling the internal functions that create a Time Lock contract for each Pool of tokens                        */
    constructor (address gaussOwner, address gaussGANGAddress) {     
        
        require(msg.sender == gaussOwner);
        
        _gaussAddress = gaussGANGAddress;
        _senderAddress = msg.sender;
        gaussToken = IBEP20(_gaussAddress);
        
        _lockCommunityTokens();
        _lockLiquidityTokens();
        _lockCharitableFundTokens();
        _lockAdvisorTokens();
        _lockCoreTeamTokens();
        _lockMarketingTokens();
        _lockOpsDevTokens();
        _lockVestingIncentiveTokens();
        _lockReserveTokens;
    }
    
    
    // Returns the Contract owner.
    function getOwner() external view returns (address) {
        return owner();
    }
    
    
    // Time-Locks the specified wallet address for the given time, Function can only be called by "owner". Returns the address it is deployed to. 
    function vestTokens(address sender, address beneficiary, uint256 amount, uint256 releaseTime) public onlyOwner() returns (address) {
        TokenLock newVestedLock = new TokenLock(gaussToken, sender, beneficiary, amount, releaseTime);
        newVestedLock.lockTokens();
        return newVestedLock.contractAddress();
    }
    
    
    // Time-Locks the specified wallet address for the given time, Function can only be called by "owner". Returns the address it is deployed to. 
    function scheduledVesting(address sender, address beneficiary, uint256 amount, uint256[] memory amountsList, uint256[] memory lockTimes) public onlyOwner() returns (address) {
        ScheduledTokenLock newVestedLock = new ScheduledTokenLock(gaussToken, sender, beneficiary, amount, amountsList, lockTimes);
        newVestedLock.lockTokens();
        return newVestedLock.contractAddress();
    }
    

    /*  Time-Locks the wallet holding the Community Pool funds over a specific time period
            - Total Community Pool Tokens is 112,500,000, 45% of total supply
            - As the wallet is unlocked, the tokens will be distributed into the community supply pool
        
            Release Schedule is as follows:
                Launch, Month 0:    25,000,000 tokens released
                Months 1 - 6:       1,250,000 tokens released per month
                Months 7 - 23:      4,444,444 tokens released per month
                Month 24:           4,444,452 tokens released
    */
    function _lockCommunityTokens() internal {
        
        // Initializes the amounts to be released over time
        _communityTokenAmountsList.push(25000000);
        
        for (uint i = 0; i < 6; i++) {
            _communityTokenAmountsList.push(1250000);
        }
        
        for (uint i = 0; i < 17; i++) {
            _communityTokenAmountsList.push(4444444);
        }
        
        _communityTokenAmountsList.push(4444452);
        
        // Initializes the time periods that tokens will be released over
        _communityLockTimes.push(1 seconds);
        
        for (uint i = 0; i < 24; i++) {
            _communityLockTimes.push(((30 days) * (i + 1)));
        }
        
        // Creates instance of of the Community Pool TokenLock contract
        ScheduledTokenLock communityLock = new ScheduledTokenLock(gaussToken, _senderAddress, communityWallet, _communityAmount, _communityTokenAmountsList, _communityLockTimes);
        
        // Transfers the tokens to the Community Pool TokenLock contract, locking the tokens over the specified schedule above.
        communityLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        communityLockAddress = communityLock.contractAddress();
    }
    

    /*  Time-Locks the wallet holding the Liquidity Pool funds over a specific time period
            - Total Liquidity Pool Tokens is 20,000,000, 8% of total supply
        
            Release Schedule is as follows:
                Month 4:    10,000,000 tokens released
                Month 8:    10,000,000 tokens released
    */
    function _lockLiquidityTokens() internal {
        
        // Initializes the amounts to be released over time
        _liquidityTokenAmountsList.push(10000000);
        _liquidityTokenAmountsList.push(10000000);

        // Initializes the time periods that tokens will be released over
        _liquidityLockTimes.push(120 days);
        _liquidityLockTimes.push(240 days);

        // Creates instance of of the Liquidity Pool TokenLock contract
        ScheduledTokenLock liquidityLock = new ScheduledTokenLock(gaussToken, _senderAddress, liquidityWallet, _liquidityAmount, _liquidityTokenAmountsList, _liquidityLockTimes);
        
        // Transfers the tokens to the Liquidity Pool TokenLock contract, locking the tokens over the specified schedule above.
        liquidityLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        liquidityLockAddress = liquidityLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Charitable Fund over a specific time period
            - Total Charitable Fund Tokens is 15,000,000, 6% of total supply
        
            Release Schedule is as follows:
                Launch, Month 0:        1,111,111 tokens released (Used to create redistribution expirement)
                Month 6 - 23:           771,605 tokens released per Month
                Month 24:               771,604 tokens released
    */
    function _lockCharitableFundTokens() internal {
        
        // Initializes the amounts to be released over time
        _charitableFundTokenAmountsList.push(1111111);
        
        for (uint i = 5; i < 23; i++) {
            _charitableFundTokenAmountsList.push(771605);    
        }
        
        _charitableFundTokenAmountsList.push(771604);
        
        // Initializes the time periods that tokens will be released over
        _charitableFundLockTimes.push(1 seconds);
        
        for (uint i = 5; i < 24; i++) {
            _charitableFundLockTimes.push(((30 days) * (i + 1)));
        }

        // Creates instance of of the Charitable Funds TokenLock contract
        ScheduledTokenLock charitableFundLock = new ScheduledTokenLock(gaussToken, _senderAddress, charitableFundWallet, _charitableFundAmount, _charitableFundTokenAmountsList, _charitableFundLockTimes);
        
        // Transfers the tokens to the Charitable Funds TokenLock contract, locking the tokens over the specified schedule above.
        charitableFundLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        charitableFundLockAddress = charitableFundLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Advisor Pool over a specific time period
            - Total Advisor Pool Tokens is 6,500,000, 2.6% of total supply
        
            Release Schedule is as follows:
                Months 1 - 18:          325,000 tokens released per Month
                Months 19 - 24:         162,500 tokens released per Month
    */
    function _lockAdvisorTokens() internal {
        
        // Initializes the amounts to be released over time
        
        for (uint i = 1; i < 18; i++) {
            _advisorTokenAmountsList.push(325000);    
        }
        
        for (uint i = 18; i < 24; i++) {
            _advisorTokenAmountsList.push(162500);    
        }
 
        // Initializes the time periods that tokens will be released over
        for (uint i = 5; i < 24; i++) {
            _advisorLockTimes.push(((30 days) * (i + 1)));
        }

        // Creates instance of of the Advisor Funds TokenLock contract
        ScheduledTokenLock advisorLock = new ScheduledTokenLock(gaussToken, _senderAddress, advisorWallet, _advisorAmount, _advisorTokenAmountsList, _advisorLockTimes);
        
        // Transfers the tokens to the Advisor Funds TokenLock contract, locking the tokens over the specified schedule above.
        advisorLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        advisorLockAddress = advisorLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Core Team Pool over a specific time period
            - Total Core Team Pool Tokens is 25,000,000, 10% of total supply
            
            Release Schedule is as follows:
                Month 5:        6,250,000 tokens released
                Month 10:       6,250,000 tokens released
                Month 15:       6,250,000 tokens released
                Month 20:       6,250,000 tokens released
    */
    function _lockCoreTeamTokens() internal {
        
        // Initializes the amounts to be released over time
        _coreTeamTokenAmountsList.push(6250000);
        _coreTeamTokenAmountsList.push(6250000);
        _coreTeamTokenAmountsList.push(6250000);
        _coreTeamTokenAmountsList.push(6250000);

        // Initializes the time periods that tokens will be released over
        _coreTeamLockTimes.push(150 days);
        _coreTeamLockTimes.push(300 days);
        _coreTeamLockTimes.push(450 days);
        _coreTeamLockTimes.push(600 days);

        // Creates instance of of the Core Team Funds TokenLock contract
        ScheduledTokenLock coreTeamLock = new ScheduledTokenLock(gaussToken, _senderAddress, coreTeamWallet, _coreTeamAmount, _coreTeamTokenAmountsList, _coreTeamLockTimes);
        
        // Transfers the tokens to the Core Team Pool TokenLock contract, locking the tokens over the specified schedule above.
        coreTeamLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        coreTeamLockAddress = coreTeamLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Marketing Funds over a specific time period
            - Total Marketing Funds Tokens is 15,000,000, 6% of total supply
        
            Release Schedule is as follows:
                Launch, Month 0:        600,000 tokens released
                Month 1 - 24:           600,000 tokens released per Month
    */
    function _lockMarketingTokens() internal {
        
        // Initializes the amounts to be released over time
        for (uint i = 0; i < 25; i++) {
            _marketingTokenAmountsList.push(600000);
        }

        // Initializes the time periods that tokens will be released over
        _marketingLockTimes.push(1 seconds);
        
        for (uint i = 0; i < 24; i++) {
            _marketingLockTimes.push(((30 days) * (i + 1)));
        }

        // Creates instance of of the Marketing Funds TokenLock contract
        ScheduledTokenLock marketingLock = new ScheduledTokenLock(gaussToken, _senderAddress, marketingWallet, _marketingAmount, _marketingTokenAmountsList, _marketingLockTimes);
        
        // Transfers the tokens to the Marketing Funds Marketing Funds, locking the tokens over the specified schedule above.
        marketingLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        marketingLockAddress = marketingLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Operations and Developement Funds over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:        600,000 tokens released
                Month 1 - 24:           600,000 tokens released per Month
    */
    function _lockOpsDevTokens() internal {
        
        // Initializes the amounts to be released over time
        for (uint i = 0; i < 25; i++) {
            _opsDevTokenAmountsList.push(600000);
        }

        // Initializes the time periods that tokens will be released over
        _opsDevLockTimes.push(1 seconds);
        
        for (uint i = 0; i < 24; i++) {
            _opsDevLockTimes.push(((30 days) * (i + 1)));
        }

        // Creates instance of of the Operations and Developement Funds TokenLock contract
        ScheduledTokenLock opsDevLock = new ScheduledTokenLock(gaussToken, _senderAddress, operationsAndDevelopementWallet, _opsDevAmount, _opsDevTokenAmountsList, _opsDevLockTimes);
        
        // Transfers the tokens to the Operations and Developement Funds TokenLock contract, locking the tokens over the specified schedule above.
        opsDevLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        opsDevLockAddress = opsDevLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Vesting Incentive Funds over a specific time period
            - Total Marketing Funds Tokens is 12,500,000, 5% of total supply
        
            Release Schedule is as follows:
                Launch, Month 0:        500,000 tokens released
                Month 1 - 24:           500,000 tokens released per Month
    */
    function _lockVestingIncentiveTokens() internal {
        
        // Initializes the amounts to be released over time
        for (uint i = 0; i < 25; i++) {
            _incentiveTokenAmountsList.push(500000);
        }
       
        // Initializes the time periods that tokens will be released over
        _incentiveLockTimes.push(1 seconds);
        
        for (uint i = 0; i < 24; i++) {
            _incentiveLockTimes.push(((30 days) * (i + 1)));
        }
 
        // Creates instance of of the Vesting Incentive Funds TokenLock contract
        ScheduledTokenLock incentiveLock = new ScheduledTokenLock(gaussToken, _senderAddress, vestingIncentiveWallet, _incentiveAmount, _incentiveTokenAmountsList, _incentiveLockTimes);
        
        // Transfers the tokens to the Vesting Incentive Funds TokenLock contract, locking the tokens over the specified schedule above.
        incentiveLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        incentiveLockAddress = incentiveLock.contractAddress();
    }
    
    
    /*  Time-Locks the wallet holding the Reserve Pool over a specific time period
            - Total Reserve Pool Tokens is 28,500,000, 11.4% of total supply
        
            Release Schedule is as follows:
                Months 0 - 20:      4,750,000 tokens released every 4 Months (Months 0, 4, 8, 12, 16, 20) 
    */
    function _lockReserveTokens() internal {
        
        // Initializes the amounts to be released over time
        for (uint i = 0; i < 6; i++) {
            _reserveTokenAmountsList.push(4750000);
        }
 
        // Initializes the time periods that tokens will be released over
        for (uint i = 0; i < 6; i++) {
            _reserveLockTimes.push(((120 days) * i));
        }

        // Creates instance of of the Advisor Funds TokenLock contract
        ScheduledTokenLock reserveLock = new ScheduledTokenLock(gaussToken, _senderAddress, reserveWallet, _reserveAmount, _reserveTokenAmountsList, _reserveLockTimes);
        
        // Transfers the tokens to the Advisor Funds TokenLock contract, locking the tokens over the specified schedule above.
        reserveLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        reserveLockAddress = reserveLock.contractAddress();
    }
}