const { ethers } = require("ethers");

const tokenAbi = require("D:/ITMO/2nd-semester/electives/homework2/contracts/MultiSigWallet.sol/MultiSigWallet.json").abi;

provider = new ethers.providers.JsonRpcBatchProvider(
    "https://eth-sepolia.g.alchemy.com/v2/qg2o5s7iYrFwm2xTv2pVzYHpci_-xBoK"
);

let KEY = FileReader.readAsText("key.txt");

const signer = new ethers.Wallet(
    KEY,
    provider
);

const address = "0xb4f9e1717a6535510F35d4804f96f3A0D402B1Ab";

const contract = new ethers.Contract(address, tokenAbi, signer);

const read = async () => {
    const res = await contract.balanceOf(
        "0x2bF677268C11C672f46a90D09B8b17d7C7b9E0D8"
    );
    console.log(Number(res))
};

const write = async () => {
    await contract.mint(
        "0x2bF677268C11C672f46a90D09B8b17d7C7b9E0D8"
    );
};


write();
read();