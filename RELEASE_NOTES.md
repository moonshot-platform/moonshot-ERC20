# Moonshot v2

The moonshot token is migrating to V2

## How to "Swap" your Moonshot

When the token has migrated a Claim button will be available on https://project-moonshot.me  that allows you to claim your new Moonshot v2 tokens.

## Why Migration

1. The upgrade to V2 allows us more autonomy over the liquidity pool and takes us away from V1 completely
2. We can offer enhanced security and remove the BitMart Hacker from the holder's list

## Benefits of the Migration

ChangeLog of the changes compared to the old Moonshot contract deployed at 0xd27d3f7f329d93d897612e413f207a4dbe8bf799

### Token Symbol "MSHOT"

The token symbol was changed from MOONSHOT to MSHOT 

### Enhanced Security

Moonshot can be more "reactive" to threats because of the ability to blacklist addresses.

### Upgradable

The addresses for the Pancake Router and Pancake pair can be upgraded

### Set Max TX Amount

This function was removed

### Fee Mechanism

The total fees are the same as the old contract, but now the 6% reserved for adding to the Liquidity Pool has changed
to 4% and 2% to support the project's development and marketing costs.

Old Fee structure: 4/6  (4% reflection, 6% LP )
New Fee stucture: 4/4/2 (4% reflection, 3% LP , 2% dev )

Fees cannot be set higher than 10% in total

### Support for setting a fee per Address

A function was added that the owner can use to configure a special fee for an address. 

Fees cannot be set higher than 10% in total


### Smaller changes

- Each function that changes the state of the contract emits an event to be recorded on chain
- Declared functions external where possible to reduce gas cost
- Resolved "Temporary Ownership Renounce" vulnerability 
- Resolved frictionless yield bug
- Removed not needed function 'deliver'
- Declared some variables as constant
- Removed redundant code
- Fix excluded[] length problem
- Fixed incorrect error messages 
- Naming things, fixed typos 

