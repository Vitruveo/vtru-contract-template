# vtru-contract-template

## IMPORTANT
nvm use 18

## Hardhat Commands

**Compile**
npx hardhat compile

**Start Local Node**
npx hardhat node

**Run Any Script**
npx hardhat run --network [network] scripts/[scriptName].js

**Run Test Script**
npx hardhat run test/[scriptName].js

**Run Deploy Script**
npx hardhat run --network [network] scripts/deploy.js

**Run Upgrade Script**
npx hardhat run --network [network] scripts/upgrade.js

**Run Flatten Script**
npx hardhat flatten contracts/[fileName].sol > flat/[fileName]_flat.sol

**Verify and Publish**
npx hardhat verify --contract contracts/[fileName].sol:[contractName] --network [network] 

**Mnemonic Used**
strong grace pretty bitter drum possible unlock abuse settle vote picture discover
[Mnemonic Code Converter](https://iancoleman.io/bip39/)