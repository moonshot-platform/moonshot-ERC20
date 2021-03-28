const Moonshot = artifacts.require( "Moonshot" );

module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();

   // BSC Mainnet
      const presale_addr = '0x17FeeE0ab7711870b92F142D89b7B8f1d495E740';
      const router_addr = '0xd27D3F7f329D93d897612E413F207A4dbe8bF799';

   // Ropsten testnet https://dxsale.app/app/pages/defipresale?saleID=67
   // const presale_addr = '0x12712a497EE07348A052D777Ca9D8D0DE7f0B63e';
   // const router_addr = '0x35e98f06Ba72e76e13DE830d273f98ad543c685a';

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
