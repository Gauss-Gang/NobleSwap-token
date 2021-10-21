// Deploys the GaussCrowdsale contract.
const { ethers, upgrades } = require("hardhat");

async function main() {

    const GaussCrowdsale = await ethers.getContractFactory("GaussCrowdsale");
    console.log('Deploying GaussCrowdsale...');

    // Set the parameters needed to launch the GaussCrowdsale contract
    const startTime = "";
    const gaussAddress = "";
    const crowdsaleWallet = "";

    const contract = await GaussCrowdsale.deploy(startTime, gaussAddress, crowdsaleWallet);
    console.log("GaussCrowdsale deployed to:", contract.address);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });