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
  const stakingContract = await StakingContract.deploy("0xf918A372cA3eC2159a14edEE36D43628612E39F7", "0xE9BabD3d55b0304819b8E8b05Ff0b40Bb6c31D50");
  await stakingContract.deployed();
  console.log("StakingContract address:", stakingContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
