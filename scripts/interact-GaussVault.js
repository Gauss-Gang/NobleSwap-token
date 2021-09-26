// Allows one to interact with already deployed contract
const { ethers, upgrades } = require("hardhat");

async function main() {

    // Following code is to use the contract at the deployed address.
    const deplyedAddress = "";
    const GaussVault = await ethers.getContractFactory("GaussVault");
    const contract = await GaussVault.attach(deplyedAddress);


//    // Locks the Vault, transferring the total amount in the GaussVault to various Time Lock contracts.
//    console.log("GaussVault; Transferring tokens to their respective Token Lock contracts...");
//    await contract.lockGaussVault();


    // List each beneficiary wallet addresses for each of the Token Lock contracts in GaussVault.
//    const beneficiaryAddressess = await contract.beneficiaryVestingAddresses();
//    console.log("GaussVault; beneficiary wallet addresses:", beneficiaryAddressess);


    // List each Token Lock contract address held in GaussVault.
//    const contractAddressess = await contract.vestingContractAddresses();
//    console.log("GaussVault; Token Lock contract addresses:", contractAddressess);


    // Attempts to release tokens from every Token Lock contract in GaussVault, lists each wallet address that recieves released tokens.
//    await contract.releaseAvailableTokens();
//    console.log("GaussVault; releasing available tokens from each contract..."); 


    // Vests the token "amount" over the specified "releaseTime"
    //const sender = "";
    //const beneficiary = "";
    //const amount = "";
    //const releaseTime = "";
    //const deployedAddress = await contract.vestTokens(sender, beneficiary, amount, releaseTime);
    //console.log("GaussVault; Tokens vested; deployed Token Lock contract:", deplyedAddress)


    // Vests the token "totalAmount" over the scheduled defined by "amountsList" and "lockTimes".
    //const Sender = "";
    //const Beneficiary = "";
    //const totalAmount = "";
    //const amountsList = "";
    //const lockTimes = ""; 
    //const newDeployedAddress = await contract.vestTokens(Sender, Beneficiary, totalAmount, amountsList, lockTimes);
    //console.log("GaussVault; Tokens vested; deployed Scheduled Token Lock contract:", newDeployedAddress)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });