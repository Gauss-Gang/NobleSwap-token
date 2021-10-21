// Allows one to interact with already deployed contract.
const { ethers, upgrades } = require("hardhat");

async function main() {

    // Following code is to use the contract at the deployed address.
    const deployedAddress = "";
    const GaussCrowdsale = await ethers.getContractFactory("GaussCrowdsale");
    const contract = await GaussCrowdsale.attach(deployedAddress);


    // List the address for the Crowdsale Wallet.
//    const crowdsaleWallet = await contract.crowdsaleWallet();
//    console.log("GaussCrowdsale; crowdsaleWallet address:", crowdsaleWallet);


    // List the amount of Jager raised in the GaussCrowdsale.
    const jagerRaised = await contract.jagerRaised();
    console.log("GaussCrowdsale; Jager raised:", jagerRaised);


    // List the amount of Gauss(GANG) tokens sold in the GaussCrowdsale.
    const gaussSold = await contract.gaussSold();
    console.log("GaussCrowdsale; Gauss(GANG) tokens sold:", gaussSold);


    // List the current stage number.
//    const currentStage = await contract.currentStage();
//    console.log("GaussCrowdsale; current Stage of Crowdsale:", currentStage);

 
    // List the start time of the GaussCrowdsale.
//    const startTime = await contract.startTime();
//    console.log("GaussCrowdsale; start time of the Crowdsale:", startTime);
    
    
    // List the end time of the GaussCrowdsale.
//    const endTime = await contract.endTime();
//    console.log("GaussCrowdsale; end time of the Crowdsale:", endTime);


    // Allows owner to close the crowdsale.
//    await contract.closeCrowdsale();
//    console.log("GaussCrowdsale; crowdsale is now closed...")


    // Allows owner to release the tokens bought during the crowdsale. (May fail due to gas limits).
//    await contract.releaseTokens();
//    console.log("GaussCrowdsale; Gauss(GANG) tokens have been released...")
    

    // Allows owner to make token withdrawals allowable to all buyers (should the batch release function fail).
//    await contract.allowWithdrawals();
//    console.log("GaussCrowdsale; withdrawals are now allowed...")


    // Allows owner to get Receipts of every purchase, showing wallet addresses, BNB spent, and tokens bought.
//    const receipts = await contract.getReceipts();
//    console.log("GaussCrowdsale; purchase Receipts:", receipts)


    // Allows owner to update the balances should the batch transfer fail or partially fail.
//    const wallets = [];
//    const tokenAmounts = [];
//    await contract.updateBalances(wallets, tokenAmounts);
//    console.log("GaussCrowdsale; updating balances with information entered above...")


    // Allows owner to finalize and close the GaussCrowdsale.
//    await contract.finalizeCrowdsale();
//    console.log("GaussCrowdsale; crowdsale finalized and closed...")


    // Allows any buyer to purchase Gauss(GANG) tokens using BNB.
//    const beneficiaryAddress = "";
//    await contract.buyTokens(beneficiaryAddress);
//    console.log("GaussCrowdsale; Gauss(GANG) tokens purchased, can be redeemed after end of sale by following address:", beneficiaryAddress);


    // Allows any buyer to withdrawl their tokens after the crowdsale is complete.
//    await contract.withdrawTokens();
//    console.log("GaussCrowdsale; tokens withdrawn to senders address...")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });