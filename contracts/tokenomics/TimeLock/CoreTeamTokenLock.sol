/*  _____________________________________________________________________________

    Gauss(Gang) Core Team Token Lock Contract

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


contract CoreTeamTokenLock is Context, Ownable {
    
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
    uint256[] private _coreTeamTokenAmountsList = 
        [   6250000,
            6250000,
            6250000,
            6250000
        ];
        
    // Initializes the time periods that tokens will be released over
    uint256[] private _coreTeamLockTimes = 
        [   150 days,
            300 days,
            455 days,
            605 days
        ];
        


    // The constructor sets internal the values of _token, _beneficiary, and _releaseTime to the variables passed in when called externally
    constructor(IBEP20 token_, address sender_, address beneficiary_, uint256 amount_) onlyOwner() {
        
        _token = token_;
        _sender = sender_;
        _beneficiary = beneficiary_;
        _amount = amount_;
        _releaseTime = _coreTeamLockTimes[0];
        
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
        
        uint256 amount = _coreTeamTokenAmountsList[_lockCounter];
        require(amount > 0, "CommunityTokenLock: no tokens to release");

        token().transfer(beneficiary(), amount);
        
        _lockCounter = _lockCounter + 1;
        _releaseTime = _coreTeamLockTimes[_lockCounter];
    }
}