const Moonshot = artifacts.require( "Moonshot" );
const DropMoonshot = artifacts.require( "DropMoonshot" );

module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();
      const a = await DropMoonshot.deployed();

      console.log("Moonshot at ", m.address);
      console.log("DropMoonshot at ", a.address);


      // prepare airdrop 
      await m.setSwapAndLiquifyEnabled( false );
      await m.setFees( 0 ,0 ,0 );

      // halt trading except for owner
      await m.pause();
    
      // whitelist airdrop contract
      await m.excludeFromReward( a.address );
      await m.excludeFromFee( a.address );

      // set To
      await a.setToTokenAddress( m.address );
q
      // add bitmart hacker to blacklist
      await a.addToBlackList( "0x25fb126B6c6B5c8EF732b86822fA0F0024E16C61" );

      // set From
      await a.setFromTokenAddress( "0xd27d3f7f329d93d897612e413f207a4dbe8bf799" );
      //TestNet: await a.setFromTokenAddress( "0x4032bA66D4820229ce73cB026DFDD0E6F40822A8");


  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
