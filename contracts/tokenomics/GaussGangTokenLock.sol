/*  _____________________________________________________________________________

    Gauss(Gang) Token Lock Contract

    Deployed to      : TODO

    MIT Licence. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.4 <0.9.0;


import "../dependencies/contracts/Context.sol";
import "../dependencies/contracts/Ownable.sol";
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/libraries/SafeMath.sol";
import "../dependencies/libraries/Address.sol";


contract GaussGangTokenLock is Context, Ownable {
    
    using SafeMath for uint256;
    using Address for address;


    // BEP20 basic token contract being held
    IBEP20 private immutable _token;

    // Beneficiary of tokens after they are released
    address private immutable _beneficiary;

    // Timestamp when token release is enabled
    uint256 private immutable _releaseTime;


    constructor(IBEP20 token_, address beneficiary_, uint256 releaseTime_) {
        
        require(releaseTime_ > block.timestamp, "GaussGangTokenLock: release time is before current time");
        _token = token_;
        _beneficiary = beneficiary_;
        _releaseTime = releaseTime_;
        
    }


    // Returns the token being held.
    function token() public view virtual returns (IBEP20) {
        return _token;
    }


    // Returns the beneficiary of the tokens.
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }


    // Returns the time when the tokens are released.
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }


    // Transfers tokens held by TimeLock to beneficiary.
    function release() public virtual {
        
        require(block.timestamp >= releaseTime(), "GaussGangTokenLock: current time is before release time");

        uint256 amount = token().balanceOf(address(this));
        require(amount > 0, "GaussGangTokenLock: no tokens to release");

        token().transfer(beneficiary(), amount);
    }
}