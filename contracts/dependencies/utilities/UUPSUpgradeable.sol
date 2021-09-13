// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./BEP20Upgrade.sol";



/*  An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
    {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 
    A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
    reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
    `UUPSUpgradeable` with a custom implementation of upgrades.
 
    NOTE:   The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
*/
abstract contract UUPSUpgradeable is BEP20Upgrade {
    
    /* Upgrade the implementation of the proxy to `newImplementation`.
            - Calls {_authorizeUpgrade}; Emits an {Upgraded} event. */
    function upgradeTo(address newImplementation) external virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, bytes(""), false);
    }


    /* Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`.
            - Calls {_authorizeUpgrade}; Emits an {Upgraded} event.                                                                 */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }
    

    // Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by {upgradeTo} and {upgradeToAndCall}.
    function _authorizeUpgrade(address newImplementation) internal virtual;
}