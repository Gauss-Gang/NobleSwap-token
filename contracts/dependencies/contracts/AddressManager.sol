// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "../utilities/Initializable.sol";
import "../utilities/Context.sol";
import "../access/Ownable.sol";
import "../libraries/Address.sol";



/*  Address Manager contract to handle the addresses used in the Gauss(GANG) ecosystem
        - "owner" can add, update, and delete addresses.
        - "owner" can included or exclude addresses from the Transaction Fee.
*/
contract AddressManager is Initializable, Context, Ownable {

    using Address for address;

    // Creates mapping for the collection of wallet addresses that are held by Gauss.
    mapping (string => address) public _gaussWallets;

    // Creates mapping for the collection of addresses excluded from the Transaction Fee.
    mapping (address => bool) public _excludedFromFee;


    // Sets the initial addresses and creates the initial excluded from fee list.
    function __AddressManager_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __AddressManager_init_unchained();
    }
    
    
    // Internal unchained initializer; sets the initial addresses and creates the initial excluded from fee list.
    function __AddressManager_init_unchained() internal initializer {
        
        // Sets the values for each wallet used or held by Gauss(GANG). Also Excludes these wallets from the Transaction Fee.
        _gaussWallets["Redistribution Fee Wallet"] = 0x9C34db8a1467c0F0F152C13Db098d7e0Ca0CE918;
        _gaussWallets["Charitable Fee Wallet"] = 0x765696087d95A84cbFa6FEEE857570A6eae19A14;
        _gaussWallets["Liquidity Fee Wallet"] = 0x3f8c6910124F32aa5546a7103408FA995ab45f65;
        _gaussWallets["GG Fee Wallet"] = 0x206F10F88159590280D46f607af976F6d4d79Ce3;
        _gaussWallets["Internal Distribution Wallet"] = 0xf532651735713E8671FE418124703ab662088C75;
        _gaussWallets["GaussGANG Owner"] = 0x64aCACeA417B39E9e6c92714e30f34763d512140;
        _gaussWallets["Community Pool"] = 0x4249B05E707FeeA3FB034071C66e5A227C230C2f;
        _gaussWallets["Liquidity Pool"] = 0x17cA40C901Af4C31Ed9F5d961b16deD9a4715505;
        _gaussWallets["Charitable Fund"] = 0x7d74E237825Eba9f4B026555f17ecacb2b0d78fE;
        _gaussWallets["Advisor Pool"] = 0x3e3049A80590baF63B6aC8D74F5CbB31584059bB;
        _gaussWallets["Core Team Pool"] = 0x747dDE9cb0b8B86ef1d221077055EE9ec4E70b89;
        _gaussWallets["Marketing Pool"] = 0x46ceE8F5F3e30aF7b62374249907FB97563262f5;
        _gaussWallets["Ops-Dev Pool"] = 0xF9f41Bd5C7B6CF9a3C6E13846035005331ed940e;
        _gaussWallets["Vesting Incentive Pool"] = 0xe3778Db10A5E8b2Bd1B68038F2cEFA835aa46b45;
        _gaussWallets["Reserve Pool"] = 0xf02fD116EEfB47E394721356B36D3350972Cc0c7;

        _excludedFromFee[owner()] = true;
        _excludedFromFee[_gaussWallets["Redistribution Fee Wallet"]] = true;
        _excludedFromFee[_gaussWallets["Charitable Fee Wallet"]] = true;
        _excludedFromFee[_gaussWallets["Liquidity Fee Wallet"]] = true;
        _excludedFromFee[_gaussWallets["GG Fee Wallet"]] = true;
        _excludedFromFee[_gaussWallets["Internal Distribution Wallet"]] = true;
        _excludedFromFee[_gaussWallets["GaussGANG Owner"]] = true;
        _excludedFromFee[_gaussWallets["Community Pool"]] = true;
        _excludedFromFee[_gaussWallets["Liquidity Pool"]] = true;
        _excludedFromFee[_gaussWallets["Charitable Fund"]] = true;
        _excludedFromFee[_gaussWallets["Advisor Pool"]] = true;
        _excludedFromFee[_gaussWallets["Core Team Pool"]] = true;
        _excludedFromFee[_gaussWallets["Marketing Pool"]] = true;
        _excludedFromFee[_gaussWallets["Ops-Dev Pool"]] = true;
        _excludedFromFee[_gaussWallets["Vesting Incentive Pool"]] = true;
        _excludedFromFee[_gaussWallets["Reserve Pool"]] = true;
    }


    // Allows anyone to check the wallet address of the sepcified Wallet Name passed into function
    function checkWalletAddress(string memory walletToCheck) public view returns (address) {
        return _gaussWallets[walletToCheck];
    }


    // Allows 'owner' to change the wallet address for the Wallet Name passed into function.
    function changeWalletAddress(string memory walletToChange, address updatedAddress) public onlyOwner() {

        // Removes old address from the excludedFromFee mapping.
        address oldAddress = _gaussWallets[walletToChange];
        _excludedFromFee[oldAddress] = false;

        // Changes wallet address and then updates the excludedFromFee mapping with the new address.
        _gaussWallets[walletToChange] = updatedAddress;
        _excludedFromFee[updatedAddress] = true;
    }


    // Allows "owner" to add a wallet address to the manager and exclude it from the Transaction Fee.
    function addWalletAddress(string memory walletName, address walletAddress) public onlyOwner() {
        _gaussWallets[walletName] = walletAddress;
        _excludedFromFee[_gaussWallets[walletName]] = true;
    }
}