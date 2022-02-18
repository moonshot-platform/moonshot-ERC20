const Moonshot = artifacts.require( "Moonshot" );
const DropMoonshot = artifacts.require( "DropMoonshot" );
const MoonshotTrader = artifacts.require( "MoonshotTrader" );

module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();
      const a = await DropMoonshot.deployed();
      const t = await MoonshotTrader.deployed();

      console.log("Moonshot at ", m.address);
      console.log("DropMoonshot at ", a.address);
      console.log("Buy contract at ", t.address);

      // set moonshot fund address and exclude from fee
      await m.setMoonshotFundAddress("0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864");
      await m.excludeFromFee("0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864");

      // disable tokenomics and trading except for owner
      await m.setSwapAndLiquifyEnabled( false );
      await m.setFees( 0 ,0 ,0 );
      await m.pause();
    
      // whitelist moonshot claim contract
      await m.excludeFromReward( a.address );
      await m.excludeFromFee( a.address );

      // set to token contract address in claim contract
      await a.setToTokenAddress( m.address );

      // add bitmart hacker to blacklist of claim contract
      await a.addToBlackList( "0x25fb126B6c6B5c8EF732b86822fA0F0024E16C61" );

      // set from token contract address in claim contract
      await a.setFromTokenAddress( "0xd27d3f7f329d93d897612e413f207a4dbe8bf799" );
     
      // set token address in buy contract
      await t.setTokenAddress( m.address );

      console.log("Add Liquidity and Burn");
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
