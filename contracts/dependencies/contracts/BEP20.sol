// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4 <0.9.0;

import "./Context.sol";
import "./Ownable.sol";
import "../interfaces/IBEP20.sol";
import "../libraries/SafeMath.sol";
import "../libraries/Address.sol";



// Implementation of the IBEP20 Interface.
abstract contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }
    
    */



    // Returns the BEP20 token owner.
    function getOwner() external override view returns (address) {
        return owner();
    }


    // Returns the token name.
    function name() public override view returns (string memory) {
        return _name;
    }
    
    
    // Returns the token symbol.
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

 
    // Returns the token decimals.
    function decimals() public override view returns (uint8) {
        return _decimals;
    }


    // Returns the total supply of token
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }


    // Returns balance of the referenced 'account' address
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    
    // Returns the remaining tokens that the 'spender' address can spend on behalf of the 'owner' address through the {transferFrom} function.
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    
    // Atomically increases the allowance granted to `spender` by the caller.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    
    // Atomically decreases the allowance granted to `spender` by the caller.
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero'));
        return true;
    }


    // Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    
    // Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    // Transfers an 'amount' of tokens from the callers account to the referenced 'recipient' address. Emits a {Transfer} event.
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    // Transfers an 'amount' of tokens from the 'sender' address to the 'recipient' address. Emits a {Transfer} event.
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance'));
        return true;
    }
    
    
    // Internal function that moves tokens `amount` from `sender` to `recipient`.
    function _transfer(address sender, address recipient, uint256 amount)internal virtual {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    // TODO: May or may not remove, left as template for now
    // Creates `amount` tokens and assigns them to `msg.sender`, increasing the total supply.
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    
    // TODO: May or may not remove, left as template for now
    // Creates `amount` tokens and assigns them to `account`, increasing the total supply.
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    // TODO: May or may not remove, left as template for now
    // Destroys `amount` tokens from `account`, reducing the total supply.
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    // TODO: May or may not remove, left as template for now
    // Destroys `amount` tokens from `account`.`amount` is then deducted from the caller's allowance.
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance'));
    }
}