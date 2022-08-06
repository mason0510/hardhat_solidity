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








