// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File contracts/dependencies/utilities/Initializable.sol



/*  This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
    behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
    external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
    function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 
    TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
         possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 
    CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
             that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    
    // Indicates that the contract has been initialized.
    bool private _initialized;


    // Indicates that the contract is in the process of being initialized.
    bool private _initializing;


    //Modifier to protect an initializer function from being invoked twice.
    modifier initializer() {
        
        require(_initializing || !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}



// File contracts/dependencies/utilities/Context.sol


// Provides information about the current execution context, including the sender of the transaction and its data.
abstract contract Context is Initializable  {
    
    
    // Empty initializer, to prevent people from mistakenly deploying an instance of this contract, which should be used via inheritance.
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }
    
    // Empty internal initializer.
    function __Context_init_unchained() internal initializer {
    }


    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }
    
    
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    
    uint256[50] private __gap;
}



// File contracts/dependencies/security/Pausable.sol


/* Contract module which allows children to implement an emergency stop mechanism that can be triggered by an authorized account.
        - This module is used through inheritance. 
        - It will make available the modifiers `whenNotPaused` and `whenPaused`, which can be applied to the functions of your contract. 
        - Note that they will not be pausable by simply including this module, only once the modifiers are put in place.              
*/
abstract contract Pausable is Initializable, Context {
    
    // Emitted when the pause is triggered by `account`.
    event Paused(address account);

    // Emitted when the pause is lifted by `account`.
    event Unpaused(address account);

    bool private _paused;


    // Initializes the contract in unpaused state.
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }
    
    
    // Initializes the contract in unpaused state.
    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }


    // Returns true if the contract is paused, and false otherwise.
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    
    // Modifier to make a function callable only when the contract is not paused. (The contract must not be paused)
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }


    // Modifier to make a function callable only when the contract is paused. (The contract must be paused)
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }


    // Triggers stopped state. (The contract must not be paused)
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }


    // Returns to normal state. (The contract must be paused)
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }    
    
    uint256[49] private __gap;
}



// File contracts/dependencies/access/Ownable.sol


