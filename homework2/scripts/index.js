const { ethers } = require("ethers");
require('dotenv').config();

const tokenAbi = require("../contracts/MultiSigWallet.sol/MultiSigWallet.json").abi;

provider = new ethers.providers.JsonRpcBatchProvider(
    "https://eth-sepolia.g.alchemy.com/v2/PoE88OYaN127e1qqc-HMFkUZGGRC4KfD"
);

const signer = new ethers.Wallet(
    process.env.PRIVATE_KEY,
    provider
);

const address = "0xe9eEE6ce9EAd9A88C94BDec13C87e383371dE61e";

const contract = new ethers.Contract(address, tokenAbi, signer);