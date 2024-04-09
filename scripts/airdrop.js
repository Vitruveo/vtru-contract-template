const { ethers } = require("hardhat");
const hre = require("hardhat");
require('dotenv').config();

async function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}

(async () => {
    const DECIMALS = 18;
    const name="NFT";
    const network = hre.network.name.toLowerCase(); 
    const mainnetAddress = '0x0';
    const testnetAddress = '0xE4C45C8534E060D154C32c4ab96c2aa42543214f';
    const isTestNet = network === 'testnet' ? true : false;
    const contractAddress = isTestNet ? testnetAddress : mainnetAddress;

    const Contract = await ethers.getContractFactory(name);
    const contract = Contract.attach(contractAddress);

    let rest = 100;
    const holders = ['0x7CB34080016ca3e3E6DA144188457e47Aa73ef43', '0x27CBE72760a4342a6645FA0a432B68f1B7d7B91f', '0x5711b76F409B6abeC03Dc416340161dcB2FfE298'];
    for(let f=0;f<holders.length;f++) {
        const holder = holders[f];              
//        const amount = ethers.parseUnits(String(2000), DECIMALS); 

        try {
              await contract.grantNFT(
                (f % 3) + 1, //classId
                holder, //account
                Math.floor(Math.random() * 10) + 1, //random rarity 
                { value: 0 });
          }
          catch(e) {
              console.log(e)
          }
          
        await sleep(rest);
    }
})();
