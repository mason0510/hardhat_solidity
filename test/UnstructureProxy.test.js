
// test/update-test.ts
const { expect } = require('chai');
const { ethers, upgrades } = require('hardhat');


let implementationV1;
let unstructureProxy;
let implementationV2;

describe('Unstructureproxy contract ', async function () {
    /**
     * 测试执行前的钩子函数
     */
    before(async () => {
        //获取合约工厂对象
        this.ImplementationV1 = await ethers.getContractFactory('ImplementationV1')
        this.UnstructureProxy = await ethers.getContractFactory('UnstructuredProxy')

        //通过合约工厂部署合约
        implementationV1 = await this.ImplementationV1.deploy()
        unstructureProxy = await this.UnstructureProxy.deploy()


    });
    //demo
    it('deploys ImplementationV1 test', async function () {
        //测试v1调用addPlayer方法 指定gasLimit
        const contract = await ethers.getContractAt('ImplementationV1',implementationV1.address)
        const result = await contract.test()
        // const result = await contract.addPlayer(('0x90f79bf6eb2c4f870365e785982e1f101e93b906',1), { gasLimit: 1000000 })
       //打印
         console.log(result)
    });

    it('deploys ImplementationV2 test', async function () {
    //打印合约地址
    console.log("ImplementationV2 address:=",implementationV1.address)
    console.log("UnstructureProxy.address",unstructureProxy.address)

     this.ImplementationV2 = await ethers.getContractFactory('ImplementationV2');
    implementationV2 = await this.ImplementationV2.deploy()
    console.log("ImplementationV2 address:=",implementationV2.address);
        //UnstructureProxy update to ImplementationV2
    await unstructureProxy.upgradeTo(implementationV2.address)
    //  //调用connect(ethers.provider.getSigner(1)).
    //  let test = await implementationV2.test({
    //      gasLimit: 10000000})
    //     console.log("test2:=++++++++++++++++++++++++++",test)
    // })
    let test = await implementationV2.addPlayer("0x90f79bf6eb2c4f870365e785982e1f101e93b906",1,{
            gasLimit: 10000000})

        let test2 = await implementationV2.addPlayer("0x90f79bf6eb2c4f870365e785982e1f101e93b906",1,{
            gasLimit: 10000000})

        let totalPlayers = await implementationV2.getTotalPlayers()
        expect(totalPlayers).to.equal(7)
    })
    //使用指定地址调用合约
    // const [owner,account1] = await ethers.getSigners();
    //打印
    //console.log("owner address:=",owner.address)
    //console.log("account1 address:=",account1.address)


    let totalPlayers = await implementationV2.getTotalPlayers()
    expect(totalPlayers).to.equal(11)
    //打印owner地址
     //let owner = await ImplementationV2.getOwner()
     //console.log("owner address:=",owner);


})
