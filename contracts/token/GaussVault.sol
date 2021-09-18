/*  _____________________________________________________________________________

    Gauss(Gang) Initial Token Distribution Contract

    Deployed to      : TODO

    MIT License. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "../dependencies/utilities/Initializable.sol";
import "../dependencies/utilities/Context.sol";
import "../dependencies/access/Ownable.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/libraries/Address.sol";
import "../dependencies/contracts/TokenLock.sol";
import "../dependencies/contracts/ScheduledTokenLock.sol";



// TODO: Write Comment
contract GaussVault is Initializable, Context, Ownable {
    
    // Dev-Note: Solidity 0.8.0 added built-in support for checked math, therefore the "SafeMath" library is no longer needed.
    using Address for address;
    
    // Initializes an event that will be called after each VestingLock contract is deployed
    event VestingCreated(address beneficiary, address lockAddress, uint256 initialAmount);
       
    // Initializes two arrays that will hold the deployed contracts of both Simple and Scheduled Time Locks.
    TokenLock[] private _simpleVestingContracts;
    ScheduledTokenLock[] private _scheduledVestingContracts;
    
    // Creates variables to hold the address of "sender" of the tokens to be transferred, as well as the address that the Gauss(GANG) is deployed to.
    address private _senderAddress;
    IBEP20  private _gaussToken;
    

    /*  The constructor sets internal the values of _gaussAddress, and _senderAddress to the variables passed in when called externally
          as well as calling the internal functions that create a Vesting Lock contract for each Pool of tokens.                     */
    function initialize(address gaussOwner, address gaussGANGAddress) initializer public {
        __Ownable_init();       
        __GaussVault_init_unchained(gaussOwner, gaussGANGAddress);        
    }


    // Sets initial values to the Transaction Fees and wallets to be excluded from the Transaction Fee.
    function __GaussVault_init_unchained(address gaussOwner, address gaussGANGAddress) internal initializer {
        require(msg.sender == gaussOwner);
        
        _senderAddress = msg.sender;
        _gaussToken = IBEP20(gaussGANGAddress);
        
        _lockCommunityTokens();
        _lockLiquidityTokens();
        _lockCharitableFundTokens();
        _lockAdvisorTokens();
        _lockCoreTeamTokens();
        _lockMarketingTokens();
        _lockOpsDevTokens();
        _lockVestingIncentiveTokens();
        _lockReserveTokens();
    }
    
    
    // Returns the beneficiary wallet address of each Vesting Lock, can be called by anyone.
    function beneficiaryVestingAddresses() public view returns (address[] memory) {

        uint256 numberOfAddresses = (_simpleVestingContracts.length + _scheduledVestingContracts.length);        
        address[] memory beneficiaryWallets = new address[](numberOfAddresses);
        
        for (uint i = 0; i < numberOfAddresses; i++) {
            if (i < _simpleVestingContracts.length) {
                beneficiaryWallets[i] = _simpleVestingContracts[i].beneficiary();
            }
            else {
                beneficiaryWallets[i] = _scheduledVestingContracts[i].beneficiary();
            }
        }
        
        return beneficiaryWallets; 
    }
    
    
    // Returns the addresses of each Vesting Contract deployed, can be called by anyone.
    function vestingContractAddresses() public view returns (address[] memory) {

        uint256 numberOfAddresses = (_simpleVestingContracts.length + _scheduledVestingContracts.length);        
        address[] memory contractAddresses = new address[](numberOfAddresses);
        
        for (uint i = 0; i < numberOfAddresses; i++) {
            if (i < _simpleVestingContracts.length) {
                contractAddresses[i] = _simpleVestingContracts[i].contractAddress();
            }
            else {
                contractAddresses[i] = _scheduledVestingContracts[i].contractAddress();
            }
        }
        
        return contractAddresses; 
    }


    // TODO: Rewrite comment
    // Attempts to release every wallet, ultimately releasing the available amount per Token Lock Contract, and starts a new release time period per contract that releases funds.
    //      - Returns addresses of every wallet that received tokens
    function releaseAvailableTokens() public onlyOwner() returns (address[] memory) {

        uint256 numberOfAddresses = (_simpleVestingContracts.length + _scheduledVestingContracts.length);
        address[] memory contractAddresses = new address[](numberOfAddresses);

        for (uint i = 0; i < numberOfAddresses; i++) {
            if (i < _simpleVestingContracts.length) {
                if ((_simpleVestingContracts[i].release()) == true) {
                    contractAddresses[i] = _simpleVestingContracts[i].contractAddress();
                }
            }
            else {
                if ((_scheduledVestingContracts[i].release()) == true) {
                    contractAddresses[i] = _scheduledVestingContracts[i].contractAddress();
                }
            }
        }

        return contractAddresses;
    }
    
    
    // Vests the specified wallet address for the given time, Function can only be called by "owner". Returns the address it is deployed to. 
    function vestTokens(address sender, address beneficiary, uint256 amount, uint256 releaseTime) public onlyOwner() returns (address) {
        
        // Creates an instance of a TokenLock contract.
        TokenLock newVestedLock = new TokenLock(_gaussToken, sender, beneficiary, amount, releaseTime);
        
        // Transfers the tokens to the tokens to the TokenLock contract, locking the tokens over the specified schedule for each pool.
        // Also adds the deployed contract to an array of all deployed Simple Token Lock contracts.
        newVestedLock.lockTokens();
        _simpleVestingContracts.push(newVestedLock);

        emit VestingCreated(beneficiary, newVestedLock.contractAddress(), amount);
        return newVestedLock.contractAddress();
    }
    
    
    // Vests the specified wallet address for the given time, Function can only be called by "owner". Returns the address it is deployed to. 
    function scheduledVesting(address sender, address beneficiary, uint256 amount, uint256[] memory amountsList, uint256[] memory lockTimes) public onlyOwner() returns (address) {
        
        require(amountsList.length == lockTimes.length, "scheduledVesting(): amountsList and lockTimes do not containt the same number of items");
               
        // Creates an instance of a ScheduledTokenLock contract.
        ScheduledTokenLock newScheduledLock = new ScheduledTokenLock (
            _gaussToken,
            sender,
            beneficiary,
            amount,
            amountsList,
            lockTimes
        );
        
        // Transfers the tokens to the tokens to the TokenLock contract, locking the tokens over the specified schedule for each pool.
        // Also adds the address of the deployed contract to an array of all deployed Scheduled Token Lock contracts.
        newScheduledLock.lockTokens();
        _scheduledVestingContracts.push(newScheduledLock);

        emit VestingCreated(beneficiary, newScheduledLock.contractAddress(), amount);
        return newScheduledLock.contractAddress();
    }


    // TODO: Check math in both for loops
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

        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0x4249B05E707FeeA3FB034071C66e5A227C230C2f;
        uint256 initialAmount = 112500000;
        uint256 indexNum = 25;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            if (i == 0) {
                releaseAmounts[i] = 25000000;
            }
            else if (i > 0 && i <= 6){
                releaseAmounts[i] = 1250000;
            }
            else if (i > 6 && i <= 23) {
                releaseAmounts[i] = 4444444;
            }
            else {
                releaseAmounts[i] = 4444452;
            }
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            if (i == 0) {
                releaseTimes[i] = (1 seconds);
            }
            releaseTimes[i] = ((30 days) * (i + 1));
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    

    /*  Vests the wallet holding the Liquidity Pool funds over a specific time period.
            - Total Liquidity Pool Tokens are 20,000,000, 8% of total supply.
        
            Release Schedule is as follows:
                Month 4:    10,000,000 tokens released
                Month 8:    10,000,000 tokens released
    */
    function _lockLiquidityTokens() internal {

        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0x17cA40C901Af4C31Ed9F5d961b16deD9a4715505;
        uint256 initialAmount = 20000000;
        uint256 indexNum = 2;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        releaseAmounts[0] = 10000000;
        releaseAmounts[1] = 10000000;
 
        // Initializes the time periods that tokens will be released over.
        releaseTimes[0] = (120 days);
        releaseTimes[1] = (240 days);

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    
    
    // TODO: Completely redo for loops, add starting cliff
    /*  Vests the wallet holding the Charitable Fund over a specific time period.
            - Total Charitable Fund Tokens are 15,000,000, 6% of total supply.
        
            Release Schedule is as follows:
                Launch, Month 0:        1,111,111 tokens released (Used to create redistribution expirement)
                Month 6 - 23:           771,605 tokens released per Month
                Month 24:               771,604 tokens released
    */
    function _lockCharitableFundTokens() internal {
        
        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0x7d74E237825Eba9f4B026555f17ecacb2b0d78fE;
        uint256 initialAmount = 15000000;
        uint256 indexNum = 20;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.    // TODO: Completely redo for loop, add starting cliff
        for (uint i = 0; i < indexNum; i++) {
            if (i == 0) {
                releaseAmounts[i] = 1111111;
            }
            else if (i > 0 && i < 19){
                releaseAmounts[i] = 771605;
            }
            else {
                releaseAmounts[i] = 771604;
            }
        }
 
        // Initializes the time periods that tokens will be released over.  // TODO: Completely redo for loop, add starting cliff
        for (uint i = 0; i < indexNum; i++) {
            releaseTimes[i] = ((30 days) * (i + 1));
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    
    
    // TODO: Check math for release schedule
    /*  Vests the wallet holding the Advisor Pool over a specific time period.
            - Total Advisor Pool Tokens are 6,500,000, 2.6% of total supply.
        
            Release Schedule is as follows:
                Months 1 - 18:          325,000 tokens released per Month
                Months 19 - 24:         162,500 tokens released per Month
    */
    function _lockAdvisorTokens() internal {
        
        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0x3e3049A80590baF63B6aC8D74F5CbB31584059bB;
        uint256 initialAmount = 6500000;
        uint256 indexNum = 24;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            if (i < 18) {
                releaseAmounts[i] = 325000;
            }
            else {
                releaseAmounts[i] = 162500;
            }
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            releaseTimes[i] = ((30 days) * (i + 1));
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
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

        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0x747dDE9cb0b8B86ef1d221077055EE9ec4E70b89;
        uint256 initialAmount = 25000000;
        uint256 indexNum = 4;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            releaseAmounts[i] = 6250000;
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            releaseTimes[i] = ((150 days) + (i * 150 days));
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    
    
    /*  Vests the wallet holding the Marketing Funds over a specific time period.
            - Total Marketing Funds Tokens are 15,000,000, 6% of total supply.
        
            Release Schedule is as follows:
                Launch, Month 0:        600,000 tokens released
                Month 1 - 24:           600,000 tokens released per Month
    */
    function _lockMarketingTokens() internal {

        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0x46ceE8F5F3e30aF7b62374249907FB97563262f5;
        uint256 initialAmount = 15000000;
        uint256 indexNum = 25;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            releaseAmounts[i] = 600000;
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            if (i == 0) {
                releaseTimes[i] = (1 seconds);   
            }
            else {
                releaseTimes[i] = ((30 days) * i);
            }
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    
    
    /*  Vests the wallet holding the Operations and Developement Funds over a specific time period.
            - Total Operations and Developement tokens are 15,000,000, 6% of total supply.
            
            Release Schedule is as follows:
                Launch, Month 0:        600,000 tokens released
                Month 1 - 24:           600,000 tokens released per Month
    */
    function _lockOpsDevTokens() internal {

        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0xF9f41Bd5C7B6CF9a3C6E13846035005331ed940e;
        uint256 initialAmount = 15000000;
        uint256 indexNum = 25;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            releaseAmounts[i] = 600000;
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            if (i == 0) {
                releaseTimes[i] = (1 seconds);   
            }
            else {
                releaseTimes[i] = ((30 days) * i);
            }
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    
    
    /*  Vests the wallet holding the Vesting Incentive Funds over a specific time period.
            - Total Marketing Funds Tokens are 12,500,000, 5% of total supply.
        
            Release Schedule is as follows:
                Launch, Month 0:        500,000 tokens released
                Month 1 - 24:           500,000 tokens released per Month
    */
    function _lockVestingIncentiveTokens() internal {

        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0xe3778Db10A5E8b2Bd1B68038F2cEFA835aa46b45;
        uint256 initialAmount = 12500000;
        uint256 indexNum = 25;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            releaseAmounts[i] = 500000;
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            if (i == 0) {
                releaseTimes[i] = (1 seconds);   
            }
            else {
                releaseTimes[i] = ((30 days) * i);
            }
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
    
    
    /*  Vests the wallet holding the Reserve Pool over a specific time period.
            - Total Reserve Pool Tokens are 28,500,000, 11.4% of total supply.
        
            Release Schedule is as follows:
                Months 0 - 20:      4,750,000 tokens released every 4 Months (Months 0, 4, 8, 12, 16, 20)
    */
    function _lockReserveTokens() internal {
        
        // Initializes the variables required for the ScheduledTokenLock contract.
        address beneficiaryWallet = 0xf02fD116EEfB47E394721356B36D3350972Cc0c7;
        uint256 initialAmount = 28500000;
        uint256 indexNum = 6;
        uint256[] memory releaseAmounts = new uint256[](indexNum);
        uint256[] memory releaseTimes = new uint256[](indexNum);
        
        // Initializes the amounts to be released over time.
        for (uint i = 0; i < indexNum; i++) {
            releaseAmounts[i] = 4750000;
        }
 
        // Initializes the time periods that tokens will be released over.
        for (uint i = 0; i < indexNum; i++) {
            releaseTimes[i] = ((120 days) * i);
        }        

        // Deploys a SceduledTokenLock contract amd transfers the tokens to said contract to be released over the above schedule
        scheduledVesting(_senderAddress, beneficiaryWallet, initialAmount, releaseAmounts, releaseTimes);
    }
}