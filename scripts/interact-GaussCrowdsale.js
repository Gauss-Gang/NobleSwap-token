// Allows one to interact with already deployed contract.
const { ethers, upgrades } = require("hardhat");

async function main() {

    // Following code is to use the contract at the deployed address.
    const deployedAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";
    const GaussCrowdsale = await ethers.getContractFactory("GaussCrowdsale");
    const contract = await GaussCrowdsale.attach(deployedAddress);


    // List the address for the Crowdsale Wallet.
    const crowdsaleWallet = await contract.crowdsaleWallet();
    console.log("GaussCrowdsale; crowdsaleWallet address:", crowdsaleWallet);


    // List the amount of Jager raised in the GaussCrowdsale.
    const jagerRaised = await contract.jagerRaised();
    console.log("GaussCrowdsale; Jager raised:", jagerRaised);


    // List the amount of Gauss(GANG) tokens sold in the GaussCrowdsale.
    const gaussSold = await contract.gaussSold();
    console.log("GaussCrowdsale; Gauss(GANG) tokens sold:", gaussSold);


    // List the current stage number.
    const currentStage = await contract.currentStage();
    console.log("GaussCrowdsale; current Stage of Crowdsale:", currentStage);

 
    // List the start time of the GaussCrowdsale.
    const startTime = await contract.startTime();
    console.log("GaussCrowdsale; start time of the Crowdsale:", startTime);
    
    
    // List the end time of the GaussCrowdsale.
    const endTime = await contract.endTime();
    console.log("GaussCrowdsale; end time of the Crowdsale:", endTime);    


    // Allows owner to close the RefundVault if the minimum raised cap has been reached.
//    await contract.closeRefundVault();
//    console.log("GaussCrowdsale; RefundVault closed...")


    // Allows owner to issue refunds if the minimum raised cap has NOT been reached.
//    await contract.issueRefunds();
//    console.log("GaussCrowdsale; refunds issued...")


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