// Provides a basic access control mechanism, where an account '_owner' can be granted exclusive access to specific functions by using the modifier `onlyOwner`.
abstract contract Ownable is Initializable, Context {
    
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    // Initializes the contract, setting the deployer as the initial owner.
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    
    // Initializes the contract, setting the deployer as the initial owner.
    function __Ownable_init_unchained() internal initializer {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    

    // Returns the address of the current owner.
    function owner() public view returns (address) {
        return _owner;
    }

    
    // Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    // Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    // Internal function, transfers ownership of the contract to a new account (`newOwner`).
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



// File contracts/dependencies/interfaces/IGTS20.sol


// GTS20 Interface that creates basic functions for a GTS-20 token.
interface IGTS20 {
    
    
    // Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);
    
    
    // Returns the token decimals.
    function decimals() external view returns (uint8);
    
    
    // Returns the token symbol.
    function symbol() external view returns (string memory);
    
    
    // Returns the token name.
    function name() external view returns (string memory);
    
    
    // Returns balance of the referenced 'account' address.
    function balanceOf(address account) external view returns (uint256);


    // Transfers an 'amount' of tokens from the caller's account to the referenced 'recipient' address. Emits a {Transfer} event. 
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    
    // Transfers an 'amount' of tokens from the 'sender' address to the 'recipient' address. Emits a {Transfer} event.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    // Returns the remaining tokens that the 'spender' address can spend on behalf of the 'owner' address through the {transferFrom} function.
    function allowance(address _owner, address spender) external view returns (uint256);
   
    
    // Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
    function approve(address spender, uint256 amount) external returns (bool);

  
    // Emitted when `value` tokens are moved from one account address (`from`) to another (`to`). Note that `value` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);


    // Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



// File contracts/dependencies/libraries/Address.sol


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
        
        // This method relies on extcodesize, which returns 0 for contracts in construction,
        //  since the code is only stored at the end of the constructor execution.
        uint256 size;
        
        assembly {
            size := extcodesize(account)
        }
        
        return size > 0;
    }

    
    // Replacement for Solidity's `transfer`: sends `amount` jager to `recipient`, forwarding all available gas and reverting on errors.
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    /*  Same as 'functionCall`, but also transferring `value` jager to `target`.
     
        Requirements:
            - the calling contract must have an BNB balance of at least `value`.
            - the called Solidity function must be `payable`.

    */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    // Same as `functionCallWithValue`, but with `errorMessage` as a fallback revert reason when `target` reverts.
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {        
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    
    
    // Same as `functionCall`, but performing a static call.
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    // Same as `functionCall` with `errorMessage`, but performing a static call.
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }


    // Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the revert reason using the provided one.
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        
        if (success) {
            return returndata;
        } 
        
        else {
            
            // Look for revert reason and bubble it up if present.
            if (returndata.length > 0) {

                // The easiest way to bubble the revert reason is using memory via assembly.
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



// File contracts/dependencies/contracts/GTS20.sol


// Implementation of the IGTS20 Interface, using Context, Pausable, Ownable, and Snapshot Extenstions.
contract GTS20 is Initializable, Context, IGTS20, Pausable, Ownable {
    
    // Dev-Note: Solidity 0.8.0 added built-in support for checked math, therefore the "SafeMath" library is no longer needed.
    using Address for address;

    // Creates mapping for the collections of balances and allowances.
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Initializes variables for the name, symbol, decimals, and the total Supply of the GTS20 token.
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    
    // Sets the values for {name}, {symbol}, {decimals}, and {totalSupply}.
    function __GTS20_init(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) internal initializer {
        __Context_init_unchained();
        __Ownable_init();
        __Pausable_init();
        __GTS20_init_unchained(name_, symbol_, decimals_, totalSupply_);
    }


    // Internal function to set the values for {name}, {symbol}, {decimals}, and {totalSupply}.
    function __GTS20_init_unchained(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    
    // Allows "owner" to Pause the token transactions, used during maintenance periods or when upgrading token to new version. 
    function pause() public onlyOwner {
        _pause();
    }

    
    // Allows "owner" to Un-Pause the token transactions, used after maintenance periods are finished or once upgrade is complete.
    function unpause() public onlyOwner {
        _unpause();
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


    // Returns the total supply of token.
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }


    // Returns balance of the referenced 'account' address.
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    
    // Returns the remaining tokens that the 'spender' address can spend on behalf of the 'owner' address through the {transferFrom} function.
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    
    // Atomically increases the allowance granted to `spender` by the caller.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));
        return true;
    }
    
    
    // Atomically decreases the allowance granted to `spender` by the caller.
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require((_allowances[_msgSender()][spender] - subtractedValue) >= 0, "GTS20: decreased allowance below zero");
        
        unchecked {
            _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));
        }
        
        return true;
    }


    // Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    
    // Sets 'amount' as the allowance of 'spender' then returns a boolean indicating result of operation. Emits an {Approval} event.
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'GTS20: approve from the zero address');
        require(spender != address(0), 'GTS20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    // Transfers an 'amount' of tokens from the callers account to the referenced 'recipient' address. Emits a {Transfer} event.
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    // Transfers an 'amount' of tokens from the 'sender' address to the 'recipient' address. Emits a {Transfer} event.
    function transferFrom(address sender, address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        
        require(amount <= _allowances[sender][_msgSender()], "GTS20: transfer amount exceeds allowance");
        
        unchecked {
            _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));
        }
        
        return true;
    }
    
    
    // Internal function that moves tokens `amount` from `sender` to `recipient`.
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), 'GTS20: transfer from the zero address');
        require(recipient != address(0), 'GTS20: transfer to the zero address');
        
        _beforeTokenTransfer(sender, recipient, amount);
        
        require(amount <= _balances[sender], "GTS20: transfer amount exceeds balance");
        
        unchecked {
            _balances[sender] = _balances[sender] - amount;
        }
        
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(sender, recipient, amount);
    }
    
    
    /*  Hook that is called before any transfer of tokens. This includes minting and burning.
     
        Calling conditions:
            - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens will be transferred to `to`.
            - when `from` is zero, `amount` tokens will be minted for `to`.
            - when `to` is zero, `amount` of ``from``'s tokens will be burned.
            - `from` and `to` are never both zero.
    */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}


    /*  Hook that is called after any transfer of tokens. This includes minting and burning.
     
        Calling conditions:
            - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens has been transferred to `to`.
            - when `from` is zero, `amount` tokens have been minted for `to`.
            - when `to` is zero, `amount` of ``from``'s tokens have been burned.
            - `from` and `to` are never both zero.
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    
    uint256[45] private __gap;
}



// File contracts/dependencies/interfaces/IBeacon.sol


// This is the interface that {BeaconProxy} expects of its beacon.
interface IBeacon {
    
    //Must return an address that can be used as a delegate call target. {BeaconProxy} will check that this address is a contract.
    function implementation() external view returns (address);
}



// File contracts/dependencies/libraries/StorageSlot.sol


/*  Library for reading and writing primitive types to specific storage slots.
 
    Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
    This library helps with reading and writing to such slots without the need for inline assembly.
 
    The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
    
    (Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`.)
*/
library StorageSlot {
    
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }


    //Returns an `AddressSlot` with member `value` located at `slot`.
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }


    // Returns an `BooleanSlot` with member `value` located at `slot`.
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }


    // Returns an `Bytes32Slot` with member `value` located at `slot`.
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }


    // Returns an `Uint256Slot` with member `value` located at `slot`.
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}



// File contracts/dependencies/utilities/GTS20Upgrade.sol


//  This abstract contract provides getters and event emitting update functions for slots.
abstract contract GTS20Upgrade is Initializable {

    function __GTS20Upgrade_init() internal initializer {
        __GTS20Upgrade_init_unchained();
    }

    function __GTS20Upgrade_init_unchained() internal initializer {
    }
    
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1.
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;
    
    // Storage slot with the address of the current implementation. 
    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is validated in the constructor.
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // Emitted when the implementation is upgraded.
    event Upgraded(address indexed implementation);


    // Returns the current implementation address.
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }


    // Stores a new address in the EIP1967 implementation slot.
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    
    // Perform implementation upgrade. Emits an {Upgraded} event.
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }


    // Perform implementation upgrade with additional setup call. Emits an {Upgraded} event.
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }


    // Perform implementation upgrade with security checks for UUPS proxies, and additional setup call. Emits an {Upgraded} event.
    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call.
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress.
        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            
            // Trigger rollback using upgradeTo from the new implementation.
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            
            // Check rollback was effective.
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            
            // Finally reset to the new implementation and log the upgrade.
            _upgradeTo(newImplementation);
        }
    }
    

    // Storage slot with the admin of the contract. 
    // This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is validated in the constructor.
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;


    // Emitted when the admin account has changed.
    event AdminChanged(address previousAdmin, address newAdmin);


    // Returns the current admin.
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }


    // Stores a new address in the EIP1967 admin slot.
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }


    // Changes the admin of the proxy. Emits an {AdminChanged} event.
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }


    // The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
    // This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;


    // Emitted when the beacon is upgraded.
    event BeaconUpgraded(address indexed beacon);


    // Returns the current beacon.
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }


    // Stores a new beacon in the EIP1967 beacon slot.
    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(Address.isContract(IBeacon(newBeacon).implementation()),"ERC1967: beacon implementation is not a contract");
        
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }


    /*  Perform beacon upgrade with additional setup call. Emits a {BeaconUpgraded} event.
        
        Note: This upgrades the address of the beacon, it does not upgrade the implementation contained in the beacon.
                (see {UpgradeableBeacon-_setImplementation} for that).                                              */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }


    // Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`], but performing a delegate call.
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(Address.isContract(target), "Address: delegate call to non-contract");

        /// @custom:oz-upgrades-unsafe-allow delegatecall
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return Address.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}



// File contracts/dependencies/utilities/UUPSUpgradeable.sol


/*  An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
    {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 
    A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
    reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
    `UUPSUpgradeable` with a custom implementation of upgrades.
 
    NOTE:   The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
*/
abstract contract UUPSUpgradeable is Initializable, GTS20Upgrade {

    function __UUPSUpgradeable_init() internal initializer {
        __GTS20Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }
    

    function __UUPSUpgradeable_init_unchained() internal initializer {}


    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);    

    /*  Check that the execution is being performed through a delegatecall call and that the execution context is
        a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
        for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
        function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to fail.
    */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    
    /* Upgrade the implementation of the proxy to `newImplementation`.
            - Calls {_authorizeUpgrade}; Emits an {Upgraded} event. */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }


    /*  Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`.
            - Calls {_authorizeUpgrade}; Emits an {Upgraded} event.                                                                 */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }
    

    // Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by {upgradeTo} and {upgradeToAndCall}.
    function _authorizeUpgrade(address newImplementation) internal virtual;
}



// File contracts/dependencies/libraries/Counters.sol


/*  Provides counters that can only be incremented, decremented, or reset.
        - Example uses: to track the number of elements in a mapping, issuing ERC721 ids, or counting request ids.
        - Include with 'using Counters for Counters.Counter;'                                                    
*/
library Counters {
    
    struct Counter {
        
        /* This variable should never be directly accessed by users of the library: 
            - interactions must be restricted to the library's function.
            - As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add this feature.
        */
        uint256 _value; // default: 0
    }
    
    
    // Returns value held in counter.
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    
    
    // Increments counter by 1.
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    
    
    // Decrements (decreases) counter by 1.
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    
    
    // Resets Counter to a null value of 0.
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}



// File contracts/dependencies/libraries/Math.sol


// Standard math utilities missing in the Solidity language.
library Math {

    // Returns the largest of two numbers.
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }


    // Returns the smallest of two numbers.
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }


    // Returns the average of two numbers. The result is rounded towards zero.
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }


    // Returns the ceiling of the division of two numbers. This differs from standard division with `/` in that it rounds up instead of rounding down.
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}



// File contracts/dependencies/libraries/Arrays.sol


// Collection of functions related to array types.
library Arrays {

    /* Searches a sorted `array` and returns the first index that contains a value greater or equal to `element`. 
        - If no such index exists (i.e. all values in the array are strictly less than `element`), the array length is returned. 
        - Time complexity O(log n).
        
        Requirements: `array` is expected to be sorted in ascending order, and to contain no repeated elements.
    */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index) because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            }
            
            else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } 
        
        else {
            return low;
        }
    }
}



// File contracts/dependencies/contracts/GTS20Snapshot.sol


/*  This contract extends an GTS20 token with a snapshot mechanism. When a snapshot is created, the balances and total supply at the time are recorded for later access.
        
        - Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
            snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
            id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
            and the account address.
*/
abstract contract GTS20Snapshot is GTS20 {

    using Arrays for uint256[];
    using Counters for Counters.Counter;    

    /* Snapshotted values have arrays of ids and the value corresponding to that id. 
        - These could be an array of a Snapshot struct, but that would impede usage of functions that work on an array. */
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }
    
    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;
    
    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;
    
    // Emitted by {_snapshot} when a snapshot identified by `id` is created.
    event Snapshot(uint256 id);
    

    // Initializes GTS20Snapshot contract
    function __GTS20Snapshot_init() internal initializer {
        __Context_init_unchained();
        __GTS20Snapshot_init_unchained();
    }
    
    
    // Initializes GTS20Snapshot contract
    function __GTS20Snapshot_init_unchained() internal initializer {}


    // Creates a new snapshot and returns its snapshot id. Emits a {Snapshot} event that contains the same id.
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }


    // Get the current snapshotId.
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }


    // Retrieves the balance of `account` at the time `snapshotId` was created.
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }


    // Retrieves the total supply at the time `snapshotId` was created.
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }


    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // burn
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }
    
    
    // Returns the value held in the snapshot using the id as an identifier.
    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "GTS20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "GTS20Snapshot: nonexistent id");

        /*  When a valid snapshot is queried, there are three possibilities:
                a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never created for this id,
                    and all stored snapshot ids are smaller than the requested one. The value that corresponds to this id is the current one.
                
                b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
                    requested id, and its value is the one to return.
        
                c) More snapshots were created after the requested one, and the queried value was later modified. There will be no entry for the requested id:
                        - the value that corresponds to it is that of the smallest snapshot id that is larger than the requested one.
            
            In summary, we need to find an element in an array, returning the index of the smallest value that is larger if it is not found,
              unless said value doesn't exist (e.g. when all values are smaller).
                    - Arrays.findUpperBound does exactly this. */
        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } 
        
        else {
            return (true, snapshots.values[index]);
        }
    }
    
    
    // Internal function, updates the balance of passed "account" before values are modified.
    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }


    // Internal function, updates the "totalSupply" of token before values are modified.
    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    
    // Internal function, updates snapshot with either the new balances, or new totalSupply.
    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }
    
    
    // Returns the last snapshot id.
    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } 
        
        else {
            return ids[ids.length - 1];
        }
    }
    
    uint256[46] private __gap;
}



