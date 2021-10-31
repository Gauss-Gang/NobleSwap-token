// Deploys the GaussCrowdsale contract.
const { ethers, upgrades } = require("hardhat");

async function main() {

    const GaussCrowdsale_V2 = await ethers.getContractFactory("GaussCrowdsale_V2");
    console.log('Deploying GaussCrowdsale_V2...');

    // Set the parameters needed to launch the GaussCrowdsale_V2 contract
    const startTime = "1635782400";         // 1635782400 = November 1st 2021, 12:00pm EDT
    const crowdsaleWallet = "0x64aCACeA417B39E9e6c92714e30f34763d512140";

    const contract = await GaussCrowdsale_V2.deploy(startTime, crowdsaleWallet, {value: ethers.utils.parseEther("0.5")});
    console.log("GaussCrowdsale deployed to:", contract.address);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });