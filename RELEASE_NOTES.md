# Moonshot v2 DRAFT

The moonshot token is migrating to V2

## Why Migration

1. The upgrade to V2 allows us more autonomy over the liquidity pool and takes us away from V1 completely
2. We can offer enhanced security and remove the BitMart Hacker from the holder's list
3. We can resolve issues in the existing smart contract

## How to "Swap" your Moonshot

When the token has deployed a Claim button will be available on https://project-moonshot.me  that allows you to claim your new Moonshot v2 tokens.


## Benefits of the Migration

ChangeLog of the changes compared to the old Moonshot contract deployed at 0xd27d3f7f329d93d897612e413f207a4dbe8bf799


### Token Symbol "MSHOT"

The token symbol was changed from MOONSHOT to MSHOT 

### Enhanced Security

Moonshot can be more "reactive" to threats because of the ability to blacklist addresses.

### Liquidity

Adding to the Liquidity Pool generates LP tokens. These tokens accumulate over time in the owner's wallet (Deployer) and pose a risk to the project.
This token contract changes that; The LP tokens will accumulate in the contract address instead and a removeLiquidity function was added that allows
the owner to remove at most 10% of the liquidity every 4 weeks.

### Buy Back mechanism

The contract will accumulate BNB and execute buy-and-transfer or buy-and-burn transactions

### Fee Mechanism

The total fees are the same as the old contract, but now the 6% reserved for adding to the Liquidity Pool has changed
to 4% ,  1.5% and 0.5% to support the project's development and marketing costs and buy back mechanism.

Old Fee structure: 4/6  (4% reflection, 6% LP )
New Fee stucture: 4/4/2 (4% reflection, 3% LP , 1.5% dev, 0.5% buyback )

Fees cannot be set higher than 10% in total

Fees can be set with 2 decimal precision.

### Upgradable

The addresses for the Pancake Router and Pancake pair can be upgraded

### Set Max TX Amount

This function was removed

### Rescue BNB

BNB sent to the contract by mistake can be rescued


### Smaller changes

- Each function that changes the state of the contract emits an event to be recorded on chain
- Declared functions external where possible to reduce gas cost
- Resolved "Temporary Ownership Renounce" vulnerability 
- Resolved frictionless yield bug
- Removed not needed function 'deliver'
- Removed unused contracts
- Declared some variables as constant
- Removed redundant code
- Fix excluded[] length problem
- Fixed incorrect error messages 
- Naming things, fixed typos


https://github.com/moonshot-platform/moonshot-ERC20/blob/removeLiquidity/RELEASE_NOTES.md