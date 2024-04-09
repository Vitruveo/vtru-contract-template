const { ethers } = require("hardhat");
const hre = require("hardhat");
require('dotenv').config();


/// npx hardhat run --network testnet scripts/wallet_test.js 

async function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}

async function createAndFundWallets(fund, owner, count) {
    const mnemonic = process.env.MNEMONIC;
    const mnemonicInstance = ethers.Mnemonic.fromPhrase(mnemonic);
    const wallets = [];
    for (let w = 10; w < count + 10; w++) {
        const wallet = ethers.HDNodeWallet.fromMnemonic(mnemonicInstance, `m/44'/60'/0'/0/${w}`);
        wallets.push(wallet.connect(hre.ethers.provider));
        console.log('***', owner.address, wallet.address);
        if (fund) {
            await owner.sendTransaction({
                to: wallet.address,
                value: ethers.parseUnits('1.0', 18)
            });
        }
    }
    return wallets;
}


(async () => {
    const DECIMALS = 18;
    const network = hre.network.name;
    const isTestNet = network === 'testnet' ? true : false;
    const [owner, user1] = await ethers.getSigners();

    const wallets = await createAndFundWallets(true, owner, 50);
    const target = user1;
    const amount = ethers.parseUnits('0.0001', 18)
    let counter = 0;
    let backoff = 0;

    for (let loop = 0; loop < wallets.length; loop++) {
        counter++;
        try {
            let tx = {
                to: target,
                value: amount
            }
            const receipt = await wallets[loop].sendTransaction(tx);
            console.log(receipt);
            backoff = 0;
        } catch (e) {
            console.log(e);
            backoff += 2000;
            await sleep(backoff);
        }
        console.log(`Completed ${counter}`);
        await sleep(5000);
    }


})();

//     const trace = await hre.network.provider.send("debug_traceTransaction", [
//         "0xdeb3e4d96e7bf64bdeca238aca108138c4db62a2bf71e090f8fdf136517ffa6e",
//         {
//             tracer: "callTracer",
//           disableMemory: true,
//           disableStack: true,
//           disableStorage: true,
//         },
//     ])