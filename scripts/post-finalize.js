const Moonshot = artifacts.require( "Moonshot" );


module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();

      console.log("Moonshot at ", m.address);

      await m.setLiquidityFeePercent( 6 );
      await m.setTaxFeePercent( 4 );
      await m.setSwapAndLiquifyEnabled( true );
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
