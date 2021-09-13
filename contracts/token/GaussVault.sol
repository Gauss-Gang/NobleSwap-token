/*  _____________________________________________________________________________

    Gauss(Gang) Initial Token Distribution Contract

    Deployed to      : TODO

    MIT License. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.4 <0.9.0;

import "../dependencies/utilities/Context.sol";
import "../dependencies/access/Ownable.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/libraries/Address.sol";
import "../dependencies/contracts/TokenLock.sol";                      // TODO: Refactor name to SimpleVesting
import "../dependencies/contracts/ScheduledTokenLock.sol";             // TODO: Refactor name to ScheduledVesting



// TODO: Write Comment
contract GaussVault is Context, Ownable {
    
    // Dev-Note: Solidity 0.8.0 added built-in support for checked math, therefore the "SafeMath" library is no longer needed.
    using Address for address;
    
    // Initializes an event that will be called after each VestingLock contract is deployed
    event VestingCreated(address beneficiary, address lockAddress, uint256 initialAmount);
    
    // Initializes a Struct that will hold the information for each seperate Vesting Lock.
    struct VestingLock {
        address beneficiaryWallet;      // Sets the address for beneficiary wallet that tokens will be released to.
        uint256 initialAmount;          // Sets the initial token amount for the Vesting Lock.
        uint256[] releaseAmounts;       // Sets the amounts to be released over time.
        uint256[] releaseTimes;         // Sets the time periods that tokens will be released over.
    }
    
    // Initializes an array that will hold each VestingLock Struct and a simple index variable to call the last pushed element.
    VestingLock[] public gaussVestings;
    uint256 private indexLast = gaussVestings.length-1;
    
    address[] private contractAddresses;
    

    // Creates variables to hold the address of the Gauss(GANG) address as well as the "sender" of the tokens to be transferred.
    address private _gaussAddress;
    address private _senderAddress;
    IBEP20  private  gaussToken;
    

    /*  The constructor sets internal the values of _gaussAddress, and _senderAddress to the variables passed in when called externally
          as well as calling the internal functions that create a Vesting Lock contract for each Pool of tokens.                     */
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
    
    
    // Returns the beneficiary wallet address of each Vesting Lock, can be called by anyone.
    function beneficiaryVestingAddresses() public view returns (address[] memory) {
        
        address[] memory beneficiaryWallets = new address[](gaussVestings.length);
        
        for (uint i = 0; i < gaussVestings.length; i++) {
            beneficiaryWallets[i] = gaussVestings[i].beneficiaryWallet;
        }
        
        return beneficiaryWallets; 
    }
    
    
    // Returns the addresses of each Vesting Contract deployed, can be called by anyone.
    function vestingContractAddresses() public view returns (address[] memory) {
        return contractAddresses;
    }
    
    
    // Vests the specified wallet address for the given time, Function can only be called by "owner". Returns the address it is deployed to. 
    function vestTokens(address sender, address beneficiary, uint256 amount, uint256 releaseTime) public onlyOwner() returns (address) {
        
        // Creates a VestingLock Struct, sets beneficiary address and intial amount, and then pushes the Struct into an array holding all Gauss Vestings.
        VestingLock memory newSimpleVesting = VestingLock (beneficiary, amount, new uint256[](0), new uint256[](0));
        gaussVestings.push(newSimpleVesting);
        
        // Creates an instance of a TokenLock contract.
        TokenLock newVestedLock = new TokenLock(gaussToken, sender, beneficiary, amount, releaseTime);
        
        // Transfers the tokens to the tokens to the TokenLock contract, locking the tokens over the specified schedule for each pool.
        // Also adds the address of the deployed contract to an array of all deployed contracts.
        newVestedLock.lockTokens();
        contractAddresses.push(newVestedLock.contractAddress());
        return newVestedLock.contractAddress();
        
        emit VestingCreated(beneficiary, newVestedLock.contractAddress(), amount);
    }
    
    
    // Vests the specified wallet address for the given time, Function can only be called by "owner". Returns the address it is deployed to. 
    function scheduledVesting(address sender, address beneficiary, uint256 amount, uint256[] memory amountsList, uint256[] memory lockTimes) public onlyOwner() returns (address) {
        
        require(amountsList.length == lockTimes.length, "scheduledVesting(): amountsList and lockTimes do not containt the same number of items");
        
        // Creates a VestingLock Struct, sets beneficiary address and intial amount, and then pushes the Struct into the array holding all Gauss Vestings.
        VestingLock memory newScheduledVesting = VestingLock (beneficiary, amount, new uint256[](0), new uint256[](0));
        gaussVestings.push(newScheduledVesting);
        
        // Adds the memory arrays into the VestingLock Struct.
        for (uint i = 0; i < amountsList.length; i++) {
            gaussVestings[indexLast].releaseAmounts.push(amountsList[i]);
            gaussVestings[indexLast].releaseTimes.push(lockTimes[i]);
        }
        
        // Creates an instance of a ScheduledTokenLock contract.
        ScheduledTokenLock newVestedLock = new ScheduledTokenLock (
            gaussToken,
            sender,
            gaussVestings[indexLast].beneficiaryWallet,
            gaussVestings[indexLast].initialAmount,
            gaussVestings[indexLast].releaseAmounts,
            gaussVestings[indexLast].releaseTimes
        );
        
        // Transfers the tokens to the tokens to the TokenLock contract, locking the tokens over the specified schedule for each pool.
        // Also adds the address of the deployed contract to an array of all deployed contracts.
        newVestedLock.lockTokens();
        contractAddresses.push(newVestedLock.contractAddress());
        return newVestedLock.contractAddress();
        
        emit VestingCreated(gaussVestings[indexLast].beneficiaryWallet, newVestedLock.contractAddress(), gaussVestings[indexLast].initialAmount);
    }


    /*  Vests the wallet holding the Community Pool funds over a specific time period.
            - Total Community Pool Tokens are 112,500,000, 45% of total supply.
            - As the wallet is unlocked, the tokens will be distributed into the community supply pool.
        
            Release Schedule is as follows:
                Launch, Month 0:    25,000,000 tokens released
                Months 1 - 6:       1,250,000 tokens released per month
                Months 7 - 23:      4,444,444 tokens released per month
                Month 24:           4,444,452 tokens released
    */
    function _lockCommunityTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory communityLock = VestingLock (
            0x4249B05E707FeeA3FB034071C66e5A227C230C2f,
            112500000,
            new uint256[](0),
            new uint256[](0)
        );
            
        gaussVestings.push(communityLock);

        
        // Initializes the amounts to be released over time.
        gaussVestings[indexLast].releaseAmounts.push(25000000);
        
        for (uint i = 0; i < 6; i++) {
            gaussVestings[indexLast].releaseAmounts.push(1250000);
        }
        
        for (uint i = 0; i < 17; i++) {
            gaussVestings[indexLast].releaseAmounts.push(4444444);
        }
        
        gaussVestings[indexLast].releaseAmounts.push(4444452);

        // Initializes the time periods that tokens will be released over.
        gaussVestings[indexLast].releaseTimes.push(1 seconds);

        for (uint i = 0; i < 24; i++) {
            gaussVestings[indexLast].releaseTimes.push(((30 days) * (i + 1)));
        }
        
        
        /*
        
        // Creates instance of of the Community Pool TokenLock contract.
        ScheduledTokenLock communityVesting = new ScheduledTokenLock(gaussToken, _senderAddress, communityWallet, communityAmount, _communityTokenAmountsList, _communityLockTimes);
        
        // Transfers the tokens to the Community Pool TokenLock contract, locking the tokens over the specified schedule above.
        communityVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        communityLockAddress = communityVesting.contractAddress();
        
        */
    }
    

    /*  Vests the wallet holding the Liquidity Pool funds over a specific time period.
            - Total Liquidity Pool Tokens are 20,000,000, 8% of total supply.
        
            Release Schedule is as follows:
                Month 4:    10,000,000 tokens released
                Month 8:    10,000,000 tokens released
    */
    function _lockLiquidityTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory liquidityLock = VestingLock (
            0x17cA40C901Af4C31Ed9F5d961b16deD9a4715505,
            20000000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(liquidityLock);
        
        
        // Initializes the amounts to be released over time.
        gaussVestings[indexLast].releaseAmounts.push(10000000);
        gaussVestings[indexLast].releaseAmounts.push(10000000);

        // Initializes the time periods that tokens will be released over.
        gaussVestings[indexLast].releaseTimes.push(120 days);
        gaussVestings[indexLast].releaseTimes.push(240 days);
         
        
        /*
        
        // Creates instance of of the Liquidity Pool TokenLock contract.
        ScheduledTokenLock liquidityVesting = new ScheduledTokenLock(gaussToken, _senderAddress, liquidityWallet, liquidityAmount, _liquidityTokenAmountsList, _liquidityLockTimes);
        
        // Transfers the tokens to the Liquidity Pool TokenLock contract, locking the tokens over the specified schedule above.
        liquidityVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        liquidityLockAddress = liquidityVesting.contractAddress();
        
        */
    }
    
    
    /*  Vests the wallet holding the Charitable Fund over a specific time period.
            - Total Charitable Fund Tokens are 15,000,000, 6% of total supply.
        
            Release Schedule is as follows:
                Launch, Month 0:        1,111,111 tokens released (Used to create redistribution expirement)
                Month 6 - 23:           771,605 tokens released per Month
                Month 24:               771,604 tokens released
    */
    function _lockCharitableFundTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory charitableFundLock = VestingLock (
            0x7d74E237825Eba9f4B026555f17ecacb2b0d78fE,
            15000000,
            new uint256[](0),
            new uint256[](0)
        );
            
        gaussVestings.push(charitableFundLock);
        
        
        // Initializes the amounts to be released over time.
        gaussVestings[indexLast].releaseAmounts.push(1111111);
        
        for (uint i = 0; i < 18; i++) {
            gaussVestings[indexLast].releaseAmounts.push(771605);
        }
        
        gaussVestings[indexLast].releaseAmounts.push(771604);
        
        // Initializes the time periods that tokens will be released over.
        gaussVestings[indexLast].releaseTimes.push(1 seconds);

        for (uint i = 0; i < 19; i++) {                                                         // TODO: Completely redo for loop, add starting cliff
            gaussVestings[indexLast].releaseTimes.push(((30 days) * (i + 1)));
        }

    
        /*
    
        // Creates instance of of the Charitable Funds TokenLock contract.
        ScheduledTokenLock charitableFundVesting = new ScheduledTokenLock(gaussToken, _senderAddress, charitableFundWallet, charitableFundAmount, _charitableFundTokenAmountsList, _charitableFundLockTimes);
        
        // Transfers the tokens to the Charitable Funds TokenLock contract, locking the tokens over the specified schedule above.
        charitableFundVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        charitableFundLockAddress = charitableFundVesting.contractAddress();
        
        */
    }
    
    
    // TODO: Remove amount of tokens alloted to Chris and move them to Reserved
    /*  Vests the wallet holding the Advisor Pool over a specific time period.
            - Total Advisor Pool Tokens are 6,500,000, 2.6% of total supply.
        
            Release Schedule is as follows:
                Months 1 - 18:          325,000 tokens released per Month
                Months 19 - 24:         162,500 tokens released per Month
    */
    function _lockAdvisorTokens() internal {
        
        // Write Comment
        VestingLock memory advisorLock = VestingLock (
            0x3e3049A80590baF63B6aC8D74F5CbB31584059bB,
            6500000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(advisorLock);
        
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < 17; i++) {
            gaussVestings[indexLast].releaseAmounts.push(325000);
        }
        
        for (uint i = 0; i < 7; i++) {
            gaussVestings[indexLast].releaseAmounts.push(162500);
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < 24; i++) {
            gaussVestings[indexLast].releaseTimes.push(((30 days) * (i + 1)));
        }
        
        
        /*

        // Creates instance of of the Advisor Funds TokenLock contract.
        ScheduledTokenLock advisorVesting = new ScheduledTokenLock(gaussToken, _senderAddress, advisorWallet, advisorAmount, _advisorTokenAmountsList, _advisorLockTimes);
        
        // Transfers the tokens to the Advisor Funds TokenLock contract, locking the tokens over the specified schedule above.
        advisorVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        advisorLockAddress = advisorVesting.contractAddress();
        
        */
    }
    
    
    /*  Vests the wallet holding the Core Team Pool over a specific time period.
            - Total Core Team Pool Tokens are 25,000,000, 10% of total supply.
            
            Release Schedule is as follows:
                Month 5:        6,250,000 tokens released
                Month 10:       6,250,000 tokens released
                Month 15:       6,250,000 tokens released
                Month 20:       6,250,000 tokens released
    */
    function _lockCoreTeamTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory coreTeamLock = VestingLock (
            0x747dDE9cb0b8B86ef1d221077055EE9ec4E70b89,
            25000000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(coreTeamLock);


        // Initializes the amounts to be released over time.
        for (int i = 0; i < 4; i++) {
            gaussVestings[indexLast].releaseAmounts.push(6250000);
        }

        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < 24; i++) {
            gaussVestings[indexLast].releaseTimes.push(((150 days) + (i * 150 days)));
        }


        
        /*
            
        // Creates instance of of the Core Team Funds TokenLock contract.
        ScheduledTokenLock coreTeamVesting = new ScheduledTokenLock(gaussToken, _senderAddress, coreTeamWallet, coreTeamAmount, _coreTeamTokenAmountsList, _coreTeamLockTimes);
        
        // Transfers the tokens to the Core Team Pool TokenLock contract, locking the tokens over the specified schedule above.
        coreTeamVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        coreTeamLockAddress = coreTeamVesting.contractAddress();
        
        */
    }
    
    
    /*  Vests the wallet holding the Marketing Funds over a specific time period.
            - Total Marketing Funds Tokens are 15,000,000, 6% of total supply.
        
            Release Schedule is as follows:
                Launch, Month 0:        600,000 tokens released
                Month 1 - 24:           600,000 tokens released per Month
    */
    function _lockMarketingTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory marketingLock = VestingLock (
            0x46ceE8F5F3e30aF7b62374249907FB97563262f5,
            15000000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(marketingLock);

        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < 25; i++) {
            gaussVestings[indexLast].releaseAmounts.push(600000);
        }

        // Initializes the time periods that tokens will be released over.
        gaussVestings[indexLast].releaseTimes.push(1 seconds);

        for (uint i = 0; i < 24; i++) {
            gaussVestings[indexLast].releaseTimes.push(((30 days) * (i + 1)));
        }
        
        
        /*

        // Creates instance of of the Marketing Funds TokenLock contract.
        ScheduledTokenLock marketingVesting = new ScheduledTokenLock(gaussToken, _senderAddress, marketingWallet, marketingAmount, _marketingTokenAmountsList, _marketingLockTimes);
        
        // Transfers the tokens to the Marketing Funds Marketing Funds, locking the tokens over the specified schedule above.
        marketingVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        marketingLockAddress = marketingVesting.contractAddress();
        
        */
    }
    
    
    /*  Vests the wallet holding the Operations and Developement Funds over a specific time period.
            - Total Operations and Developement tokens are 15,000,000, 6% of total supply.
            
            Release Schedule is as follows:
                Launch, Month 0:        600,000 tokens released
                Month 1 - 24:           600,000 tokens released per Month
    */
    function _lockOpsDevTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory opsDevLock = VestingLock (
            0xF9f41Bd5C7B6CF9a3C6E13846035005331ed940e,
            15000000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(opsDevLock);

        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < 25; i++) {
            gaussVestings[indexLast].releaseAmounts.push(600000);
        }

        // Initializes the time periods that tokens will be released over.
        gaussVestings[indexLast].releaseTimes.push(1 seconds);

        for (uint i = 0; i < 24; i++) {
            gaussVestings[indexLast].releaseTimes.push(((30 days) * (i + 1)));
        }
        
        
        /*

        // Creates instance of of the Operations and Developement Funds TokenLock contract.
        ScheduledTokenLock opsDevVesting = new ScheduledTokenLock(gaussToken, _senderAddress, operationsAndDevelopementWallet, opsDevAmount, _opsDevTokenAmountsList, _opsDevLockTimes);
        
        // Transfers the tokens to the Operations and Developement Funds TokenLock contract, locking the tokens over the specified schedule above.
        opsDevVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable.
        opsDevLockAddress = opsDevVesting.contractAddress();
        
        */
    }
    
    
    /*  Vests the wallet holding the Vesting Incentive Funds over a specific time period.
            - Total Marketing Funds Tokens are 12,500,000, 5% of total supply.
        
            Release Schedule is as follows:
                Launch, Month 0:        500,000 tokens released
                Month 1 - 24:           500,000 tokens released per Month
    */
    function _lockVestingIncentiveTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory incentiveLock = VestingLock (
            0xe3778Db10A5E8b2Bd1B68038F2cEFA835aa46b45,
            12500000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(incentiveLock);

        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < 25; i++) {
            gaussVestings[indexLast].releaseAmounts.push(500000);
        }
       
        // Initializes the time periods that tokens will be released over.
        gaussVestings[indexLast].releaseTimes.push(1 seconds);
        
        for (uint i = 0; i < 24; i++) {
            gaussVestings[indexLast].releaseTimes.push(((30 days) * (i + 1)));

        }
 
    
        /*
        
        // Creates instance of of the Vesting Incentive Funds TokenLock contract.
        ScheduledTokenLock incentiveVesting = new ScheduledTokenLock (
            gaussToken,
            _senderAddress,
            gaussVestings[indexLast].beneficiaryWallet,
            gaussVestings[indexLast].initialAmount,
            gaussVestings[indexLast].releaseAmounts,
            gaussVestings[indexLast].releaseTimes
        );
        vestingContracts.push(reserveVesting.contractAddress());
        
        // Transfers the tokens to the Vesting Incentive Funds TokenLock contract, locking the tokens over the specified schedule above.
        incentiveVesting.lockTokens();
        
        // Sets the address of the deployed contract to a callable variable
        incentiveLockAddress = incentiveVesting.contractAddress();
        
        */
    }
    
    
    /*  Vests the wallet holding the Reserve Pool over a specific time period.
            - Total Reserve Pool Tokens are 28,500,000, 11.4% of total supply.
        
            Release Schedule is as follows:
                Months 0 - 20:      4,750,000 tokens released every 4 Months (Months 0, 4, 8, 12, 16, 20)
    */
    function _lockReserveTokens() internal {
        
        // TODO: Write Comment
        VestingLock memory reserveLock = VestingLock (
            0xf02fD116EEfB47E394721356B36D3350972Cc0c7,
            28500000,
            new uint256[](0),
            new uint256[](0)
        );
        
        gaussVestings.push(reserveLock);
        
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < 6; i++) {
            gaussVestings[indexLast].releaseAmounts.push(4750000);
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < 6; i++) {
            gaussVestings[indexLast].releaseTimes.push(((120 days) * i));
        }
        

        // Creates instance of of the Advisor Funds TokenLock contract and adds the address of the deployed contract to an array of all deployed contracts.
        ScheduledTokenLock reserveVesting = new ScheduledTokenLock (
            gaussToken,
            _senderAddress,
            gaussVestings[indexLast].beneficiaryWallet,
            gaussVestings[indexLast].initialAmount,
            gaussVestings[indexLast].releaseAmounts,
            gaussVestings[indexLast].releaseTimes
        );
        contractAddresses.push(reserveVesting.contractAddress());
        
        // Transfers the tokens to the Advisor Funds TokenLock contract, locking the tokens over the specified schedule above.
        reserveVesting.lockTokens();
    }
}