// File contracts/token/NobleSwap.sol

/*  _____________________________________________________________________________

    NobleSwap (NOBLE) Token Contract

    Name             : NobleSwap
    Symbol           : NOBLE
    Total supply     : 2,500,000,000 (2.5 Billion)

    MIT License. (c) 2022 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


/*  Noble Swap Token (NOBLE)
*/
contract NobleSwap is Initializable, GTS20, GTS20Snapshot, UUPSUpgradeable {

    // A record of the Delegates for each account.
    mapping (address => address) internal _delegates;

    // A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    // The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    // A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    // A checkpoint for marking number of votes from a given block.
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    // The EIP-712 typehash for the contract's domain
    bytes32 public DOMAIN_TYPEHASH;

    // The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public DELEGATION_TYPEHASH;

    // An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    // An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    // Calls the GTS20 Initializer and internal Initializer to create th NobleSwap token and set required variables.
    function initialize() initializer public {
        __GTS20_init("NobleSwap", "NOBLE", 18, (2500000000 * (10 ** 18)));
        __GTS20Snapshot_init_unchained();
        __UUPSUpgradeable_init();
        __NobleSwap_init_unchained();
    }


    // NobleSwap Initializer, sets state variables for the governance functionality.
    function __NobleSwap_init_unchained() internal initializer {
        DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
        DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    }


    // Creates a Snapshot of the balances and totalsupply of token, returns the Snapshot ID. Can only be called by owner.
    function snapshot() public onlyOwner returns (uint256) {
        uint256 id = _snapshot();
        return id;
    }

    
    // Returns the current "votes" balance for `account`
    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }


    /*  Determines the prior number of votes for an 'account' per the given 'blockNnumber'.
            NOTE: Block number must be a finalized block or else this function will revert to prevent misinformation.
    */
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256) {
        
        require(blockNumber < block.number, "NOBLE: getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        
        while (upper > lower) {            
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } 
            else if (cp.fromBlock < blockNumber) {
                lower = center;
            } 
            else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }


    // Delegate votes from `msg.sender` to `delegator`.
    function delegates(address delegator) external view returns (address) {
        return _delegates[delegator];
    }


    // Delegate votes from `msg.sender` to `delegatee`.
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }


    /* Delegates votes from signatory to `delegatee`.
            Parameters:
                delegatee - The address to delegate votes to.
                nonce - The contract state required to match the signature.
                expiry - The time at which to expire the signature.
                v - The recovery byte of the signature.
                r - Half of the ECDSA signature pair.
                s - Half of the ECDSA signature pair.
    */
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "NOBLE: delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "NOBLE: delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "NOBLE: delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }


    // Internal function to change the Delagate.
    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying NOBLE (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }


    // Internal function to move delegate votes from one Representative to another.
    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld - amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld + amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }


    // Internal funtion to write the current delegate votes to the checkpoint struct.
    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {
       
        uint32 blockNumber = _safe32(block.number, "NOBLE: _writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }


    // Internal check to ensure entered Block Number is less than or equal the max 32 integer amount (2,147,483,647).
    function _safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }


    // Returns the current ChainID for the chain this contract is deployed to.
    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }


    // Internal function; overriden to allow GTS20Snapshot to update values before a Transfer event.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(GTS20, GTS20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }


    // Function to allow "owner" to upgarde the contract using a UUPS Proxy.
    function _authorizeUpgrade(address newImplementation) internal whenPaused onlyOwner override {}
}
