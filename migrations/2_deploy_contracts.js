require( 'dotenv' ).config();

const token = artifacts.require("Moonshot");
const claim = artifacts.require("DropMoonshot");
const buy = artifacts.require("MoonshotTrader");

const migration = async function( deployer, network, accounts ) {
        await Promise.all([
                deployContracts(deployer,network,accounts),
        ]);
};

module.exports = migration;

async function deployContracts(deployer,network,accounts) {
     const moonshotContract = await deployer.deploy(token);
     const claimContract = await deployer.deploy(claim);
     const buyContract = await deployer.deploy(buy);
}
