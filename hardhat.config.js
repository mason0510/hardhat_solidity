//hardhat项目依赖组件
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');

//hardhat项目配置项
module.exports = {
  solidity:  {
    compilers: [
      {
        version: "0.8.2",
      },
      {
        version: "0.6.11",
      },
      {
        version: "0.6.6",
      },
      {
        version: "0.8.4",
      },
      {
        version: "0.4.8",
      },
      {
        version: "0.4.23",
      },
      {
        version: "0.5.16",
      },
      {
        version: "0.6.11",
      },
      // {
      //   version: "0.5.7"
      // },
      // {
      //   version: "0.8.4"
      // },
      // {
      //   version: "0.8.2"
      // },
      // {
      //   version: "0.6.6"
      // },
      // {
      //   version: "0.5.16"
      // },
      // {
      //   version: "0.4.11"
      // },
      // {
      //   version: "0.4.23"
      // },
      // {
      //   version: "0.4.8"
      // },
      // {
      //   version: "0.6.12"
      // },
      // {
      //   version: "0.6.11"
      // }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  }, //使用的sodity库的版本
  networks: {
    local: {
      url: 'http://127.0.0.1:8545', //本地RPC地址 7545 8545
      //本地区块链账户地址(需要启动运行npx hardhat node命令开启本地开发环境的区块链)
      //这些账户地址和秘钥每次重启区块链都是相同的,并且数据会重置
      accounts: [
          //0x6fD631E6595Cf1F7582745909891A843cB2B0C42
        // '152a7c3e127eb1b04a8c5cf17d02eb0dc7dfdaa64531d28eed7d40e1b7eeb5eb',
        // '7d1d9607d92bef7aed27ee188aed76a7c3785d3435a2f1ad1084968210dc4d5a',
        //  'b7fcc83d481ae1044889abec22c115c3fc4078871b4f27fff0514062d8e2da88',
        // 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 (第一个账户地址及秘钥)
        '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
        // 0x70997970c51812dc3a010c7d01b50e0d17dc79c8 (第二个账户地址及秘钥)
        '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d',
        // 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc (三个账户地址及秘钥)
        '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a',
        // 0x90f79bf6eb2c4f870365e785982e1f101e93b906 (第四个个账户地址及秘钥)
        '0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6',
        // 0x15d34aaf54267db7d7c367839aaf71a00a2c6a65 (第五个账户地址及秘钥)
        '0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a',
      ]
    },
    hardhat: {
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/qdGBEfRBpOdC5iBfVHpIxYzyBhK1pgy5",
        blockNumber: 14139081,
      }
    }
  }
};
