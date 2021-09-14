// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const GaussGANG = await ethers.getContractFactory("GaussGANG");
  console.log('Deploying GaussGANG...');
  
  const gg = await upgrades.deployProxy(GaussGANG);

  await gg.deployed();

  console.log("GaussGANG deployed to:", gg.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });