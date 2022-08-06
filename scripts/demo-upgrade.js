//安全帽模块
const { ethers, upgrades  } = require("hardhat");

//主函数
async function main() {
    const upgradeContractName = 'DemoV2' //升级合约的名称
    const proxyContractAddress = '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707' //代理合约的名称
    const DemoUpgrade = await ethers.getContractFactory(upgradeContractName)
    console.log('Upgrading Demo...')
    await upgrades.upgradeProxy(proxyContractAddress, DemoUpgrade)
    console.log('Demo upgraded')
}

//升级合约
main().then(() => process.exit(0)).catch(error => {
  console.error(error)
  process.exit(1)
});
