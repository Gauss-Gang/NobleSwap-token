/*  _____________________________________________________________________________

    Gauss Locked Wallet Manager Contract

    Deployed to      : TODO

    (c) TODO. MIT Licence.
    
    _____________________________________________________________________________
*/

pragma solidity >=0.8.4 <0.9.0;

// SPDX-License-Identifier: GPL-3.0-or-later



// library that creates wrappers over Solidity's arithmetic operations with added overflow protection
library SafeMath {
 
 
    // Returns the addition of two unsigned integers, reverting on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }


    // Returns the subtraction of two unsigned integers, reverting on overflow (when the result is negative).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    

    // Returns the subtraction of two unsigned integers, reverting with custom message on overflow (when the result is negative).  
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    
    
    // Returns the multiplication of two unsigned integers, reverting on overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    

    // Returns the integer division of two unsigned integers. Reverts on division by zero. The result is rounded towards zero.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    // Returns the integer division of two unsigned integers. Reverts with custom message on division by zero. The result is rounded towards zero.
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    

    // Returns the remainder of dividing two unsigned integers. (unsigned integer modulo), Reverts when dividing by zero.
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    // Returns the remainder of dividing two unsigned integers. (unsigned integer modulo), Reverts with custom message when dividing by zero.
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



interface BEP20 {
  uint256 public totalSupply;

  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



abstract contract LockedWallet is Context, Ownable, BEP20 {
    
    using SafeMath for uint256;

    address public creator;
    address public walletOwner;
    uint256 public unlockDate;
    uint256 public createdAt;
    

    function LockWallet(address _creator, address _owner, uint256 _unlockDate) public {
        creator = _creator;
        walletOwner = _owner;
        unlockDate = _unlockDate;
        createdAt = block.timestamp;
    }


    // keep all the ether sent to this address
    receive() external payable { 
        Received(msg.sender, msg.value);
    }


    // callable by owner only, after specified time
    function withdraw() onlyOwner public {
        require(block.timestamp >= unlockDate);
       
       
        //now send all the balance
        msg.sender.transfer(address(this.balance);
        Withdrew(msg.sender, this.balance);
    }


    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawTokens(address _tokenContract) onlyOwner public {
        
        require(now >= unlockDate);
        BEP20 token = BEP20(_tokenContract);
       
       
        //now send all the token balance
        uint256 tokenBalance = token.balanceOf(this);
        token.transfer(owner, tokenBalance);
        WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }


    function info() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate, createdAt, this.balance);
    }
    

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);
}



abstract contract GaussLockedWalletManager is Context, Ownable, BEP20  {
    
    using SafeMath for uint256;
 
    mapping(address => address[]) wallets;

    function getWallets(address _user) public view returns(address[] memory) {
        return wallets[_user];
    }

    function newTimeLockedWallet(address _owner, uint256 _unlockDate) payable public returns(address wallet) {
        
        // Create new wallet.
        wallet = new LockedWallet(msg.sender, _owner, _unlockDate);
        
        // Add wallet to sender's wallets.
        wallets[msg.sender].push(wallet);

        // If owner is the same as sender then add wallet to sender's wallets too.
        if(msg.sender != _owner){
            wallets[_owner].push(wallet);
        }
    
        // TODO: Change if necessary
        // Send ether from this transaction to the created contract.
        wallet.transfer(msg.value);

        // Emit event.
        Created(wallet, msg.sender, _owner, now, _unlockDate, msg.value);
    }

    // Prevents accidental sending of ether to the factory
    fallback() public {
        revert();
    }

    event Created(address wallet, address from, address to, uint256 createdAt, uint256 unlockDate, uint256 amount);
}