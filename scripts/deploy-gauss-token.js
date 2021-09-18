// Deploys the Guass GANG token while using the OpenZepplin UUPS Upgradable Pattern
const { ethers, upgrades } = require("hardhat");

async function main() {
  const GaussGANG = await ethers.getContractFactory("GaussGANG");
  console.log('Deploying GaussGANG...');
  
  const contract = await upgrades.deployProxy(GaussGANG, { kind: 'uups'});

  await contract.deployed();

  console.log("GaussGANG deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });