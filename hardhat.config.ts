import * as dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { HardhatUserConfig, task } from 'hardhat/config';
import 'hardhat-tracer';
import 'hardhat-deploy';
import 'hardhat-gas-reporter';
import 'hardhat-contract-sizer';
import 'hardhat-abi-exporter';
import 'hardhat-preprocessor';
import '@nomicfoundation/hardhat-verify';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import { HardhatConfig } from 'hardhat/types';
import { evmos, bsc, arbitrum, localhost, mainnet, polygon, polygonZkEvm, optimism, cronos } from '@wagmi/chains';

import readlineSync from 'readline-sync';

const networkInfos = require('@wagmi/chains');

const envPath = path.resolve(__dirname, '.env');
dotenv.config({ path: envPath });

const chainIdMap: { [key: string]: string } = {};
for (const [networkName, networkInfo] of Object.entries(networkInfos)) {
  // @ts-ignore
  chainIdMap[networkInfo.id] = networkName;
}

// function getRemappings() {
//   return fs
//     .readFileSync('remappings.txt', 'utf8')
//     .split('\n')
//     .filter(Boolean)
//     .map((line) => line.trim().split('='));
// }

// // Prevent to load scripts before compilation and typechain
// if (!SKIP_LOAD) {
//   ['deploy'].forEach((folder) => {
//     const tasksPath = path.join(__dirname, 'tasks', folder);
//     fs.readdirSync(tasksPath)
//       .filter((pth) => pth.includes('.ts'))
//       .forEach((task) => {
//         require(`${tasksPath}/${task}`);
//       });
//   });
// }

const DEFAULT_COMPILER_SETTINGS = {
  version: '0.8.19',
  settings: {
    viaIR: true,
    optimizer: {
      enabled: true,
      runs: 200,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
  overrides: {},
};

const mnemonic = process.env.MNEMONIC;

export default {
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
  },
  docgen: {
    outputDir: './docs',
  },
  paths: {
    sources: './src',
  },
  etherscan: {
    apiKey: `${process.env.ETHERSCAN_API_KEY}`,
    customChains: [
      {
        network: `${polygonZkEvm.id}`,
        chainId: polygonZkEvm.id,
        urls: {
          apiURL: 'https://api-zkevm.polygonscan.com/api',
          browserURL: 'https://zkevm.polygonscan.com',
        },
      },
      {
        network: 'scroll',
        chainId: 534352,
        urls: {
          apiURL: 'https://api.scrollscan.com/api',
          browserURL: 'https://scrollscan.com',
        },
      },
    ],
  },
  defaultNetwork: 'hardhat',

  networks: {
    hardhat: {
      // zksync: true,
      chainId: localhost.id,
      allowUnlimitedContractSize: true,
      blockGasLimit: 45000000,
      gas: 'auto',
      hardfork: 'london',
      // @ts-ignore
      // forking: {
      //   enabled: true,
      //   url: 'ARCHIVE_NODE_URL',
      // },
      mining: {
        auto: true,
        interval: 0,
        mempool: {
          order: 'fifo',
        },
      },
      accounts: {
        mnemonic: 'test test test test test test test test test test test junk',
        initialIndex: 0,
        count: 10,
        path: "m/44'/60'/0'/0",
        accountsBalance: '10000000000000000000000000000',
        passphrase: '',
      },
      // @ts-ignore
      minGasPrice: undefined,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      initialDate: new Date().toISOString(),
      loggingEnabled: false,
      // @ts-ignore
      chains: undefined,
      // forking: {
      //   // url: `https://polygon-mainnet-rpc.allthatnode.com:8545/${process.env.INFURA_API_KEY}`,
      //   // blockNumber: 15360000,
      //   url: process.env.POLYGON_URL,
      // },
    },
    zksync: {
      url: process.env.ETH_NODE_URI_ZKSYNC,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      chainId: 324,
      companionNetworks: {
        hub: 'mainnet',
      },
      zksync: true,
      ethNetwork: 'mainnet',
      verifyURL: 'https://zksync2-mainnet-explorer.zksync.io/contract_verification',
    },
    mainnet: {
      url: process.env.ETH_NODE_URI_MAINNET,
      chainId: mainnet.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },

    scroll: {
      url: process.env.ETH_NODE_URI_SCROLL,
      chainId: 534352,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
    polygon: {
      url: process.env.ETH_NODE_URI_POLYGON, // 'https://polygon-rpc.com',
      // url: 'https://polygon-rpc.com',

      chainId: polygon.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
    evmos: {
      url: process.env.ETH_NODE_URI_EVMOS,

      chainId: evmos.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
    neotest: {
      url: process.env.ETH_NODE_URI_NEOTEST,

      chainId: 2970385,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
    base: {
      url: process.env.ETH_NODE_URI_BASE,

      chainId: 8453,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
    cronos: {
      url: process.env.ETH_NODE_URI_CRONOS,
      chainId: cronos.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
    bsc: {
      url: process.env.ETH_NODE_URI_BSC,

      chainId: bsc.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },

    arbitrum: {
      url: process.env.ETH_NODE_URI_ARBITRUM,

      chainId: arbitrum.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },

    optimism: {
      url: process.env.ETH_NODE_URI_OPTIMISM,

      chainId: optimism.id,
      accounts: [`${process.env.DEPLOYER_PRIVATE_KEY}`],
      gas: 'auto',
      gasPrice: 'auto',
      gasMultiplier: 1,
      timeout: 3000000,
      httpHeaders: {},
      live: true,
      saveDeployments: true,
      tags: ['mainnet', 'prod'],
      companionNetworks: {},
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  zksolc: {
    version: '1.3.5',
    compilerSource: 'binary',
    settings: {},
  },
  // @ts-ignore
  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5',
  },
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
  abiExporter: [
    // @ts-ignore
    {
      path: './abi',
      runOnCompile: false,
      clear: true,
      flat: true,
      only: [],
      except: [],
      spacing: 2,
      pretty: false,
      filter: () => true,
    },
  ],
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true,
  },
  mocha: {
    timeout: 40000000,
    require: ['hardhat/register'],
  },
  // @ts-ignore
  contractSizer: {
    runOnCompile: true,
  },

  // preprocess: {
  //   eachLine: (hre) => ({
  //     transform: (line: string, sourceInfo: { absolutePath: string }) => {
  //       if (line.match(/^\s*import /i)) {
  //         for (const [from, to] of getRemappings()) {
  //           if (line.includes(from)) {
  //             console.log(sourceInfo.absolutePath);
  //             console.log(`before ${line}`);
  //             line = line.replace(from, `${path.relative(sourceInfo.absolutePath, __dirname).slice(0, -2)}${to}`);
  //             console.log(`Remapping to ${line}`);
  //             break;
  //           }
  //         }
  //       }
  //       return line;
  //     },
  //   }),
  // },
};
