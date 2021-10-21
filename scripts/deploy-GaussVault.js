// Deploys the Guass GANG token while using the OpenZepplin UUPS Upgradable Pattern
const { ethers, upgrades } = require("hardhat");

async function main() {

  const GaussVault = await ethers.getContractFactory("GaussVault");
  console.log('Deploying GaussVault...');

  // Enter address of Gauss GANG Token deployement and the address for the Initial Distribution Wallet.
  const GaussGANGAddress = "";

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