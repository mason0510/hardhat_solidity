# hardhat_solidity
hardhat有关的


##基础版本
可升级业务逻辑 
1.A合约
2.部署代理合约
3.部署B合约并且将起2中的代理合约传入


##高级版本
并且可支持存储迁移 并且进行初始化
update代理
1.逻辑合约
2.ProxyAdmin 合约
3.代理合约（名为 TransparentUpgradeableProxy）

upgradeable步骤：
1.部署新的逻辑合约
2.调用 ProxyAdmin 合约的 upgrade 函数来更换新合约，两个参数分别是代理合约和新逻辑合约的地址

uups
1.需要继承UUPSUpgradeable
2.复写_authorizeUpgrade
3.增加kind:'uupfs'
uups模式不需要代理合约 但是多了一个函数
1.给函数更加权限
2.需要区分业务场景的 owner 和合约升级架构的 owner

建议:
1.uups部署简单轻量级 节省gas 可以继续服用update代理
2.代理模式需要代理合约作为参数传入，但是结构清晰，可读性好
3.所有的具体实现合约都必须继承自存储结构合约，并且在代理合约部署后不可更改，以避免代理合约的存储区的意外覆盖。
4.要么重写,利用新的代理合约。
## 代理合约
### 结构化代理合约
https://github.com/vinay035/proxy-contract

###非结构化代理合约
利用单独的存储合约来存储代理合约的地址，并且可以设置代理合约的权限
原理是利用底层keccak256(“org.govblocks.implemenation.address”) 避免实现覆盖。
缺点是不允许升级存储合约结构,如果代理合约跑路 那么合约就over了。
目前为止最先进的方法
参考https://learnblockchain.cn/article/4333
居中方法：
主从合约和非结构化可升级存储代理合约结合，将存储设置为可升级
https://github.com/somish/govblocks-protocol/tree/npm/contracts

4.1
- 部署代理合约和执行合约 
- 调用代理合约的upgradeTo(address)同时不再理会执行合约的地址
参考链接：
https://mirror.xyz/xyyme.eth/kM9ld2u0D1BpHAfXTiaSPGPtDnOd6vrxJ5_tW4wZVBk

##存储升级
1.将数据合约的所有权转移到一个新的逻辑合约,并且禁用之前合约(失效或者0X0)
2.
##部署与运行
### 1.本地部署
下载并设置ganache

npx hardhat node

npx hardhat run scripts/demo-upgradeable-deploy.js --network local

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




##token 转账示例
https://ethereum.stackexchange.com/questions/126443/error-transaction-reverted-without-a-reason-string
