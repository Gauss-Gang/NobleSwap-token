// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;



// Provides information about the current execution context, including the sender of the transaction and its data.
abstract contract Context {
    
    
    // Empty internal constructor, to prevent people from mistakenly deploying an instance of this contract, which should be used via inheritance.
    constructor () { }


    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }
    
    
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}