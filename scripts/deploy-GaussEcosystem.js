// Deploys the Guass(GANG) token ecosystem while using the OpenZepplin UUPS Upgradable Pattern
const { ethers, upgrades } = require("hardhat");

async function main() {

    // Deploys the Guass GANG token while using the OpenZepplin UUPS Upgradable Pattern
    const GaussGANG = await ethers.getContractFactory("GaussGANG");
    console.log('Deploying GaussGANG...');
    
    const tokenContract = await upgrades.deployProxy(GaussGANG, { kind: 'uups'}, { unsafeAllow: ['delegatecall']});
  
    await tokenContract.deployed();
    console.log("GaussGANG deployed to:", tokenContract.address);


    // Deploys the GaussVault contract
    const GaussGANGAddress = tokenContract.address;

    const GaussVault = await ethers.getContractFactory("GaussVault");
    console.log('Deploying GaussVault...');

    const vaultContract = await upgrades.deployProxy(GaussVault, [GaussGANGAddress], { kind: 'uups'}, { unsafeAllow: ['delegatecall']});

    await vaultContract.deployed();  
    console.log("GaussVault deployed to:", vaultContract.address);


    // Transfers the Total Supply of Gauss(GANG) tokens to GaussVault contract.
    const recipient = vaultContract.address;
    const amount = 250000000000000000n;
    await tokenContract.transfer(recipient,amount);
    console.log("Transferred amount:", amount);


    // Locks the Total Supply of Gauss(GANG) tokens in various ScheduledTokenLock contracts, each representing the various pools used for and by Gauss Gang Inc.
    console.log("GaussVault; Transferring tokens to their respective Token Lock contracts...");
    await vaultContract.lockGaussVault();


    //  Releases the initial available tokens (tokens to be released upon launch).
    await vaultContract.releaseAvailableTokens();
    console.log("GaussVault; releasing available tokens from each contract..."); 


    // List each beneficiary wallet addresses for each of the Token Lock contracts in GaussVault.
    const beneficiaryAddressess = await vaultContract.beneficiaryVestingAddresses();
    console.log("GaussVault; beneficiary wallet addresses:", beneficiaryAddressess);


    // List each Token Lock contract address held in GaussVault.
    const contractAddressess = await vaultContract.vestingContractAddresses();
    console.log("GaussVault; Token Lock contract addresses:", contractAddressess);


    // Returns the balance of the Community Pool Wallet.
    const communityPoolAddress = "0x4249B05E707FeeA3FB034071C66e5A227C230C2f";
    const communityPoolBalance = await tokenContract.balanceOf(communityPoolAddress);
    console.log("Community Pool Wallet balance:", communityPoolBalance);


    // Returns the balance of the Charitable Fund Wallet.
    const charitableFundAddress = "0x7d74E237825Eba9f4B026555f17ecacb2b0d78fE";
    const charitableFundBalance = await tokenContract.balanceOf(charitableFundAddress);
    console.log("Charitable Fund Wallet balance:", charitableFundBalance);


    // Returns the balance of the Charitable Fund Wallet.
    const advisorAddress = "0x3e3049A80590baF63B6aC8D74F5CbB31584059bB";
    const advisorBalance = await tokenContract.balanceOf(advisorAddress);
    console.log("Advisor Fund Wallet balance:", advisorBalance);


    // Returns the balance of the Marketing Funds Wallet.
    const marketingAddress = "0x46ceE8F5F3e30aF7b62374249907FB97563262f5";
    const marketingBalance = await tokenContract.balanceOf(marketingAddress);
    console.log("Marketing Funds Wallet balance:", marketingBalance);


    // Returns the balance of the Operations and Developement Funds Wallet.
    const opsDevAddress = "0xF9f41Bd5C7B6CF9a3C6E13846035005331ed940e";
    const opsDevBalance = await tokenContract.balanceOf(opsDevAddress);
    console.log("Operations and Developement Funds balance:", opsDevBalance);


    // Returns the balance of the Vesting Incentive Wallet.
    const vestingAddress = "0xe3778Db10A5E8b2Bd1B68038F2cEFA835aa46b45";
    const vestingBalance = await tokenContract.balanceOf(vestingAddress);
    console.log("Vesting Incentive wallet balance:", vestingBalance);


    // Returns the balance of the Reserve Wallet.
    const reserveAddress = "0xf02fD116EEfB47E394721356B36D3350972Cc0c7";
    const reserveBalance = await tokenContract.balanceOf(reserveAddress);
    console.log("Reserve wallet balance:", reserveBalance);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });