// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;



// Collection of functions related to the address type.
library Address {
    
    
    /*  Returns true if `account` is a contract.

            - It is unsafe to assume that an address for which this function returns
                false is an externally-owned account (EOA) and not a contract.
     
            - Among others, `isContract` will return false for the following
                types of addresses:
     
                - an externally-owned account
                - a contract in construction
                - an address where a contract will be created
                - an address where a contract lived, but was destroyed
    */
    function isContract(address account) internal view returns (bool) {
        
        /* According to EIP-1052, 0x0 is the value returned for not-yet created accounts
            and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
            for accounts without code, i.e. `keccak256('')`.
        */
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        // solhint-disable-next-line no-inline-assembly.
        assembly {
            codehash := extcodehash(account)
        }
        
        return (codehash != accountHash && codehash != 0x0);
    }

    
    // TODO: Make comment more concise, look over listed links
    /*  Replacement for Solidity's `transfer`: sends `amount` wei to `recipient`, forwarding all available gas and reverting on errors.

        IMPORTANT: because control is transferred to `recipient`, care must be
            taken to not create reentrancy vulnerabilities. Consider using
            {ReentrancyGuard} or the
            https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
    */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }


    /*  Performs a Solidity function call using a low level `call`. A 'plaincall' is an unsafe replacement for a function call: use this function instead.
            - If `target` reverts with a revert reason, it is bubbled up by this function (like regular Solidity function calls).
            - Returns the raw returned data.
     
        Requirements:
            - `target` must be a contract.
            - calling `target` with `data` must not revert.
    */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }


    //  Same as `functionCall`, but with `errorMessage` as a fallback revert reason when `target` reverts.
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    /*  Same as 'functionCall`, but also transferring `value` wei to `target`.
     
        Requirements:
            - the calling contract must have an BNB balance of at least `value`.
            - the called Solidity function must be `payable`.

    */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }


    // Same as `functionCallWithValue`, but with `errorMessage` as a fallback revert reason when `target` reverts.
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }


    // Internal function called from "functionCallWithValue" above (Same as `functionCallWithValue`, but with `errorMessage` as a fallback revert reason when `target` reverts.)
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        
        if (success) {
            return returndata;
        }
        
        else {
            
            // Look for revert reason and bubble it up if present.
            if (returndata.length > 0) {
                
                // The easiest way to bubble the revert reason is using memory via assembly; solhint-disable-next-line no-inline-assembly.
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } 
            
            else {
                revert(errorMessage);
            }
        }
    }
}