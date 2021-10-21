// Upgrades Gauss GANG Token using UUPS Proxy.
const { ethers, upgrades } = require("hardhat");

async function main() {

  // Following code is to upgrade the contract to a new version.
  // Enter ADDRESS of previous interationt and the contract name of the new version before running scrip.
  const previousIteration = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const newContractName = "GaussV2_Template";


  // Gauss(GANG) must be paused before it can be upgraded.
  const GaussGANG = await ethers.getContractFactory("GaussGANG");
  const gaussV1 = await GaussGANG.attach(previousIteration);
  await gaussV1.pause();
  console.log("GaussGANG Transactions paused...");


  // Grabs the new version and deploys it using the UUPS Proxy.
  const GaussV2 = await ethers.getContractFactory(newContractName);
  console.log('Deploying Gauss GANG Upgrade...');
  const upgraded = await upgrades.upgradeProxy(previousIteration, GaussV2);
  console.log("Gauss GANG Upgrade deployed to:", upgraded.address);


  // This unpauses transactions after the deployment of the Upgraded Contract.
  await upgraded.unpause();
  console.log("GaussV2 Transactions unpaused...");


  // This is used to test the template upgrade contract.
  await upgraded.initializeUpgrade();
  const templateVariable = await upgraded.getSample();
  console.log("GaussV2 Template Variable:", templateVariable);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
