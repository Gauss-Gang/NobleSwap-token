// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "../access/Ownable.sol";


/*  This contract is used for storing funds while a crowdsale is in progress.
        - should be initialized in the crowdsale contract, otherwise there are no safegaurds to prevent "owner" from closing the RefundVault and recieving all funds.
        - if crowdsale fails to reach the minimum cap (set in the crowdsale contract) by the close of the sale, a full refund to all buyers will be initiated.
        
        DEV-NOTE:   - a struct and array were used, in place of a mapping container, to hold buyer addresses and BNB amount.
                    - this allows "owner" to cover the cost of gas and refund all buyers in a single transaction.
*/
contract RefundVault is Ownable {

    // Creates enum to represent the State of the RefundVault.
    enum State { Active, Refunding, Completed }
    State private _state;

    // The sctruct will hold the address and BNB amount of each Buyer.
    struct Buyer {
        address payable wallet;
        uint256 amount;
    }

    // Array of all Buyers, used to keep track of each Buyer's address and amount of BNB spent.
    Buyer[] public buyers;

    // Address where BNB funds are collected.
    address payable public crowdsaleWallet;    

    event Completed();
    event RefundsIssued();
    event Refunded(address indexed beneficiary, uint256 jagerAmount);


    // Constructor sets the crowdsaleWallet adress and sets the State to Active.
    constructor(address payable _crowdsaleWallet) {
        require(_crowdsaleWallet != address(0), "RefundVault: address can not be 0.");
        __Ownable_init();
        crowdsaleWallet = _crowdsaleWallet;
        _state = State.Active;
    }


    // Returns the integer value of the current State; 0 = Active, 1 = Refunding, 2 = Completed.
    function currentState() public view returns (uint) {
        return uint(_state);
    }


    // Allows "onwer" to keep track of the buyer's wallet address and amount of BNB sent in purchase; can only be called when in an Active State.
    function deposit(address payable _wallet, uint256 _amount) onlyOwner public {
        require(_state == State.Active, "RefundVault: State not currently active.");
        buyers.push(Buyer(_wallet, _amount));
    }


    // Allows "owner" to close the RefundVault, can only be called when in an Active State.
    function closeVault() onlyOwner public {
        require(_state == State.Active, "RefundVault: State not currently active.");
        crowdsaleWallet.transfer(address(this).balance);
        _state = State.Completed;
        emit Completed();        
    }


    // Allows "owner" to issue refunds should the minimum cap not be reached during the Crowdsale; can only be called when in an Active State.
    function issueRefunds() onlyOwner public {
        require(_state == State.Active, "RefundVault: State not currently active.");
        _state = State.Refunding;

        for (uint i = 0; i < buyers.length; i++) {
            require(buyers[i].amount > 0, "RefundVault: beneficiary amount can not be 0.");
            _refund(buyers[i]);
        }
        
        emit RefundsIssued();
    }

    
    // Internal function to facilitate the refund process per buyer.
    function _refund(Buyer storage beneficiary) internal {
        require(_state == State.Refunding, "RefundVault: State not currently Refunding.");
        beneficiary.wallet.transfer(beneficiary.amount);
        beneficiary.amount = 0;
        emit Refunded(beneficiary.wallet, beneficiary.amount);
    }
}