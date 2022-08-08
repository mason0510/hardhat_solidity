const { ethers, upgrades } = require("hardhat");
async function main() {
//代理合约
    const proxyAddress = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';
    const Demo = await ethers.getContractFactory("Demo");
    console.log("Preparing upgrade...");
    // 升级合约
    await upgrades.upgradeProxy(proxyAddress, Demo);
}

//执行部署
main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
