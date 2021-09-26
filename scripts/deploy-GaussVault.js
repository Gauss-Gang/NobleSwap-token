// Deploys the Guass GANG token while using the OpenZepplin UUPS Upgradable Pattern
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Enter address of Gauss GANG Token deployement and the address for the Initial Distribution Wallet.
  const GaussGANGAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

  const GaussVault = await ethers.getContractFactory("GaussVault");
  console.log('Deploying GaussVault...');
  
  const contract = await upgrades.deployProxy(GaussVault, [GaussGANGAddress], { kind: 'uups'}, { unsafeAllow: ['delegatecall']});

  await contract.deployed();

  console.log("GaussVault deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });