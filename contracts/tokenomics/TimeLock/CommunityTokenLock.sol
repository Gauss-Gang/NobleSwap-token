/*  _____________________________________________________________________________

    Gauss(Gang) Community Token Lock Contract

    Deployed to      : TODO

    MIT License. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.4 <0.9.0;


import "../../dependencies/contracts/Context.sol";
import "../../dependencies/contracts/Ownable.sol";
import "../../dependencies/interfaces/IBEP20.sol";
import "../../dependencies/libraries/SafeMath.sol";
import "../../dependencies/libraries/Address.sol";



// TODO Write in actual wallet addresses
// TODO: Consider writing actual token amounts instead or in addition to for the comment
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
contract CommunityTokenLock is Context, Ownable {
    
    using SafeMath for uint256;
    using Address for address;


    // BEP20 basic token contract being held
    IBEP20 private immutable _token;
    
    // Sender of tokens to be Time Locked
    address private immutable _sender;

    // Beneficiary of tokens after they are released
    address private immutable _beneficiary;

    // Timestamp when token release is enabled
    uint256 private _releaseTime;
    
    // Sets amount to be transfered into Time Lock contract
    uint256 private immutable _amount;
    
    // Incremental Counter to keep track of the Lock Timestamp
    uint private _lockCounter = 0;
    
    // Initializes the amounts to be released over time
    uint256[] private _communityTokenAmountsList = 
        [   25000000,
            14062500,
            11250000,
            14062500,
            11250000,
            11250000,
            6750000,
            6750000,
            6750000,
            5375000
        ];
        
    // Initializes the time periods that tokens will be released over
    uint256[] private _communityLockTimes = 
        [   1 days,
            30 days,
            60 days,
            90 days,
            150 days,
            270 days,
            395 days,
            485 days,
            575 days,
            665 days
        ];
        


    // The constructor sets internal the values of _token, _beneficiary, and _releaseTime to the variables passed in when called externally
    constructor(IBEP20 token_, address sender_, address beneficiary_, uint256 amount_) onlyOwner() {
        
        _token = token_;
        _sender = sender_;
        _beneficiary = beneficiary_;
        _amount = amount_;
        _releaseTime = _communityLockTimes[0];
        
    }


    // Returns the token being held.
    function token() public view virtual returns (IBEP20) {
        return _token;
    }
    

    // Returns the beneficiary of the tokens.
    function sender() public view virtual returns (address) {
        return _sender;
    }
    

    // Returns the beneficiary of the tokens.
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }
    
    
    // Returns the amount being held in the TimeLock contract
    function lockedAmount() public view virtual returns (uint256) {
        return _amount;
    }


    // Returns the time when the tokens are released.
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }
    
    
    // Initializes the transfer of tokens from the "sender" to the the Time Lock contract  
    function lockTokens() public virtual {
        _token.transferFrom(_sender, address(this), _amount);
    }
    
    
    // Transfers tokens held by CommunityTimeLock to beneficiary.
    function release() public virtual {
        
        require(block.timestamp >= releaseTime(), "TokenLock: current time is before release time");
        
        uint256 amount = _communityTokenAmountsList[_lockCounter];
        require(amount > 0, "CommunityTokenLock: no tokens to release");

        token().transfer(beneficiary(), amount);
        
        _lockCounter = _lockCounter + 1;
        _releaseTime = _communityLockTimes[_lockCounter];
    }
}