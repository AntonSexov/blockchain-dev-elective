// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Wallet is Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    uint256 public ETHBalance;
    address public feeReciever = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    uint256 public feeRate = 10;

    struct UserInfo {
        uint256 amount;
        }
    //это для токенов ERC20
    mapping (IERC20 => UserInfo) public userInfo;

    event Recieved(address, uint256);
    receive() external payable {
        emit Recieved(msg.sender, msg.value);
        ETHBalance+= msg.value;
    }


    function setFeeRate(uint256 newFee) public{
        require(msg.sender == feeReciever, "juk");
        feeRate = newFee;
    }


    //Отправить eth на кошелек
    function depositETH() public payable {
        uint256 fee = (msg.value).div(100).mul(feeRate);
        ETHBalance += msg.value - fee;
        payable(feeReciever).transfer(fee);
    }
    //Получить eth из кошелька(этого) в кошелек владельца
    //коммиссия в вывод - нечеловечно
    function withdrawETH(uint256 amount) public onlyOwner{
        require(amount <= ETHBalance, "amount exceeds current balance");
        address payable to = payable(msg.sender);
        to.transfer(amount);
        ETHBalance-=amount;
    }
    //Перевести на другой кошелек
    function sendETHToUser(uint256 amount, address payable userAddress) public onlyOwner {
        require(amount <= ETHBalance, "amount exceeds current balance");
        require(userAddress != address(0), "null address");
        userAddress.transfer(amount);
        uint256 fee = (amount).div(100).mul(feeRate);
        ETHBalance-=amount - fee;
        payable(feeReciever).transfer(fee);
    }


    //Пользователь переводит со своего кошелька токен на кошелек(этот)
    function depositERC20(IERC20 token, uint256 amount) public {
        require(amount <= token.balanceOf(address(msg.sender)));
        UserInfo storage user = userInfo[IERC20 (token)];
        token.transferFrom(msg.sender, address(this), amount);
        user.amount += amount;
    }
    //Перевод с кошелька(этого) на кошелек пользователя
    function withdrawERC20(IERC20 token, uint256 amount) public onlyOwner{
        UserInfo storage user = userInfo[IERC20 (token)];
        require(user.amount >= amount, "insufficient funds");
        token.transfer(msg.sender, amount);
        user.amount -= amount;
    }
    //Перевод токенов на кошелек другогго пользователя
    function sendERC20ToUser(IERC20 token, uint256 amount, address userAddress) public {
        UserInfo storage user = userInfo[IERC20 (token)];
        require(user.amount >= amount, "insufficient funds");
        token.transfer(userAddress, amount);
        user.amount -= amount;
    }


    //Возможность делать allowance для токенов
    function setAllowance(IERC20 token, uint256 amount, address userAddress) public onlyOwner{
        token.approve(userAddress, amount);
    }
}