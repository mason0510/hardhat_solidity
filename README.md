# hardhat_solidity
hardhat有关的


##基础版本
可升级业务逻辑



##高级版本
并且可支持存储迁移 并且进行初始化


##部署与运行
### 1.本地部署
npx hardhat node

npx hardhat run scripts/demo-deploy.js --network local

npx hardhat test test/demo.test.js --network local

### 2.升级
部署代理合约
npx hardhat run scripts/demo-upgradeable-deploy.js --network local
0x5FC8d32690cc91D4c39d9d3abcBD16989F875707

### 3.部署升级合约
npx hardhat run scripts/demo-upgrade.js --network local

###4.调用测试
0x8937e2F1ee6286643952dfE4A97371385d088c49

## remix部署
共享当前文件夹
remixd -s /Users/houzi/remix/ --remix-ide https://remix.ethereum.org






