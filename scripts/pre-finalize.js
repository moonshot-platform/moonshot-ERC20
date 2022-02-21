const Moonshot = artifacts.require( "Moonshot" );
const ClaimMoonshot = artifacts.require( "ClaimMoonshot" );
const BuyMoonshot = artifacts.require( "BuyMoonshot" );

module.exports = async function(callback) {
  try {
        
      const m = await Moonshot.deployed();
      const a = await ClaimMoonshot.deployed();
      const t = await BuyMoonshot.deployed();

      console.log("Moonshot at ", m.address);
      console.log("ClaimMoonshot at ", a.address);
      console.log("Buy contract at ", t.address);

      // set moonshot fund address and exclude from fee
      await m.setMoonshotFundAddress("0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864");
      await m.setFee("0x9d8a5d6B405c2Eb7cee724F4B2F67a902F0f0864", 0, true);
 
      // bitmart hotwallet
      await m.setFeeForAddress( "0x328130164d0F2B9D7a52edC73b3632e713ff0ec6", 0);
      await m.excludeFromReward( "0x328130164d0F2B9D7a52edC73b3632e713ff0ec6" );

      // exclude hotbit wallet
      await m.setFeeForAddress( "0xc7029e939075f48fa2d5953381660c7d01570171", 0);
      await m.excludeFromReward( "0xc7029e939075f48fa2d5953381660c7d01570171");

      // latoken
      await m.setFeeForAddress( "0xCE55977E7B33E4e5534Bd370eE31504Fc7Ac9ADc",0 );
      await m.excludeFromReward( "0xCE55977E7B33E4e5534Bd370eE31504Fc7Ac9ADc" );

      // p2pb2b
      await m.setFeeForAddress( "0x5be909E0D204A94cc93fc9D7940584B5EC59e618",0 );
      await m.excludeFromReward( "0x5be909E0D204A94cc93fc9D7940584B5EC59e618" );

      // moonshot
      await m.setFeeForAddress( "0x66A7B9f608378e59105022aB00b0F541666e8c4d", 0);
      await m.excludeFromReward( "0xe539958C08477B8EaBE2290e8E06dc657102572D");
 
      // whitelist moonshot claim contract
      await m.excludeFromReward( a.address );
      // users that claim are not subject to fee
      await m.setFee( a.address, 0, true );

      // set to token contract address in claim contract
      await a.setToTokenAddress( m.address );
      // set from token contract address in claim contract
      await a.setFromTokenAddress( "0xd27d3f7f329d93d897612e413f207a4dbe8bf799" );
     
      // add bitmart hacker to blacklist of claim contract
      await a.addToBlackList( "0x25fb126B6c6B5c8EF732b86822fA0F0024E16C61" );
      
      

      // set token address in buy contract
      await t.setTokenAddress( m.address );
      // set fee enabled in buy contract (0.5%)
      await t.setFeeEnabled( true );



      console.log("Add Liquidity, Burn and Fund Claim contract");
  }
  catch( error ) {
      console.log(error);
  }

  callback();
}
