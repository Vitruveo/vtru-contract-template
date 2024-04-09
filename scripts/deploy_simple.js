const { ethers } = require("hardhat");

// npx hardhat run --network testnet scripts/deploy_simple.js 

async function main() {
  const name = "Simple"
  const Contract = await ethers.getContractFactory(name);
  const contract = await Contract.deploy();
  await contract.waitForDeployment();
  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});