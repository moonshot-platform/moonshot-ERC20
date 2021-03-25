require( 'dotenv' ).config();

const token = artifacts.require("Moonshot");

const migration = async function( deployer, network, accounts ) {
        await Promise.all([
                deployToken(deployer,network,accounts),
        ]);
};

module.exports = migration;

async function deployToken(deployer,network,accounts) {
        const moonshot = await deployer.deploy(token);
}
