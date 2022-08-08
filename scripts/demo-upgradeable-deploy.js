//hardhat库使用ethers组件与区块链进行交互
const { ethers, upgrades } = require("hardhat");
//import upgrades

//主函数
async function main() {
    const Demo = await ethers.getContractFactory("Demo");
    console.log("Deploying Demo...");
    //initalize方法初始化合约
    const demo = await upgrades.deployProxy(Demo, [101], {
        initializer: 'initialize',
    });
    console.log("Demo deployed at", demo.address);
}

//执行部署
main().then(() => process.exit(0)).catch(error => {
    console.error(error);
    process.exit(1);
});
