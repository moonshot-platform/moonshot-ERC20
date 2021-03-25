const Moonshot = artifacts.require( "Moonshot" );

module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();
      const presale_addr = '';
      const router_addr = '';

      console.log("Moonshot at ", m.address);

      await m.excludeFromFee( presale_addr );
      await m.excludeFromFee( router_addr );

      await m.setLiquidityFeePercent( 0 );
      await m.setMaxTxPercent( 100 );
      await m.setSwapAndLiquifyEnabled( false );
      await m.setTaxFeePercent( 0 );
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
