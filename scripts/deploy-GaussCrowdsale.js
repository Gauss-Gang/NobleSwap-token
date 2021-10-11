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



    //** Following code sets up the Gauss(GANG) token to exclude the Crowdsale Address from the Transaction Fee **\\

        // Allows the use of the GaussGANG contract at the deployed address.
        const deployedAddress = "";    // Local-Testnet: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
        const GaussGANG = await ethers.getContractFactory("GaussGANG");
        const gaussContract = await GaussGANG.attach(deployedAddress);


        // Adds a wallet address to the AddressManager and excludes it from the Transaction Fee
        const newWalletName = "Gauss Crowdsale";
        const newAddress = contract.address;
        await gaussContract.addWalletAddress(newWalletName, newAddress);
        console.log("GaussGANG added new wallet address to AddressManager:", newAddress);


        // Checks current address for the wallet name passsed below.
        const walletNameToCheck = "Gauss Crowdsale";
        const walletAddress = await gaussContract.checkWalletAddress(walletNameToCheck);
        console.log("GaussGANG wallet address excluded from Fee:", walletAddress);
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });