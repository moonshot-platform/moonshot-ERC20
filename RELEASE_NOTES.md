# Moonshot v2 0x5298ad82dd7c83eeaa31dda9deb4307664c60534

The moonshot token is migrating to V2

Old address: 0xd27d3f7f329d93d897612e413f207a4dbe8bf799
New address: 0x5298ad82dd7c83eeaa31dda9deb4307664c60534

## Why Migration

1. The upgrade to V2 allows us more autonomy over the liquidity pool and takes us away from V1 completely
2. We can offer enhanced security and remove the BitMart Hacker from the holder's list
3. We can resolve issues in the existing smart contract

## How to migrate your Moonshot

You can claim your Moonshot V1 balance as Moonshot V2 here: https://project-moonshot.me/moonswap

## Benefits of the Migration

Below follow a list of changes compared to the old Moonshot contract deployed at 0xd27d3f7f329d93d897612e413f207a4dbe8bf799

### Token Symbol "MSHOT"

The token symbol was changed from MOONSHOT to MSHOT 

### Enhanced Security

Moonshot can be more "reactive" to threats because of the ability to blacklist addresses.

### Liquidity

Adding to the Liquidity Pool generates LP tokens. These tokens accumulate over time in the owner's wallet (Deployer) and pose a risk to the project.
The Moonshot V2 contract changes that; The LP tokens will accumulate in the contract instead and a removeLiquidity function was added that allows
the owner to remove at most 10% of the liquidity every 4 weeks.

### Buy Back mechanism

The token contract has an optional buy back mechanism. When the contract buys Moonshot V2, the tokens are sent to the NULL address.

### Fee Mechanism

The total fees are the same as the old contract, but now the 6% reserved for adding to the Liquidity Pool was reduced to 3% and the remaining 3% is
sent directly to the team wallet to support the project's development / marketing costs . 

Old Fee structure: 4/6  (4% reflection, 6% LP )
New Fee stucture: 4/3/3 (4% reflection, 3% LP , 3% dev/marketing )

Fees cannot be set higher than 10% in total

Fees can be set with 2 decimal precision.

### Upgradable

The addresses for the Pancake Router and Pancake pair can be upgraded

### Set Max TX Amount

This function was removed

### Rescue BNB

BNB sent to the contract by mistake may be rescued. 


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

