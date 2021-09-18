// Upgrades Gauss GANG Token using UUPS Proxy.
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Following code is to upgrade the contract at later time
  const previousIteration = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

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