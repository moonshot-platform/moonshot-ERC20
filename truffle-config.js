require('dotenv').config();
const HDWalletProvider = require("truffle-hdwallet-provider");


module.exports = {
  mocha: {
    enableTimeouts: false,
  },
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "1",
      gasPrice: 0,
      gas: 6000000,
    },
    test: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "2"
    },
    bsctestnet: {
        provider: () => new HDWalletProvider( process.env.PRIVKEY, 'https://data-seed-prebsc-1-s1.binance.org:8545' ),
            network_id: 97,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true
    },
    ropsten: {
        provider: () => new HDWalletProvider( process.env.PRIVKEY, process.env.ROPSTEN_URL ),
            network_id: 3,
            confirmation: 10,
            timeoutBlocks: 200,
            skipDryRun: true
    },
    bsc: {
        provider: () => new HDWalletProvider( process.env.PRIVKEY, 'https://bsc-dataseed1.binance.org'),
            network_id: 56,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true
    }
  },
  plugins: [
      'truffle-plugin-verify'
  ],
  api_keys: {
      bscscan: process.env.APIKEY,
      etherscan: process.env.ETHERSCAN_APIKEY
  },

  compilers: {
    solc: {
      version: "0.6.12",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};
