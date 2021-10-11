// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;



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