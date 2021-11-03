// Deploys the Guass(GANG) token ecosystem while using the OpenZepplin UUPS Upgradable Pattern
const { ethers, upgrades } = require("hardhat");

async function main() {

    // Following code is to use the contract at the deployed address.
    const deployedGANG = "0x71E837De0534B5E81c2d540e2452951b087e52d7";
    const GaussGANG = await ethers.getContractFactory("GaussGANG");
    const tokenContract = await GaussGANG.attach(deployedGANG);


    // Following code is to use the contract at the deployed address.
    const deployedVault = "0x2258af5877510A01E068d7AAB94Cc787c74C868B";
    const GaussVault = await ethers.getContractFactory("GaussVault");
    const vaultContract = await GaussVault.attach(deployedVault);


    // Following code is to use the contract at the deployed address.
    const deployedCrowdsale = "0xFC5bE805c952f78661aE32703c4e0f8f8C6Bcd2E";
    const GaussCrowdsale = await ethers.getContractFactory("GaussCrowdsale");
    const crowdsaleContract = await GaussCrowdsale.attach(deployedCrowdsale);


/*------------------------------------------------------------------------------------------------------------------------------------*/
/*----------------------------- Final upkeep and initalizations  ---------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------*/

// Locks the Total Supply of Gauss(GANG) tokens in various ScheduledTokenLock contracts, each representing the various pools used for and by Gauss Gang Inc.
//console.log("GaussVault; Transferring tokens to their respective Token Lock contracts...");
//await vaultContract.lockGaussVault();


// List each Token Lock contract address held in GaussVault.
const contractAddressess = await vaultContract.vestingContractAddresses();
console.log("GaussVault; Token Lock contract addresses:", contractAddressess);


// Transfers 15 Million tokens to the GaussGrowdsale contract.
//console.log("GaussGANG; transferring 15 million tokens to GaussCrowdsale...");
//const recipientAddress = crowdsaleContract.address;
//const transferAmount = 15000000000000000n;
//await tokenContract.transfer(recipientAddress, transferAmount);
//console.log("GaussGANG; transferred amount:", transferAmount);


// Releases the initial available tokens (tokens to be released upon launch).
//console.log("GaussVault; releasing available tokens from each contract...");
//await vaultContract.releaseAvailableTokens();



/*------------------------------------------------------------------------------------------------------------------------------------*/
/*----------------------------- Comfirmation of Launch, Each Value Should be Checked for Correctness ---------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------------*/

    // Returns the balance of the Community Pool Wallet.
    const communityPoolAddress = "0x4249B05E707FeeA3FB034071C66e5A227C230C2f";
    const communityPoolBalance = await tokenContract.balanceOf(communityPoolAddress);
    console.log("GaussGANG; Community Pool Wallet balance:", communityPoolBalance);


    // Returns the balance of the Charitable Fund Wallet.
    const charitableFundAddress = "0x7d74E237825Eba9f4B026555f17ecacb2b0d78fE";
    const charitableFundBalance = await tokenContract.balanceOf(charitableFundAddress);
    console.log("GaussGANG; Charitable Fund Wallet balance:", charitableFundBalance);


    // Returns the balance of the Charitable Fund Wallet.
    const advisorAddress = "0x3e3049A80590baF63B6aC8D74F5CbB31584059bB";
    const advisorBalance = await tokenContract.balanceOf(advisorAddress);
    console.log("GaussGANG; Advisor Fund Wallet balance:", advisorBalance);


    // Returns the balance of the Marketing Funds Wallet.
    const marketingAddress = "0x46ceE8F5F3e30aF7b62374249907FB97563262f5";
    const marketingBalance = await tokenContract.balanceOf(marketingAddress);
    console.log("GaussGANG; Marketing Funds Wallet balance:", marketingBalance);


    // Returns the balance of the Operations and Developement Funds Wallet.
    const opsDevAddress = "0xF9f41Bd5C7B6CF9a3C6E13846035005331ed940e";
    const opsDevBalance = await tokenContract.balanceOf(opsDevAddress);
    console.log("GaussGANG; Operations and Developement Funds balance:", opsDevBalance);


    // Returns the balance of the Vesting Incentive Wallet.
    const vestingAddress = "0xe3778Db10A5E8b2Bd1B68038F2cEFA835aa46b45";
    const vestingBalance = await tokenContract.balanceOf(vestingAddress);
    console.log("GaussGANG; Vesting Incentive wallet balance:", vestingBalance);


    // Returns the balance of the Reserve Wallet.
    const reserveAddress = "0xf02fD116EEfB47E394721356B36D3350972Cc0c7";
    const reserveBalance = await tokenContract.balanceOf(reserveAddress);
    console.log("GaussGANG; Reserve wallet balance:", reserveBalance);


    // Returns the balance of the GaussCrowdsale Contract.
    const crowdsaleBalance = await tokenContract.balanceOf(crowdsaleContract.address);
    console.log("GaussGANG; GaussCrowdsale Contract balance:", crowdsaleBalance);

    
    // Checks current address for GaussVault is excluded from fee.
    const vaultAddress = await tokenContract.checkWalletAddress("Gauss Vault");
    console.log("GaussGANG; wallet address excluded from Fee:", vaultAddress);   


    // Checks current address for GaussCrowdsale is excluded from fee.
    const crowdsaleAddress = await tokenContract.checkWalletAddress("Gauss Crowdsale");
    console.log("GaussGANG; wallet address excluded from Fee:", crowdsaleAddress);


    // List the address for the Crowdsale Wallet.
    const crowdsaleWalletAddress = await crowdsaleContract.crowdsaleWallet();
    console.log("GaussCrowdsale; crowdsaleWallet address:", crowdsaleWalletAddress);


    // List the current stage number.
    const currentStage = await crowdsaleContract.currentStage();
    console.log("GaussCrowdsale; current Stage of Crowdsale:", currentStage);


    // List the start time of the GaussCrowdsale.
    const crowdsaleStartTime = await crowdsaleContract.startTime();
    console.log("GaussCrowdsale; start time of the Crowdsale:", crowdsaleStartTime);


    // List the end time of the GaussCrowdsale.
    const endTime = await crowdsaleContract.endTime();
    console.log("GaussCrowdsale; end time of the Crowdsale:", endTime);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});