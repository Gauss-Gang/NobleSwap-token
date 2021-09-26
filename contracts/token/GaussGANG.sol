/*  _____________________________________________________________________________

    Gauss(Gang) Contract

    Deployed to      : TODO
    Name             : Gauss
    Symbol           : GANG
    Total supply     : 250,000,000 (250 Million)
    Transaction Fee  : 12%

    MIT License. (c) 2021 Gauss Gang Inc. 
    
    _____________________________________________________________________________
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;
import "../dependencies/utilities/Initializable.sol";
import "../dependencies/utilities/UUPSUpgradeable.sol";
import "../dependencies/contracts/BEP20.sol";
import "../dependencies/contracts/BEP20Snapshot.sol";



/*  A tokenized ecosystem to serve the evolving needs of any brand. 
    The purpose of the Gauss ecosystem is to support and work with brands to launch utility tokens on 
    our future blockchain and empower them to engage with their audiences in a new, captivating manner.
*/
contract GaussGANG is Initializable, BEP20, BEP20Snapshot, UUPSUpgradeable {
    
    // Creates mapping for the collection of wallet addresses that are held by Gauss.
    mapping (string => address) private _gaussWallets;

    // Creates mapping for the collection of addresses excluded from the Transaction Fee.
    mapping (address => bool) private _excludedFromFee;
    
    // Initializes variables representing the seperate fees that comprise the Transaction Fee.
    uint256 public redistributionFee;
    uint256 public charitableFundFee;
    uint256 public liquidityFee;
    uint256 public ggFee;
    uint256 private _totalFee;


    // Calls te BEP20 Initializer and internal Initializer to create the Gauss GANG token and set required variables.
    function initialize() initializer public {
        __BEP20_init("Gauss", "GANG", 9, (250000000 * (10 ** 9)));
        __BEP20Snapshot_init_unchained();
        __UUPSUpgradeable_init();
        __GaussGANG_init_unchained();
    }


    // Sets initial values to the Transaction Fees and wallets to be excluded from the Transaction Fee.
    function __GaussGANG_init_unchained() internal initializer {
        
        // Sets values for the variables representing the seperate fees that comprise the Transaction Fee.
        redistributionFee = 3;
        charitableFundFee = 3;
        liquidityFee = 3;
        ggFee = 3;
        _totalFee = 12;

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
    
    
    // Creates a Snapshot of the balances and totalsupply of token, returns the Snapshot ID. Can only be called by owner.
    function snapshot() public onlyOwner returns (uint256) {
        uint256 id = _snapshot();
        return id;
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


    // Returns the current total Transaction Fee.
    function totalTransactionFee() public view returns (uint256) {
        return _totalFee;
    }
    
    
    /*  Allows 'owner' to change the transaction fees at a later time, so long as the total Transaction Fee is lower than 12% (the initial fee ceiling).
            -An amount for each Pool is required to be entered, even if the specific fee amount won't be changed.
            -Each variable should be entered as a single or double digit number to represent the intended percentage; 
                Example: Entering a 3 for newRedistributionFee would set the Redistribution fee to 3% of the Transaction Amount.
    */
    function changeTransactionFees(uint256 newRedistributionFee, uint256 newCharitableFundFee, uint256 newLiquidityFee, uint256 newGGFee) public onlyOwner() {

        uint256 newTotalFee;
        newTotalFee = (newRedistributionFee + newCharitableFundFee + newLiquidityFee + newGGFee);

        require(newTotalFee <= 12, "GaussGANG: Transaction fee entered exceeds ceiling of 12%");
        
        redistributionFee = newRedistributionFee;
        charitableFundFee = newCharitableFundFee;
        liquidityFee = newLiquidityFee;
        ggFee = newGGFee;
        _totalFee = newTotalFee;
    }
    
    
    // Internal Transfer function; checks to see if "sender" is excluded from the transaction fee, attempts the transaction without fees if found true.
    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused override(BEP20) {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        _beforeTokenTransfer(sender, recipient, amount);
        
        if (_checkIfExcluded(sender, recipient) == 1) {            
            require(amount <= _balances[sender], "BEP20: transfer amount exceeds balance");

            unchecked {
                _balances[sender] = _balances[sender] - amount;
            }

            _balances[recipient] = _balances[recipient] + amount;
            emit Transfer(sender, recipient, amount);
        }

        else {
            _transferWithFee(sender, recipient, amount);
        }
    }


    /*  Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'.
            -At launch, the transaction fee is set to 12%, but will be lowered over time.
            -The max transaction fee is also 12%, never raising beyond the initial fee set at launch.
            -Fee is evenly split between 4 Pools: 
                    The Redistribution pool,        (Initially, 3%)
                    the Charitable Fund pool,       (Initially, 3%)
                    the Liquidity pool,             (Initially, 3%)
                    and Gauss Gang pool             (Initially, 3%)
    */
    function _transferWithFee(address sender, address recipient, uint256 amount) internal {

        // This section calculates the number of tokens, for the pools that comprise the transaction fee, that get pulled out of "amount" for the transaction fee.
        uint256 redistributionAmount = (amount * redistributionFee) / 100;
        uint256 charitableFundAmount = (amount * charitableFundFee) / 100;
        uint256 liquidityAmount = (amount * liquidityFee) / 100;
        uint256 ggAmount = (amount * ggFee) / 100;
        uint256 finalAmount = amount - (redistributionAmount + charitableFundAmount + liquidityAmount + ggAmount);

        /*  This section performs the balance transfer from "sender" to "recipient".
                - First ensuring the original "amount" is removed from the "sender" and the "finalAmount" ("amount" - transaction fee)
                    is sent to the "recipient".
                - After those transactions are complete, the transaction fee is divided up and sent to the respective pool addresses.
        */
        require(amount <= _balances[sender], "BEP20: transfer amount exceeds balance");
        require(finalAmount < amount, "GaussGANG: finalAmount exceeds original amount");

        unchecked {
            _balances[sender] = _balances[sender] - amount;
        }

        _balances[recipient] = _balances[recipient] + finalAmount;
        _balances[_gaussWallets["Redistribution Fee Wallet"]] = _balances[_gaussWallets["Redistribution Fee Wallet"]] + redistributionAmount;
        _balances[_gaussWallets["Charitable Fee Wallet"]] = _balances[_gaussWallets["Charitable Fee Wallet"]] + charitableFundAmount;
        _balances[_gaussWallets["Liquidity Fee Wallet"]] = _balances[_gaussWallets["Liquidity Fee Wallet"]] + liquidityAmount;
        _balances[_gaussWallets["GG Fee Wallet"]] = _balances[_gaussWallets["GG Fee Wallet"]] + ggAmount;

        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, _gaussWallets["Redistribution Fee Wallet"], redistributionAmount);
        emit Transfer(sender, _gaussWallets["Charitable Fee Wallet"], charitableFundAmount);
        emit Transfer(sender, _gaussWallets["Liquidity Fee Wallet"], liquidityAmount);
        emit Transfer(sender, _gaussWallets["GG Fee Wallet"], ggAmount);
    }


    // Internal function to check if sender or recipient are excluded from the Transaction Fee.
    //      Dev-Note: Boolean cost more gas than uint256; using 0 to represent false, and 1 to represent true.
    function _checkIfExcluded(address sender, address recipient) internal view returns (uint256) {
        if (_excludedFromFee[sender] == true) {
            return 1;
        }

        else if (_excludedFromFee[recipient] == true) {
            return 1;
        }

        else {
            return 0;
        }
    }


    // Internal function; overriden to allow BEPSnapshot to update values before a Transfer event.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(BEP20, BEP20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }


    // Function to allow "owner" to upgarde the contract using a UUPS Proxy
    function _authorizeUpgrade(address newImplementation) internal whenPaused onlyOwner override {}
}