// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;



// BEP20 Interface that creates basic functions for a BEP20 token. The Gauss(Gang) Contract inherits it's core functions from this interface.
interface IBEP20 {
    
    
    // Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);
    
    
    // Returns the token decimals.
    function decimals() external view returns (uint8);
    
    
    // Returns the token symbol.
    function symbol() external view returns (string memory);
    
    
    // Returns the token name.
    function name() external view returns (string memory);
    
    
    // Returns the BEP20 token owner.
    function getOwner() external view returns (address);
    
    
    // Returns balance of the referenced 'account' address
    function balanceOf(address account) external view returns (uint256);


    // Transfers an 'amount' of tokens from callers account to the referenced 'recipient' address. Emits a {Transfer} event. 
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    
    // Transfers an 'amount' of tokens from the 'sender' address to the 'recipient' address. Emits a {Transfer} event.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    // Returns the remaining tokens that the 'spender' address can spend on behalf of the 'owner' address through the {transferFrom} function.
    function allowance(address _owner, address spender) external view returns (uint256);
   
    
    /* Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
        -TODO: Consider use of the aforementioned solution ->
        IMPORTANT: Beware that changing an allowance with this method brings the risk
        that someone may use both the old and the new allowance by unfortunate
        transaction ordering. One possible solution to mitigate this race
        condition is to first reduce the spender's allowance to 0 and set the
        desired value afterwards:
        https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729  */
    function approve(address spender, uint256 amount) external returns (bool);

  
    // Emitted when `value` tokens are moved from one account address (`from`) to another (`to`). Note that `value` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);


    // Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}