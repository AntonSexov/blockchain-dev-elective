// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MultiSigWallet{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address[] public owners;
    uint public confirmations;
    mapping(address => bool) public isOwner;
    mapping(uint => mapping(address => bool)) public isConfirmedBy;

    struct EthTransaction {
        address to;
        uint value;
        bool executed;
        uint numConfirmations;
        uint id;
    }

    struct TokenTransaction {
        address to;
        uint value;
        IERC20 token;
        bool executed;
        uint numConfirmations;
        uint id;
    }
    
    EthTransaction[] public transactions;
    TokenTransaction[] public tokenTransactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    constructor(address[] memory _owners, uint _confirmations) {
        require(_owners.length > 0, "atleast 1 owner");
        require(
            _confirmations > 0 &&
                _confirmations <= _owners.length,
            "invalid confirmation amount"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0));
            require(!isOwner[owner], "owners should be uniqu");

            isOwner[owner] = true;
            owners.push(owner);
        }

        confirmations = _confirmations;
    }


    receive() external payable {}

    function  submitEthTransaction(address _to, uint _value) public onlyOwner {
        transactions.push(
            EthTransaction({
                to: _to,
                value: _value,
                executed: false,
                numConfirmations: 0,
                id: transactions.length
            })
        );
    }

    function  submitTokenTransaction(address _to, uint _value, IERC20 _token) public onlyOwner {
        tokenTransactions.push(
            TokenTransaction({
                to: _to,
                value: _value,
                token: _token,
                executed: false,
                numConfirmations: 0,
                id: tokenTransactions.length
            })
        );
    }

    function confirmEthTransaction(uint _id) public onlyOwner{
        require(_id < transactions.length);
        EthTransaction storage transaction = transactions[_id];
        transaction.numConfirmations+=1;
        isConfirmedBy[_id][msg.sender]=true;
    }

    function confirmTokenTransaction(uint _id) public onlyOwner{
        require(_id < tokenTransactions.length);
        TokenTransaction storage tokenTransaction = tokenTransactions[_id];
        tokenTransaction.numConfirmations+=1;
        isConfirmedBy[_id][msg.sender]=true;
    }

    function executeEthTransaction(uint _id) public payable onlyOwner{
        require(_id < transactions.length, "length");
        EthTransaction storage transaction = transactions[_id];
        require(transaction.numConfirmations>=confirmations, "insufficient confirmations");
        require(transaction.executed==false, "transaction is already executed");
        payable(transaction.to).transfer(transaction.value);
        transaction.executed = true;
    }

    function executeTokenTransaction(uint _id) public onlyOwner{
        require(_id < tokenTransactions.length, "length");
        TokenTransaction storage transaction = tokenTransactions[_id];
        require(transaction.numConfirmations>=confirmations, "insufficient confirmations");
        require(transaction.executed==false, "transaction is already executed");
        transaction.token.transfer(transaction.to, transaction.value);
        transaction.executed = true;
    }

    function depositEth() public payable{
    }
}