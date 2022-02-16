const Moonshot = artifacts.require( "Moonshot" );

module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();

      // prepare airdrop 
      await m.setSwapAndLiquifyEnabled( false );
      await m.setFees( 0 ,0 ,0 );

      // halt trading except for owner
      await m.pause();
      
      // run airdrop is not here
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
