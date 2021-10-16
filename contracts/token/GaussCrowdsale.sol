/*  _____________________________________________________________________________

    GaussCrowdsale: Crowdsale for the Gauss Gang Ecosystem

    Deployed to: TODO

    MIT License. (c) 2021 Gauss Gang Inc. 

    _____________________________________________________________________________
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "../dependencies/interfaces/IBEP20.sol";
import "../dependencies/access/Ownable.sol";
import "../dependencies/contracts/RefundVault.sol";



/*  The GuassCrowdsale allows buyers to purchase Gauss(GANG) tokens with BNB.
        - Crowdsale is Staged, where each Stage has a different exchange rate of BNB to Gauss(GANG) tokens.
        - Crowdsale is Refundable if the minimum cap amount is not reached by the end of the sale.
        - Crowdsale has a Maximum Purchase amount of 100 BNB.
        - The tokens bought in the Crowdsale can only be claimed after the completetion of the Crowdsale.
*/
contract GaussCrowdsale is Ownable {

    // Mapping that contains the addresses of each purchaser and the amount of tokens they will recieve.
    mapping(address => uint256) private balances;

    // The token being sold.
    IBEP20 private _token;

    // Refund Vault used to hold funds while Crowdsale is running
    RefundVault private refundVault;

    // How many Gauss(GANG) tokens a buyer will receive per BNB. (shown with the Gauss(GANG) decimals applied)
    uint256[] private rates = [
        6800000000000,      // 6,800 tokens per 1 BNB during stage 0
        5667000000000,      // 5,667 tokens per 1 BNB during stage 1
        4857000000000,      // 4,857 tokens per 1 BNB during stage 2
        4250000000000,      // 4,250 tokens per 1 BNB during stage 3
        3778000000000,      // 3,778 tokens per 1 BNB during stage 4
        3400000000000,      // 3,400 tokens per 1 BNB during stage 5
        3091000000000,      // 3,091 tokens per 1 BNB during stage 6
        2833000000000,      // 2,833 tokens per 1 BNB during stage 7
        2615000000000,      // 2,615 tokens per 1 BNB during stage 8
        2429000000000,      // 2,429 tokens per 1 BNB during stage 9
        2267000000000,      // 2,267 tokens per 1 BNB during stage 10
        2125000000000,      // 2,125 tokens per 1 BNB during stage 11
        2000000000000,      // 2,000 tokens per 1 BNB during stage 12
        1889000000000,      // 1,889 tokens per 1 BNB during stage 13
        1789000000000,      // 1,789 tokens per 1 BNB during stage 14
        1700000000000       // 1,700 tokens per 1 BNB during stage 15
    ];

    // Number of tokens per stage; the rate changes after each stage has been completed.
    uint256[] private stages = [
        100000,     // 100,000 tokens in stage 0
        250000,     // 150,000 tokens in stage 1
        500000,     // 250,000 tokens in stage 2
        750000,     // 250,000 tokens in stage 3
        1250000,    // 500,000 tokens in stage 4
        2000000,    // 750,000 tokens in stage 5
        2750000,    // 750,000 tokens in stage 6
        3500000,    // 750,000 tokens in stage 7
        4250000,    // 750,000 tokens in stage 8
        5000000,    // 750,000 tokens in stage 9
        6000000,    // 1,000,000 tokens in stage 10
        7000000,    // 1,000,000 tokens in stage 11
        9000000,    // 2,000,000 tokens in stage 12
        11000000,   // 2,000,000 tokens in stage 13
        13000000,   // 2,000,000 tokens in stage 14
        15000000    // 2,000,000 tokens in stage 15
    ];

    // Address where BNB funds are collected.
    address payable public crowdsaleWallet;

    // The amount, in Jager, that will represent the minimum amount before owner can release stored funds. (Set to 550 BNB)
    uint256 private minimumCap;

    // The max amount, in Jager, a buyer can purchase; used to prevent potential whales from buying up too many tokens at once.
    uint256 private purchaseCap;

    // Amount of Jager raised (BNB's smallest unit; BNB has 8 decimals).
    uint256 public jagerRaised;

    // Amount of remaining Gauss(GANG) tokens remaining in the GaussCrowdsale.
    uint256 public gaussSold;

    // Number indicating the current stage.
    uint256 public currentStage;

    // Start and end timestamps, between which investments are allowed.
    uint256 public startTime;
    uint256 public endTime;

    // A varaible to determine whether Crowdsale is closed or not.
    bool private _hasClosed;

    // Initializes an event that will be called after each token purchase.
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    // Constructor sets takes the variables passed in and initializes are state variables. 
    constructor(uint256 _startTime, address _gaussAddress, address payable _crowdsaleWallet) {

        require(_startTime >= block.timestamp, "GaussCrowdsale: startTime can not be before current time.");
        require(_gaussAddress != address(0), "GaussCrowdsale: gaussAddress can not be Zero Address.");
        require(_crowdsaleWallet != address(0), "GaussCrowdsale: Crowdsale wallet can not be Zero Address.");
        require(rates.length == stages.length);

        __Ownable_init();
        startTime = _startTime;
        endTime = startTime + (30 days);
        crowdsaleWallet = _crowdsaleWallet;
        _token = IBEP20(_gaussAddress);
        refundVault = new RefundVault(crowdsaleWallet);
        minimumCap = (550 * 10**8);
        purchaseCap = (100 * 10**8);
        jagerRaised = 0;
        gaussSold = 0;
        currentStage = 0;
        _hasClosed = false;        
    }


    // Receive function to recieve BNB.
    receive() external payable {
        buyTokens(msg.sender);
    }


    /*  Allows one to buy or gift Gauss(GANG) tokens using BNB. 
            - Amount of BNB the buyer transfers must be lower than the "purchaseCap" of 100 BNB.
            - Either transfers BNB to RefundVault or crowdsaleWallet, depending on if "minimumCap" has been reached.
            - Keeps track of the token amounts purchased in the "balances" mapping, to be claimed after to Crowdsale is completed. */
    function buyTokens(address _beneficiary) public payable {
        uint256 jagerAmount = msg.value;
        _validatePurchase(_beneficiary, jagerAmount);
        _processPurchase(_beneficiary, jagerAmount);
        _transferBNB(payable(msg.sender), msg.value);
    }


    // Validation of an incoming purchase. Uses require statements to revert state when conditions are not met.
    function _validatePurchase(address _beneficiary, uint256 _jagerAmount) internal view {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "GaussCrowdsale: current time is either before or after Crowdsale period.");
        require(_hasClosed == false, "Crowdsale: sale is no longer open");
        require(_beneficiary != address(0), "GaussCrowdsale: beneficiary can not be Zero Address.");
        require(_jagerAmount != 0, "GaussCrowdsale: amount of BNB must be greater than 0.");
        require(_jagerAmount <= purchaseCap, "Crowdsale: amount of BNB sent must lower than 100");
        require((balances[_beneficiary] + _jagerAmount) <= purchaseCap, "Crowdsale: amount of BNB entered exceeds buyers purchase cap.");
    }


    // Adds the "tokenAmount" (amount of Gauss(GANG) tokens) to the beneficiary's balance.
    function _processPurchase(address _beneficiary, uint256 _jagerAmount) internal {

        // Calculates the token amount using the "jagerAmount" and the rate at the current stage.
        uint256 tokenAmount = ((_jagerAmount * rates[currentStage])/(10**8));
        
        // Addes the "tokenAmount" to the beneficiary's balance.
        balances[_beneficiary] = balances[_beneficiary] + tokenAmount;

        _updatePurchasingState(tokenAmount, _jagerAmount); 
        emit TokenPurchase(msg.sender, _beneficiary, _jagerAmount, tokenAmount);
    }


    // Updates the amount of tokens left in the Crowdsale; may change the stage if conditions are met.
    function _updatePurchasingState(uint256 _tokenAmount, uint256 _jagerAmount) internal {        
        gaussSold = gaussSold + _tokenAmount;
        jagerRaised = jagerRaised + _jagerAmount;
        
        if (gaussSold >= stages[currentStage]) {
            if (currentStage < stages.length) {
                currentStage = currentStage + 1;
            }
        }
    }


    // Tranfers the BNB recieved in purchase to either the Crowdsale Wallet or RefundVault, depending on whether the "minimumCap" has been met.
    function _transferBNB(address payable senderWallet, uint256 jagerAmount) internal {
        if (refundVault.currentState() == 2){
            crowdsaleWallet.transfer(jagerAmount);
        }
        else {
            payable(address(refundVault)).transfer(jagerAmount);
            refundVault.deposit(senderWallet, jagerAmount);
        }        
    }


    // Closes the RefundVault if the "minimumCap" has been reached. 
    function closeRefundVault() public onlyOwner() {
        require(jagerRaised >= minimumCap, "Crowdsale: minimum sale cap not reached");
        refundVault.closeVault();
    }


    // Allows "owner" to issue refunds to all buyers should the minimum cap amount not be reached by the completion of the Crowdsale.
    function issueRefunds() public onlyOwner() {
        require(block.timestamp >= endTime, "GaussCrowdsale: current time is before Crowdsale end time.");
        require(jagerRaised < minimumCap, "Crowdsale: minimum sale cap has been reached");
        refundVault.issueRefunds();
    }


    /*  Transfer remaining Gauss(GANG) tokens back to the "crowdsaleWallet" as well BNB earned if "minimumCap" is reached.
            NOTE:   - To be called at end of the Crowdsale to finalize and complete the Crowdsale.
                    - Can act as a backup in case the sale needs to be urgently stopped.
                    - Care should be taken when calling function as it could prematurely end the Crowdsale if accidentally called. */
    function finalizeCrowdsale() public onlyOwner() {
          
        // Send remaining tokens back to the admin.
        uint256 tokensRemaining = _token.balanceOf(address(this));
        _token.transfer(crowdsaleWallet, tokensRemaining);

        // Closes the Crowdsale and allows beneficiaries to withdrawl the purchased tokens.
        _hasClosed = true;

        // If "minimumCap" has been reached, transfer BNB raised to the Crowdsale wallet.
        if (address(this).balance >= minimumCap) {
            crowdsaleWallet.transfer(address(this).balance);
        }
    }


    // Can only be called once the Crowdsale has completed and the "owner" has finalized the Crowdsale.
    function withdrawTokens() public {
        
        require(_hasClosed == true, "Crowdsale: sale has not been closed.");
        uint256 amount = balances[msg.sender];
        
        require(amount > 0, "Crowdsale: can not withdrawl 0 amount.");
        balances[msg.sender] = 0;

        _token.transfer(msg.sender, amount);
    }
}