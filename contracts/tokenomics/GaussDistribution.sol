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
import "../dependencies/libraries/SafeMath.sol";
import "../dependencies/libraries/Address.sol";
import "./TimeLock/TokenLock.sol";
import "./TimeLock/ScheduledTokenLock.sol";


// TODO: Write Comment
contract GaussDistribution is Context, Ownable {
    
    using SafeMath for uint256;
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
    
    // Creates a callable address for each token lock contract, set after they are deployed
    address public communityLockAddress;
    address public liquidityLockAddress;
    address public charitableFundLockAddress;
    address public advisorLockAddress;
    address public coreTeamLockAddress;
    address public marketingLockAddress;
    address public opsDevLockAddress;
    address public incentiveLockAddress;
    
    // TODO: Consider making public
    // Sets each of the Company's wallets initial token amount
    uint256 private _communityAmount = 112500000;
    uint256 private _liquidityAmount = 20000000;
    uint256 private _charitableFundAmount = 15000000;
    uint256 private _advisorAmount = 35000000;
    uint256 private _coreTeamAmount = 25000000;
    uint256 private _marketingAmount = 15000000;
    uint256 private _opsDevAmount = 15000000;
    uint256 private _incentiveAmount = 12500000;   
    uint256 private _totalAmount = 250000000;
    
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
    
    // Creates variables to hold the address of the Gauss(GANG) address as well as the "sender" of the tokens to be transferred
    address private _gaussAddress;
    address private _senderAddress;
    IBEP20  private  gaussToken;


    
    /* The constructor sets internal the values of _gaussAddress, and _senderAddress to the variables passed in when called externally
          as well as calliung the internal functions that create a Time Lock contract for each Pool of tokens                       */
    constructor (uint amount, address gaussGANGAddress) {     
        
        require(amount == _totalAmount);
        
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
    


    /* Time-Locks the wallet holding the Community Pool funds over a specific time period
            - As the wallet is unlocked, the tokens will be distributed into the community supply pool
        
            Release Schedule is as follows:
                Launch, Month 0:    10% of total alloted community pool tokens released
                Month 1:            6% of total alloted community pool tokens released
                Month 2:            5% of total alloted community pool tokens released
                Month 3:            6% of total alloted community pool tokens released
                Months 5,9:         5% of total alloted community pool tokens released
                Months 13,16,19:    3% of total alloted community pool tokens released
                Month 22:           2.15% of total alloted community pool tokens released
    */
    function _lockCommunityTokens() internal {
        
        // Initializes the amounts to be released over time
        _communityTokenAmountsList.push(    25000000    );
        _communityTokenAmountsList.push(    14062500    );
        _communityTokenAmountsList.push(    11250000    );
        _communityTokenAmountsList.push(    14062500    );
        _communityTokenAmountsList.push(    11250000    );
        _communityTokenAmountsList.push(    11250000    );
        _communityTokenAmountsList.push(    6750000     );
        _communityTokenAmountsList.push(    6750000     );
        _communityTokenAmountsList.push(    6750000     );
        _communityTokenAmountsList.push(    5375000     );
     
        // Initializes the time periods that tokens will be released over
        _communityLockTimes.push(    1   days    );
        _communityLockTimes.push(    30  days    );
        _communityLockTimes.push(    60  days    );
        _communityLockTimes.push(    90  days    );
        _communityLockTimes.push(    150 days    );
        _communityLockTimes.push(    270 days    );
        _communityLockTimes.push(    395 days    );
        _communityLockTimes.push(    485 days    );
        _communityLockTimes.push(    575 days    );
        _communityLockTimes.push(    665 days    );

        // Creates instance of of the Community Pool TokenLock contract
        ScheduledTokenLock communityLock = new ScheduledTokenLock(gaussToken, _senderAddress, communityWallet, _communityAmount, _communityTokenAmountsList, _communityLockTimes);
        
        // Transfers the tokens to the Community Pool TokenLock contract, locking the tokens over the specified schedule above.
        communityLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        communityLockAddress = communityLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Liquidity Pool funds over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockLiquidityTokens() internal {
        
        // Initializes the amounts to be released over time
        _liquidityTokenAmountsList.push(    10000000    );
        _liquidityTokenAmountsList.push(    10000000    );

        // Initializes the time periods that tokens will be released over
        _liquidityLockTimes.push(     120 days    );
        _liquidityLockTimes.push(     240 days    );

        // Creates instance of of the Liquidity Pool TokenLock contract
        ScheduledTokenLock liquidityLock = new ScheduledTokenLock(gaussToken, _senderAddress, liquidityWallet, _liquidityAmount, _liquidityTokenAmountsList, _liquidityLockTimes);
        
        // Transfers the tokens to the Liquidity Pool TokenLock contract, locking the tokens over the specified schedule above.
        liquidityLock.lockTokens();
        
        // TODO: Ensure this is the correct syntax
        liquidityLockAddress = liquidityLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Charitable Fund over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockCharitableFundTokens() internal {
        
        // TODO: Fix amounts, cover the "1111111" over multple wallets
        // Initializes the amounts to be released over time
        _charitableFundTokenAmountsList.push(    13888889    ); 
        _charitableFundTokenAmountsList.push(    1111111     );

        // Initializes the time periods that tokens will be released over
        _charitableFundLockTimes.push(     180 days    );
        _charitableFundLockTimes.push(     760 days    );
        
        // Creates instance of of the Charitable Funds TokenLock contract
        ScheduledTokenLock charitableFundLock = new ScheduledTokenLock(gaussToken, _senderAddress, charitableFundWallet, _charitableFundAmount, _charitableFundTokenAmountsList, _charitableFundLockTimes);
        
        // Transfers the tokens to the Charitable Funds TokenLock contract, locking the tokens over the specified schedule above.
        charitableFundLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        charitableFundLockAddress = charitableFundLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Advisor Pool over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockAdvisorTokens() internal {
        
        // Initializes the amounts to be released over time
        _advisorTokenAmountsList.push(      11250000    );
        _advisorTokenAmountsList.push(      4750000     );
        _advisorTokenAmountsList.push(      4750000     );
        _advisorTokenAmountsList.push(      4750000     );
        _advisorTokenAmountsList.push(      4750000     );
        _advisorTokenAmountsList.push(      4750000     );
 
        // Initializes the time periods that tokens will be released over
        _advisorLockTimes.push(     1   days    );
        _advisorLockTimes.push(     120 days    );
        _advisorLockTimes.push(     240 days    );
        _advisorLockTimes.push(     365 days    );
        _advisorLockTimes.push(     485 days    );
        _advisorLockTimes.push(     605 days    );
 
        // Creates instance of of the Advisor Funds TokenLock contract
        ScheduledTokenLock advisorLock = new ScheduledTokenLock(gaussToken, _senderAddress, advisorWallet, _advisorAmount, _advisorTokenAmountsList, _advisorLockTimes);
        
        // Transfers the tokens to the Advisor Funds TokenLock contract, locking the tokens over the specified schedule above.
        advisorLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        advisorLockAddress = advisorLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Core Team Pool over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockCoreTeamTokens() internal {
        
        // Initializes the amounts to be released over time
        _coreTeamTokenAmountsList.push(     6250000     );
        _coreTeamTokenAmountsList.push(     6250000     );
        _coreTeamTokenAmountsList.push(     6250000     );
        _coreTeamTokenAmountsList.push(     6250000     );

        // Initializes the time periods that tokens will be released over
        _coreTeamLockTimes.push(    150 days    );
        _coreTeamLockTimes.push(    300 days    );
        _coreTeamLockTimes.push(    455 days    );
        _coreTeamLockTimes.push(    605 days    );

        // Creates instance of of the Core Team Funds TokenLock contract
        ScheduledTokenLock coreTeamLock = new ScheduledTokenLock(gaussToken, _senderAddress, coreTeamWallet, _coreTeamAmount, _coreTeamTokenAmountsList, _coreTeamLockTimes);
        
        // Transfers the tokens to the Core Team Pool TokenLock contract, locking the tokens over the specified schedule above.
        coreTeamLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        coreTeamLockAddress = coreTeamLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Marketing Funds over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockMarketingTokens() internal {
        
        // Initializes the amounts to be released over time
        _marketingTokenAmountsList.push(    25000000    );
        _marketingTokenAmountsList.push(    14062500    );
        _marketingTokenAmountsList.push(    11250000    );
        _marketingTokenAmountsList.push(    14062500    );
        _marketingTokenAmountsList.push(    11250000    );
        _marketingTokenAmountsList.push(    11250000    );
        _marketingTokenAmountsList.push(    6750000     );
        _marketingTokenAmountsList.push(    6750000     );
        _marketingTokenAmountsList.push(    6750000     );
        _marketingTokenAmountsList.push(    5375000     );
        
        // Initializes the time periods that tokens will be released over
        _marketingLockTimes.push(      1   days     );
        _marketingLockTimes.push(      30  days     );
        _marketingLockTimes.push(      60  days     );
        _marketingLockTimes.push(      90  days     );
        _marketingLockTimes.push(      150 days     );
        _marketingLockTimes.push(      270 days     );
        _marketingLockTimes.push(      395 days     );
        _marketingLockTimes.push(      485 days     );
        _marketingLockTimes.push(      575 days     );
        _marketingLockTimes.push(      665 days     );

        // Creates instance of of the Marketing Funds TokenLock contract
        ScheduledTokenLock marketingLock = new ScheduledTokenLock(gaussToken, _senderAddress, marketingWallet, _marketingAmount, _marketingTokenAmountsList, _marketingLockTimes);
        
        // Transfers the tokens to the Core Team Pool Marketing Funds, locking the tokens over the specified schedule above.
        marketingLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        marketingLockAddress = marketingLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Operations and Developement Funds over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockOpsDevTokens() internal {
        
        // Initializes the amounts to be released over time
        _opsDevTokenAmountsList.push(    25000000    );
        _opsDevTokenAmountsList.push(    14062500    );
        _opsDevTokenAmountsList.push(    11250000    );
        _opsDevTokenAmountsList.push(    14062500    );
        _opsDevTokenAmountsList.push(    11250000    );
        _opsDevTokenAmountsList.push(    11250000    );
        _opsDevTokenAmountsList.push(    6750000     );
        _opsDevTokenAmountsList.push(    6750000     );
        _opsDevTokenAmountsList.push(    6750000     );
        _opsDevTokenAmountsList.push(    5375000     );
        
        // Initializes the time periods that tokens will be released over
        _opsDevLockTimes.push(      1   days     );
        _opsDevLockTimes.push(      30  days     );
        _opsDevLockTimes.push(      60  days     );
        _opsDevLockTimes.push(      90  days     );
        _opsDevLockTimes.push(      150 days     );
        _opsDevLockTimes.push(      270 days     );
        _opsDevLockTimes.push(      395 days     );
        _opsDevLockTimes.push(      485 days     );
        _opsDevLockTimes.push(      575 days     );
        _opsDevLockTimes.push(      665 days     );

        // Creates instance of of the Operations and Developement Funds TokenLock contract
        ScheduledTokenLock opsDevLock = new ScheduledTokenLock(gaussToken, _senderAddress, operationsAndDevelopementWallet, _opsDevAmount, _opsDevTokenAmountsList, _opsDevLockTimes);
        
        // Transfers the tokens to the Operations and Developement Funds TokenLock contract, locking the tokens over the specified schedule above.
        opsDevLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        opsDevLockAddress = opsDevLock.contractAddress();
    }
    
    
    
    // TODO: Write out Schedule
    /* Time-Locks the wallet holding the Vesting Incentive Funds over a specific time period
        
            Release Schedule is as follows:
                Launch, Month 0:
    */
    function _lockVestingIncentiveTokens() internal {
        
        // Initializes the amounts to be released over time
        _incentiveTokenAmountsList.push(    25000000    );
        _incentiveTokenAmountsList.push(    14062500    );
        _incentiveTokenAmountsList.push(    11250000    );
        _incentiveTokenAmountsList.push(    14062500    );
        _incentiveTokenAmountsList.push(    11250000    );
        _incentiveTokenAmountsList.push(    11250000    );
        _incentiveTokenAmountsList.push(    6750000     );
        _incentiveTokenAmountsList.push(    6750000     );
        _incentiveTokenAmountsList.push(    6750000     );
        _incentiveTokenAmountsList.push(    5375000     );
        
        // Initializes the time periods that tokens will be released over
        _incentiveLockTimes.push(       1   days     );
        _incentiveLockTimes.push(       30  days     );
        _incentiveLockTimes.push(       60  days     );
        _incentiveLockTimes.push(       90  days     );
        _incentiveLockTimes.push(       150 days     );
        _incentiveLockTimes.push(       270 days     );
        _incentiveLockTimes.push(       395 days     );
        _incentiveLockTimes.push(       485 days     );
        _incentiveLockTimes.push(       575 days     );
        _incentiveLockTimes.push(       665 days     );
        
        // Creates instance of of the Vesting Incentive Fundsl TokenLock contract
        ScheduledTokenLock incentiveLock = new ScheduledTokenLock(gaussToken, _senderAddress, vestingIncentiveWallet, _incentiveAmount, _incentiveTokenAmountsList, _incentiveLockTimes);
        
        // Transfers the tokens to the Vesting Incentive Funds TokenLock contract, locking the tokens over the specified schedule above.
        incentiveLock.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        incentiveLockAddress = incentiveLock.contractAddress();
    }
}