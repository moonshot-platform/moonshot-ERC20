require( 'dotenv' ).config();

const token = artifacts.require("Moonshot");
const drop = artifacts.require("DropMoonshot");

const migration = async function( deployer, network, accounts ) {
        await Promise.all([
                deployContracts(deployer,network,accounts),
        ]);
};

module.exports = migration;

async function deployContracts(deployer,network,accounts) {
        const moonshot = await deployer.deploy(token);
        const airdrop = await deployer.deploy(drop);
}
