// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");

async function main() {
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
        "gets automatically created and destroyed every time. Use the Hardhat" +
        " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

//  const Wistaverse = await ethers.getContractFactory("Wistaverse");
//  const wistaverse = await Wistaverse.deploy();
//  await wistaverse.deployed();
//  console.log("Wistaverse address:", wistaverse.address);

//  const Wistake = await ethers.getContractFactory("Wistake");
//  const wistake = await Wistake.deploy();
//  await wistake.deployed();
//  console.log("Wistake address:", wistake.address);

  const StakingContract = await ethers.getContractFactory("StakingContract");
  const stakingContract = await StakingContract.deploy("0xB7042C40De76CFc607aC05e68F9C28A778F0C8a6", "0x376D7A04BE9CD5c932A1B177801f2ff88A46a3E8", 0);
  await stakingContract.deployed();
  console.log("StakingContract address:", stakingContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
