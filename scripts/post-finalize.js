const Moonshot = artifacts.require( "Moonshot" );


module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();

      console.log("Moonshot at ", m.address);

      // open trading
      await m.unpause();

      console.log( "Trading is open" );
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
