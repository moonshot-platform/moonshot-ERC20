# Project Moonshot

Feel free to read the code.

## Overview of Contracts 

### Moonshot.sol BEP20 token

Deflationary, Frictionless yield and liquidity generation protocol. Simply hold Moonshot in your wallet and gain rewards when others transfer.

The contract takes a 10% fee:
 - 4% is redistributed to all holders
 - 4% is added to the V2 LP pool
 - 2% is added to the Moonshot support fund

Notes:
- The contract contains functions for the owner to blacklist addresses and to pause the transfer() function
- Tokens sent to the contract can be rescued
- There is no max TX amount and the total fees can be set to at most 10%
- The router can be upgraded

### ClaimMoonshot.sol

Contract that sends MoonshotV2 to the caller if the caller has a positive Moonshot balance. The caller can only claim once.

Notes:
- The contract contains functions for the owner to black list addresses
- The contract contains a function for the owner to burn the token's MoonshotV2 balance 
- The contract contains a function to rescue BNB
- The contract contains no functions to withdraw the balance of a BEP20 token

### BuyMoonshot.sol

Contract that sends MoonshotV2 to the caller upon receiving BNB.
A 0.5% fee is deducted from the BNB received to do a market buy of the Moonshot V2 token using the pancakeswap V2 Router

Notes:
- The contract contains a function to enable or disable the fee
- The contract contains a function to set the fee to at most 2%
- The contract contains functions to update token contract addresses
- The contract contains a function to withdraw BNB
- The contract contains a function to withdraw BEP20 tokens

## Setting up your workspace

1. run 'npm install' in your workspace
2. run Ganache and setup a workspace
3. run 'npm test' in your workspace

### Deploying locally

For testing:
1. run 'npx ganache-cli --deterministic --allowUnlimitedContractSize --networkId 2'
2. run 'npx truffle migrate --network test'

For development:
1. run 'npx ganache-cli --deterministic --allowUnlimitedContractSize --networkId 1 -p 7545'
2. run 'npx truffle migrate --network develop'

## Deploying on Smart Chain Testnet 

0. Create a wallet and get some BNB from the faucet: https://testnet.binance.org/faucet-smart
1. Copy secrets.env.template to secrets.env and set values
2. Run 'npx truffle compile'
3. Run 'npx truffle migrate --network bsctestnet'
4. Smart contract should now be deployed.
5. Verify the contract
6. Run 'npx truffle run verify moonshot@0x0000TOKENADDRES0000 --network bsctestnet

## Running scripts

To configure the contract instances for use, you can run the files in scripts/ 

0. Run 'npx truffle exec scripts/pre-finalize.js --network bsctestnet'



## License

WTFPL
