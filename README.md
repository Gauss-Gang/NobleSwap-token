# NobleSwap Token (NOBLE) README

![gg - strands@4x](https://user-images.githubusercontent.com/85713806/138234841-06c4116b-0fa7-432d-9d24-f1fcdc65b30a.png)

## Project Overview


**Website:** [gaussgang](https://gaussgang.com)

**Litepaper:** 

<br />All necessary and related files for the NobleSwap Token are located within the “[NobleSwap-token](https://github.com/Gauss-Gang/NobleSwap-token)” GitHub repository.

- [audits](https://github.com/Gauss-Gang/NobleSwap-token/tree/devMain/audits "audits")/:  contains audits for the main NobleSwap contract.

- [contracts](https://github.com/Gauss-Gang/NobleSwap-token/tree/devMain/contracts "contracts")/: contains the solidity smart contracts and their dependencies for the NobleSwap Token.

     --[dependencies](https://github.com/Gauss-Gang/NobleSwap-token/devMain/contracts/dependencies "dependencies")/: contains [access controls](https://github.com/Gauss-Gang/NobleSwap-token/tree/main/contracts/dependencies/access "access") , [contracts](https://github.com/Gauss-Gang/NobleSwap-token/tree/main/contracts/dependencies/contracts "contracts"), [interfaces](https://github.com/Gauss-Gang/NobleSwap-tokenv/tree/main/contracts/dependencies/interfaces "interfaces"), [libraries]https://github.com/Gauss-Gang/NobleSwap-token/tree/main/contracts/dependencies/libraries "libraries"), [security extensions](https://github.com/Gauss-Gang/NobleSwap-token/tree/main/contracts/dependencies/security "security"), and [utilities]https://github.com/Gauss-Gang/NobleSwap-token/tree/main/contracts/dependencies/utilities "utilities") that are used by the main NobleSwap smart contract.

     --[token](https://github.com/Gauss-Gang/NobleSwap-token/tree/devMain/contracts/token "token"):/ contains NobleSwap contract.

     --[upgrades](https://github.com/Gauss-Gang/NobleSwap-token/tree/devMain/contracts/upgrades "upgrades"):/ currently contains a template for Noble_v2 to build off as well as to test the upgrade functionality.

- [flattenedContracts](https://github.com/Gauss-Gang/NobleSwap-token/tree/devMain/flattenedContracts "flattenedContracts")/: contains the flattened versions of the main smart contracts, containing all dependencies in each contract.

- [scripts](https://github.com/Gauss-Gang/NobleSwap-token/tree/devMain/scripts "scripts")/: contains scripts to deploy, interact, and upgrade the main smart contracts.
---

#### Deployment & Installation:

This project can be compiled, tested, deployed, and interacted with by using [Hardhat](https://hardhat.org/getting-started/#overview) in conjunction with the [OpenZeppelin Upgrades Plugin](https://docs.openzeppelin.com/upgrades-plugins/1.x/hardhat-upgrades).
 - After installation of Hardhat and OpenZeppelin's Upgrades plugin, try running some of the following tasks:

```shell
# To deploy token ecosystem on a local test node, run the following commmands: 
npx hardhat local-testnet 
//open a new terminal window after the node launches
npx hardhat deploy:local 

# Hardhat built-in tasks
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
```
