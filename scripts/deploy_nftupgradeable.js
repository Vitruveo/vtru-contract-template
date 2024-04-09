const { ethers, upgrades } = require("hardhat");

// npx hardhat run --network testnet scripts/deploy_nftupgradeable.js 

async function main() {
  const name = "NFTUpgradeable"
  const Contract = await ethers.getContractFactory(name);
  const contract = await upgrades.deployProxy(Contract, {initializer: 'initialize'});
  await contract.waitForDeployment();
  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });