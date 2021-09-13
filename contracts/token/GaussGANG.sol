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

pragma solidity >=0.8.4 <0.9.0;
import "../dependencies/utilities/Initializable.sol";
import "../dependencies/utilities/UUPSUpgradeable.sol";
import "../dependencies/contracts/BEP20.sol";
import "../dependencies/contracts/BEP20Snapshot.sol";



// TODO: Consider use of Gauss Gang as contract name
// TODO: Create Comment (Possibly Use introduction from Litepaper, or iteration thereof)
contract GaussGANG is Initializable, BEP20, BEP20Snapshot, UUPSUpgradeable {
    
    // Creates mapping for the collection of addresses excluded from the Transaction Fee.
    mapping (address => bool) private _excludedFromFee;
    
    // TODO: Consider changing variable, without the word Fee?
    // Initializes variables representing the seperate fees that comprise the Transaction Fee.
    uint256 public redistributionFee = 3;
    uint256 public charitableFundFee = 3;
    uint256 public liquidityFee = 3;
    uint256 public ggFee = 3;
    uint256 private _totalFee = 12;
    
    // Initializes variables representing the seperate wallets that receive the Transaction Fee.
    address public redistributionWallet = (0x9C34db8a1467c0F0F152C13Db098d7e0Ca0CE918);
    address public charitableFundWallet = (0x765696087d95A84cbFa6FEEE857570A6eae19A14);
    address public liquidityWallet = (0x3f8c6910124F32aa5546a7103408FA995ab45f65);
    address public ggWallet = (0x206F10F88159590280D46f607af976F6d4d79Ce3);
    
    
    // Calls te BEP20 Initializer to create the Gauss GANG token and set required variables.
   function initialize() initializer public {
       __BEP20_init("Gauss", "GANG", 9, (250000000 * (10 ** 9)));
       __BEP20Snapshot_init_unchained();
       __UUPSUpgradeable_init();
        
        // TODO: Add more exclusions if needed; Possibly reword comment
        // Excludes the wallets that compose the Transaction Fee from the Fee itself.
        _excludedFromFee[owner()] = true;
        _excludedFromFee[redistributionWallet] = true;
        _excludedFromFee[charitableFundWallet] = true;
        _excludedFromFee[liquidityWallet] = true;
        _excludedFromFee[ggWallet] = true;
    }
    
    
    // Creates a Snapshot of the balances and totalsupply of token, returns the Snapshot ID. Can only be called by owner.
    function snapshot() public onlyOwner returns (uint256) {
        uint256 id = _snapshot();
        return id;
    }
    
    
    // Returns the current total Transaction Fee.
    function totalTransactionFee() public view returns (uint256) {
        return _totalFee;
    }
    

    // Allows 'owner' to change the wallet address for the Redistribution Wallet.
    function changeRedistributionWallet(address newRedistributionAddress) public onlyOwner() {
        
        // Removes old address from the excludedFromFee mapping, then updates the mapping with the new address.
        _excludedFromFee[redistributionWallet] = false;
        redistributionWallet = newRedistributionAddress;
        _excludedFromFee[redistributionWallet] = true;
    }
    
    
    // Allows 'owner' to change the wallet address for the Charitable Fund Wallet.
    function changeCharitableWallet(address newCharitableAddress) public onlyOwner() {
        
        // Removes old address from the excludedFromFee mapping, then updates the mapping with the new address.
        _excludedFromFee[charitableFundWallet] = false;
        charitableFundWallet = newCharitableAddress;
        _excludedFromFee[charitableFundWallet] = true;
    }
    
    
    // Allows 'owner' to change the wallet address for the Liquidity Pool Wallet.
    function changeLiquidityWallet(address newLiquidityAddress) public onlyOwner() {
        
        // Removes old address from the excludedFromFee mapping, then updates the mapping with the new address.
        _excludedFromFee[liquidityWallet] = false;
        liquidityWallet = newLiquidityAddress;
        _excludedFromFee[liquidityWallet] = true;
    }
    
    
    // Allows 'owner' to change the wallet address for the Gauss Gang Wallet.
    function changeGaussGangWallet(address newGaussGangAddress) public onlyOwner() {
        
        // Removes old address from the excludedFromFee mapping, then updates the mapping with the new address.
        _excludedFromFee[ggWallet] = false;
        ggWallet = newGaussGangAddress;
        _excludedFromFee[ggWallet] = true;
    }
    
    
    /*  Allows 'owner' to change the transaction fees at a later time, so long as the total Transaction Fee is lower than 12% (the initial fee ceiling).
            -An amount for each Pool is required to be entered, even if the specific fee amount won't be changed.         
            -Each variable should be entered as a single or double digit number to represent the intended percentage; 
                Example: Entering a 3 for newRedistributionFee would set the Redistribution fee to 3% of the Transaction Amount.
    */      
    function changeTransactionFees(uint256 newRedistributionFee, uint256 newCharitableFundFee, uint256 newLiquidityFee, uint256 newGGFee) public onlyOwner() {
        uint256 newTotalFee;
        
        newTotalFee = newRedistributionFee + newCharitableFundFee + newLiquidityFee + newGGFee;

        if (newTotalFee <= 12) {
            redistributionFee = newRedistributionFee;
            charitableFundFee = newCharitableFundFee;
            liquidityFee = newLiquidityFee;
            ggFee = newGGFee;
            _totalFee = newTotalFee;
        }
    }
    
    
    /*  Internal Transfer function; takes out transaction fees before sending remaining to 'recipient'.
            -At launch, the transaction fee is set to 12%, but will be lowered over time.
            -The max transaction fee is also 12%, never raising beyond the intital fee set at launch.
            -Fee is evenly split between 4 Pools: 
                    The Redistribution pool,        (Initially, 3%) 
                    the Charitable Fund pool,       (Initially, 3%)
                    the Liquidity pool,             (Initially, 3%)
                    and Gauss Gang pool             (Initially, 3%)
    */
    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused override(BEP20) {
        
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        
        _beforeTokenTransfer(sender, recipient, amount);
        
        // Checks to see if "sender" is excluded from the transaction fee, attempts the transaction without fees if found true.
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
    
    
    // Internal function to process a transfer while applying the Transaction Fee.
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
        _balances[redistributionWallet] = _balances[redistributionWallet] + redistributionAmount;
        _balances[charitableFundWallet] = _balances[charitableFundWallet] + charitableFundAmount;
        _balances[liquidityWallet] = _balances[liquidityWallet] + liquidityAmount;
        _balances[ggWallet] = _balances[ggWallet] + ggAmount;
            
        emit Transfer(sender, recipient, finalAmount);
        emit Transfer(sender, redistributionWallet, redistributionAmount);
        emit Transfer(sender, charitableFundWallet, charitableFundAmount);
        emit Transfer(sender, liquidityWallet, liquidityAmount);
        emit Transfer(sender, ggWallet, ggAmount);
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
    

    // Internal function; overriden to allow Snapshot to update values before a Transfer event.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(BEP20, BEP20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    
    // Function to allow "owner" to upgarde the contract using a UUPS Proxy
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}