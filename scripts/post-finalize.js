const Moonshot = artifacts.require( "Moonshot" );


module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();

      console.log("Moonshot at ", m.address);

      
      // set moonshot fund address
      await m.setMoonshotFundAddress("0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864");
      await m.excludeFromFee("0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864");
      
      // set fees
      await m.setFees( 4, 3, 2);

      // enable swap and liquify
      await m.setSwapAndLiquifyEnabled( true );



      // open trading
      await m.unpause();

 
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
