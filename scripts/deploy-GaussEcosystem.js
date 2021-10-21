// Deploys the Guass(GANG) token ecosystem while using the OpenZepplin UUPS Upgradable Pattern
const { ethers, upgrades } = require("hardhat");

async function main() {

    /*------------------------------------------------------------------------------------------------------------------------------------*/
    /*---------------------------------------------- Deployement of Contracts ------------------------------------------------------------*/
    /*------------------------------------------------------------------------------------------------------------------------------------*/

    // Deploys the Guass GANG token while using the OpenZepplin UUPS Upgradable Pattern
    const GaussGANG = await ethers.getContractFactory("GaussGANG");
    console.log('Deploying GaussGANG...');
    
    const tokenContract = await upgrades.deployProxy(GaussGANG, { kind: 'uups'}, { unsafeAllow: ['delegatecall']});  
    await tokenContract.deployed();
    console.log("GaussGANG deployed to:", tokenContract.address);


    // Deploys the GaussVault contract
    const GaussVault = await ethers.getContractFactory("GaussVault");
    console.log('Deploying GaussVault...');

    const GaussGANGAddress = tokenContract.address;

    const vaultContract = await upgrades.deployProxy(GaussVault, [GaussGANGAddress], { kind: 'uups'}, { unsafeAllow: ['delegatecall']});
    await vaultContract.deployed();  
    console.log("GaussVault deployed to:", vaultContract.address);


    // Deploys GaussCrowdsale contract.
    const GaussCrowdsale = await ethers.getContractFactory("GaussCrowdsale");
    console.log('Deploying GaussCrowdsale...');

    const startTime = "1635742800";     // November 1st 2021, 0:00am
    const crowdsaleWallet = "0x64aCACeA417B39E9e6c92714e30f34763d512140";

    const crowdsaleContract = await GaussCrowdsale.deploy(startTime, GaussGANGAddress, crowdsaleWallet, {value: ethers.utils.parseEther("0.5")});
    console.log("GaussCrowdsale deployed to:", crowdsaleContract.address);



    /*------------------------------------------------------------------------------------------------------------------------------------*/
    /*----------------------------------- Necessary Variable Initialization and Upkeep ---------------------------------------------------*/
    /*------------------------------------------------------------------------------------------------------------------------------------*/

    // Adds the GaussVault to the AddressBook and excludes it from the Transaction Fee
    const vaultName = "Gauss Vault";
    const gaussVaultAddress = vaultContract.address;
    await tokenContract.addWalletAddress(vaultName, gaussVaultAddress);
    console.log("GaussGANG; added GaussVault address to AddressBook:", gaussVaultAddress);


    // Adds the GaussCrowdsale to the AddressBook and excludes it from the Transaction Fee
    const crowdsaleName = "Gauss Crowdsale";
    const gaussCrowdsaleAddress = crowdsaleContract.address;
    await tokenContract.addWalletAddress(crowdsaleName, gaussCrowdsaleAddress);
    console.log("GaussGANG; added GaussCrowdsale address to AddressBook:", gaussCrowdsaleAddress);


    // Transfers the Total Supply of Gauss(GANG) tokens to GaussVault contract.
    console.log("GaussGANG; transferring total supply, minus 15 million, to GaussVault...");
    const recipient = vaultContract.address;
    const amount = 235000000000000000n;
    await tokenContract.transfer(recipient,amount);
    console.log("GaussGANG; transferred amount:", amount);


    // Transfers 1 BNB to the GaussVault contract so that it may pay any gas required.
    console.log("GaussVault; Transferring BNB to GaussVault...");
    [owner] = await ethers.getSigners();
    const transactionHash = await owner.sendTransaction({
        to: vaultContract.address,
        value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
    });
    console.log("TransactionHash is:", transactionHash);
    
    
    // Locks the Total Supply of Gauss(GANG) tokens in various ScheduledTokenLock contracts, each representing the various pools used for and by Gauss Gang Inc.
    console.log("GaussVault; Transferring tokens to their respective Token Lock contracts...");
    await vaultContract.lockGaussVault();
    
    
    // List each Token Lock contract address held in GaussVault.
    const contractAddressess = await vaultContract.vestingContractAddresses();
    console.log("GaussVault; Token Lock contract addresses:", contractAddressess);


    // Transfers 15 Million tokens to the GaussGrowdsale contract.
    console.log("GaussGANG; transferring 15 million tokens to GaussCrowdsale...");
    const recipientAddress = crowdsaleContract.address;
    const transferAmount = 15000000000000000n;
    await tokenContract.transfer(recipientAddress, transferAmount);
    console.log("GaussGANG; transferred amount:", transferAmount);


    // Releases the initial available tokens (tokens to be released upon launch).
    console.log("GaussVault; releasing available tokens from each contract...");
    await vaultContract.releaseAvailableTokens();



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
        const vaultAddress = await tokenContract.checkWalletAddress(vaultName);
        console.log("GaussGANG; wallet address excluded from Fee:", vaultAddress);   


        // Checks current address for GaussCrowdsale is excluded from fee.
        const crowdsaleAddress = await tokenContract.checkWalletAddress(crowdsaleName);
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