const Web3 = require("web3");
const RLP = require("rlp");

const nonce = 0;
const account = "0xa990077c3205cbdf861e17fa532eeb069ce9ff96";

var e = RLP.encode(
    [
        account,
        nonce,
    ],
);
const nonceHash = Web3.utils.sha3(Buffer.from(e));
let substring = nonceHash.substring(26);
console.log(substring);
console.log(substring.length);

//重放交易
/*
{
  "nonce": 2,
  "gasPrice": {
    "_hex": "0x02540be400"
  },
  "gasLimit": {
    "_hex": "0x114343"
  },
  "to": "0x00",
  "value": {
    "_hex": "0x00"
  },
  "data": "xxxx...xxxx",
  "v": 28,
  "r": "0xc7841dea9284aeb34c2fb783843910adfdc057a37e92011676fddcc33c712926",
  "s": "0x4e59ce12b6a06da8f7ec7c2d734787bd413c284fc3d1be3a70903ebc23945e8c"
}
 */

//createProxy 重新部署就能生成新的代理地址 他不创建直接转钱过去 但是账户已被控制。








