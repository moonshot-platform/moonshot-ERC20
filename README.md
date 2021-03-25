# Project Moonshot

Deflationary, Frictionless yield and liquidity generation protocol. 
Simply hold Moonshot in your wallet and gain rewards when others transfer.

Feel free to read the code.

## Contract Address

The contract address is 0xd27d3f7f329d93d897612e413f207a4dbe8bf799 and deployed on Binance Smart Chain: https://bscscan.com/address/0xd27d3f7f329d93d897612e413f207a4dbe8bf799#code


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

0. Run 'npx truffle exec scripts/script.js --network bsctestnet'


## License

WTFPL
