const Moonshot = artifacts.require( "Moonshot" );


module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();

    
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
