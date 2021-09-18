// Allows one to interact with already deployed contract
const { ethers, upgrades } = require("hardhat");

async function main() {

    // Following code is to use the contract at the deployed address
    const deplyedAddress = "0xFC5bE805c952f78661aE32703c4e0f8f8C6Bcd2E";
    const GaussGANG = await ethers.getContractFactory("GaussGANG");
    const contract = await GaussGANG.attach(deplyedAddress);


/**** The next block of code is specific for the GaussGANG Token itself ****\
            (Does not contain the BEP20 standard function calls)           
            To use, uncomment the call, or calls, you wish to use           */


        // Checks the current total Transaction Fee
        const transactionFee = await contract.totalTransactionFee();
        console.log("GaussGANG Transaction Fee:", transactionFee);

        // Changes the Transaction Fee to a new int (must change the numbers passed in below)
    //    await contract.changeTransactionFees(3,3,3,3);
    //    const newFees = await contract.totalTransactionFee();
    //    console.log("GaussGANG New Transaction Fee:", newFees);


        // Checks the current redistributionFee
        const redistributionFee = await contract.redistributionFee();
        console.log("GaussGANG redistributionFee:", redistributionFee);

        // Checks current address for redistributionWallet
    //    const redistributionWallet = await contract.redistributionWallet();
    //    console.log("GaussGANG redistributionWallet address:", redistributionWallet);

        // Changes the current Redistribution Wallet address (must add in the new address to the variable created below)
    //    const newRedistributionAddress = "";
    //    await contract.changeRedistributionWallet(newRedistributionAddress);
    //    console.log("GaussGANG new redistributionWallet address:", await contract.redistributionWallet());


        // Checks the current charitableFundFee
        const charitableFundFee = await contract.charitableFundFee();
        console.log("GaussGANG charitableFundFee:", charitableFundFee);

        // Checks current address for charitableFundWallet
    //    const charitableFundWallet = await contract.charitableFundWallet();
    //    console.log("GaussGANG charitableFundWallet address:", charitableFundWallet);

        // Changes the current Charitable Fund Wallet address (must add in the new address to the variable created below)
    //    const newCharitableAddress = "";
    //    await contract.changeCharitableWallet(newCharitableAddress);
    //    console.log("GaussGANG new charitableFundWallet address:", await contract.charitableFundWallet());


        // Checks the current liquidityFee
        const liquidityFee = await contract.liquidityFee();
        console.log("GaussGANG liquidityFee:", liquidityFee);

        // Checks current address for liquidityWallet
    //    const liquidityWallet = await contract.liquidityWallet();
    //    console.log("GaussGANG liquidityWallet address:", liquidityWallet);

        // Changes the current Liquidity Wallet address (must add in the new address to the variable created below)
    //    const newLiquidityAddress = "";
    //    await contract.changeLiquidityWallet(newLiquidityAddress);
    //    console.log("GaussGANG new Liquidity Wallet address:", await contract.liquidityWallet());


        // Checks the current ggFee
        const ggFee = await contract.ggFee();
        console.log("GaussGANG ggFee:", ggFee);

        // Checks current address for ggWallet
    //    const ggWallet = await contract.ggWallet();
    //    console.log("GaussGANG ggWallet address:", ggWallet);

        // Changes the current ggWallet address (must add in the new address to the variable created below)
    //    const newGGWalletAddress = "";
    //    await contract.changeGaussGangWallet(newGGWalletAddress);
    //    console.log("GaussGANG new ggWallet address:", await contract.ggWallet());


        // Checks current address for internalDistributionWallet
    //    const internalDistributionWallet = await contract.internalDistributionWallet();
    //    console.log("GaussGANG internalDistributionWallet address:", internalDistributionWallet);

        // Changes the current internalDistributionWallet address (must add in the new address to the variable created below)
    //    const newInternalDistributionAddress = "";
    //    await contract.changeInternalDistributionWallet(newInternalDistributionAddress);
    //    console.log("GaussGANG new internalDistributionWallet address:", await contract.internalDistributionWallet());


        // Creates Snapshot of current balances
    //    const snapShotID = await contract.snapshot();
    //    console.log("GaussGANG Snapshot ID:", snapShotID);

        // Allows owner to Pause all Transfers
    //    await contract.pause();
    //    console.log("GaussGANG Transactions paused...");

        // Allows owner to Unpause all Transfers
    //    await contract.unpause();
    //    console.log("GaussGANG Transactions unpaused...");



/**** The next block of code is specific for BEP20 Tokens that Gauss GANG Inherits ****\
                    (Contains BEP20 Specific functions calls)
                To use, uncomment the call, or calls, you wish to use                 */


        // Returns the name of the BEP20 Token
    //    const name = await contract.name();
    //    console.log("BEP20 Token Name:", name);

        // Returns the symbol of the BEP20 Token
    //    const symbol = await contract.symbol();
    //    console.log("BEP20 Token symbol:", symbol);

        // Returns the decimals of the BEP20 Token
    //    const decimals = await contract.decimals();
    //    console.log("BEP20 Token decimals:", decimals);

        // Returns the totalSupply of the BEP20 Token
    //    const totalSupply = await contract.totalSupply();
    //    console.log("BEP20 Token totalSupply:", totalSupply);


        // Returns the balance of the address entered below
    //    const address = "";
    //    const balance = await contract.balanceOf(address);
    //    console.log("Balance of entered address:", balance);

        // Returns the allowance of the owner and spender addresses entered below
    //    const owner = "";
    //    const spender = "";
    //    const allowance = await contract.allowance(owner,spender);
    //    console.log("Allowance of entered addresses:", allowance);

        // Increases the allowance of the spender address by the amount entered below
    //    const spender = "";
    //    const amount = "";
    //    const success = await contract.increaseAllowance(spender,amount);
    //    console.log("Increase Allowance was:", success);
        
        // Decreases the allowance of the spender address by the amount entered below
    //    const spender = "";
    //    const amount = "";
    //    const success = await contract.decreaseAllowance(spender,amount);
    //    console.log("Decrease Allowance was:", success);

        // Approves the allowance of the spender address by the amount entered below
    //    const spender = "";
    //    const amount = "";
    //    const success = await contract.approve(spender,amount);
    //    console.log("Approve Allowance was:", success);


        // Transfers an amount of tokens to the recipient address entered below
    //    const recipient = "";
    //    const amount = "";
    //    const success = await contract.transfer(recipient,amount);
    //    console.log("Transfer was:", success);

        // Transfers an amount of tokens from the sender address to the recipient address entered below
    //    const sender = "";
    //    const recipient = "";
    //    const amount = "";
    //    const success = await contract.transferFrom(sender,recipient,amount);
    //    console.log("Transferfrom was:", success);
}    

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });