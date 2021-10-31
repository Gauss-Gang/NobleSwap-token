# Gauss(GANG) README
![gg - strands@4x](https://user-images.githubusercontent.com/85713806/138234841-06c4116b-0fa7-432d-9d24-f1fcdc65b30a.png)
### ****CROWDSALE NOVEMBER 1st ****

## Project Overview

Gauss Gang, a Tokenized Ecosystem To Serve The Evolving Needs Of Any Brand.

**Website:** [gaussgang](https://gaussgang.com)

**Litepaper:** [webview](https://gaussgang.com/documentation/), [download](https://cutt.ly/JEEFrRD)

<br />All necessary and related files for the Gauss(GANG) Token, it's Vault, and Crowdsale are located within the “[GaussGANG-Token](https://github.com/Gauss-Gang/GaussGANG-Token)” GitHub repository.

- [audits](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/audits "audits")/:  contains audits for the main GaussGANG, GaussVault, and GaussCrowdsale contracts.

- [contracts](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/contracts "contracts")/: contains the solidity smart contracts and their dependencies for the initial Gauss Ecosystem.

     --[dependencies](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/contracts/dependencies "dependencies")/: contains [access controls](https://github.com/Gauss-Gang/GaussGANG-Token/tree/main/contracts/dependencies/access "access") , [contracts](https://github.com/Gauss-Gang/GaussGANG-Token/tree/main/contracts/dependencies/contracts "contracts"), [interfaces](https://github.com/Gauss-Gang/GaussGANG-Token/tree/main/contracts/dependencies/interfaces "interfaces"), [libraries](https://github.com/Gauss-Gang/GaussGANG-Token/tree/main/contracts/dependencies/libraries "libraries"), [security extensions](https://github.com/Gauss-Gang/GaussGANG-Token/tree/main/contracts/dependencies/security "security"), and [utilities](https://github.com/Gauss-Gang/GaussGANG-Token/tree/main/contracts/dependencies/utilities "utilities") that are used by the main GaussGANG, GaussVault, and GaussCrowdsale smart contracts.

     --[token](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/contracts/token "token"):/ contains GaussGANG, GaussVault, and GaussCrowdsale contracts.

     --[upgrades](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/contracts/upgrades "upgrades"):/ currently contains a template for GaussV2 to build off as well as to test the upgrade functionality.

- [flattenedContracts](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/flattenedContracts "flattenedContracts")/: contains the flattened versions of the main smart contracts, containing all dependencies in each contract.

- [scripts](https://github.com/Gauss-Gang/GaussGANG-Token/tree/devMain/scripts "scripts")/: contains scripts to deploy, interact, and upgrade the main smart contracts.
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

## Project Introduction

  The Gauss ecosystem will be a frontrunner regarding token design for brands. End users of these tokens will be able to connect with the brand on a deeper level. We’re creating a unified experience for users to engage with brands, and for brands to engage with their audience. The core Gauss Gang service is token design for brands of a variety of sizes as these brands don’t have the in-house expertise or processes to be able to efficiently and effectively develop tokens. Gauss Gang enables brands to create tokens by collaborating with their team, then we’ll launch them into a powerful ecosystem complete with broad and deep functionality. GANG will begin as a token on the Binance Smart Chain (BSC). The logic behind this step is to catapult our user base around the time of the initial offering phase. Prompt adoption has a considerable impact on success rates when using existing blockchains rather than new blockchains.

  Our next step is to build our own blockchain, along with the necessary supporting tools. Following that, we’ll migrate from BSC, launching tokens for our first partners immediately following migration. Partners will be able to use their own branded token for contests, reward programs, ecommerce, fundraising, and many other use cases. Branded tokens will be tailored to fit the needs of each brand partner. We will also design, with brands' goals in mind, and encourage our partners to think creatively about how they use their token through a collaborative effort. Gauss Gang will work alongside each partner to
develop tokenomics that fit their brand’s defined objectives. Certain fundamentals will be upheld across all partners’ tokens,
ensuring the health of the ecosystem overall, but ultimate ownership is in the hands of partners allowing for a great deal of freedom.

  Gauss Gang will continually work alongside partners, building upon, promoting, and growing their status after their token has been launched. Our partnerships will not consist of short-term interactions only at their inception. Rather, we’re committed to the long haul, where our expertise will routinely be paired alongside our partners’ latest goals and strategies. Gauss will be run with dedication to building strong, lasting relationships with our partners. Furthermore, we will regularly improve the use cases of new and existing tokens both in terms of compatibility and general acceptance by global consumers and also for specifically-researched audiences.

## Tokenomics

The total supply of GANG will be fully minted upon it's launch and then distributed to multiple wallets, each representing the different pools listed in the image below. Each wallet and smart contract address will be disclosed and annotated to show what each will be used for. These tokens will have time locked schedules via smart contract, only unlocking based on the published release schedule.


![pieChartWhiteLetterTransparent](https://user-images.githubusercontent.com/85713806/138248092-d899d37a-fcdb-4d08-ad23-0f1ccd9fb9c0.png)

![distribution](https://user-images.githubusercontent.com/85713806/138243992-d82e912f-54cb-44fa-983a-022c4d4bce0e.PNG)

---

### Components of the Transaction Fee

GANG’s transaction fee is broken down into four parts to secure the future of Gauss. A 12% ceiling is placed on the transaction fee,  therefore never raising above 12% with plenty of room to lower over time. Transaction fees aid us when it comes to maintaining the Gauss ecosystem. It will provide for validation rewards and help the company to blossom as time progresses. Gauss has chosen to use a transaction fee, instead of a ‘mint and burn’ or other inflationary/deflationary methods.

![transaction fee](https://user-images.githubusercontent.com/85713806/138243848-23b8b0a3-ee3a-418a-844c-903d7bf56266.PNG)

#### Redistribution
Many projects include redistribution within their tokenomics as a way to pull in
early adopters and reward holders; this is similar to how a number of projects use token burning or other
deflationary methods. Our system was built to reward holders and mitigate
volatility. GANG will place more weight in the wallets of smaller holders with our
redistribution methods - incentivizing more to participate, even at small amounts.

#### Liquidity
Larger liquidity pools make for more stable ecosystems and allow for more expansions
(into new pairings and exchanges). As such, we are allocating a quarter of our
transaction fees to building liquidity pools as well as paying staking rewards in
the future.

#### Charitable Fund
To help support the growth of communities, entrepreneurs, and creators, 6% of our
GANG tokens (15M tokens) will be allocated to the creation and sustainability of
a charity fund. This charitable fund will give grants, scholarships, and other forms
of financial assistance to aspiring entrepreneurs, artists, researchers, and the wider
community in the hopes of building a better future for generations to come. A quarter
of our transaction fees will add to this pool, maintaining this aspect of our goals
long term.

#### Company Funds
A portion of the transaction fees will fund Gauss Gang’s operations, development, and
marketing. Individual pools will be allocated for each area and will be replenished via
transaction fees.
