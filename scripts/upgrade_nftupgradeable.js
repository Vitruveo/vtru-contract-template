const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

// npx hardhat run --network testnet scripts/upgrade_nftupgradeable.js 

async function main() {
  const name="NFTUpgradeable";
  const network = hre.network.name.toLowerCase(); 
  const mainnetAddress = '0x0';
  const testnetAddress = '0x0';

  const Contract = await ethers.getContractFactory(name);
  const instance = network == 'mainnet' ? mainnetAddress.toLowerCase() : testnetAddress.toLowerCase();
  const contract = await upgrades.upgradeProxy(instance, Contract);
  await contract.waitForDeployment();
  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
   console.error(error);
   process.exitCode = 1;
 });