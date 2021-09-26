// Upgrades Gauss GANG Token using UUPS Proxy.
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Following code is to upgrade the contract at later time.
  // ENTER ADDRESS of previous interation before running script.
  const previousIteration = "";

  const GaussV2 = await ethers.getContractFactory("GaussV2");
  console.log('Deploying Gauss GANG Upgrade...');

  const upgraded = await upgrades.upgradeProxy(previousIteration, GaussV2);
  console.log("Gauss GANG Upgrade deployed to:", upgraded.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
