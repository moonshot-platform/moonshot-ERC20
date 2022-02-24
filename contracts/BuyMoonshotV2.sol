/*

██████╗ ██╗   ██╗██╗   ██╗    ███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗███████╗██╗  ██╗ ██████╗ ████████╗
██╔══██╗██║   ██║╚██╗ ██╔╝    ████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██╔════╝██║  ██║██╔═══██╗╚══██╔══╝
██████╔╝██║   ██║ ╚████╔╝     ██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║███████╗███████║██║   ██║   ██║   
██╔══██╗██║   ██║  ╚██╔╝      ██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚════██║██╔══██║██║   ██║   ██║   
██████╔╝╚██████╔╝   ██║       ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║███████║██║  ██║╚██████╔╝   ██║   
╚═════╝  ╚═════╝    ╚═╝       ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   
                                                                                                       
Let user buy moonshot through this contract

*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

import "contracts/Context.sol";
import "contracts/IERC20.sol";
import "contracts/SafeMath.sol";
import "contracts/Ownable.sol";
import "contracts/IUniswapV2Factory.sol";
import "contracts/IUniswapV2Pair.sol";
import "contracts/IUniswapV2Router.sol";

contract BuyMoonshotV2 is Context, Ownable {
    using SafeMath for uint256;

    address public tokenAddress = 0x000000000000000000000000000000000000dEaD;
    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    IUniswapV2Router02 private uniswapV2Router;

    bool public feeEnabled = false;
    uint256 public fee = 50; // 50 = 0.5%

    event SetTokenAddress(address newTokenContract);
    event Withdraw(address tokenContract, uint256 amount);
    event WithDrawBNB(uint256 amount);
    event BuyTokens(address account, uint256 amount);
    event SetRouterAddress(address newRouterAddress);
    event FeeEnabled(bool newState);
    event SetFee(uint256 fee);

    constructor() public payable {
        // BSC MainNet, Pancakeswap Router
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // Ropsten, Uniswap Router
        //uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        // BSC TestNet
        //uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    }
 
    function setTokenAddress(address newTokenContract) external onlyOwner() {
        tokenAddress = newTokenContract;

        emit SetTokenAddress(tokenAddress);
    }

    function setRouterAddress(address newRouterAddress) external onlyOwner() {
        routerAddress = newRouterAddress;
        uniswapV2Router = IUniswapV2Router02(routerAddress);

        emit SetRouterAddress(routerAddress);
    }

    // this function swaps BNB for the configured token (market buy)
    function buyTokenWithBNB() public payable {
        uint256 amount = msg.value;
        address beneficiary = msg.sender;
        
        require(amount > 0);

        if( feeEnabled ) {
            uint256 feeAmount = amount.mul(fee).div(10000);
            amount = amount - feeAmount;
        }

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(0, path, beneficiary, block.timestamp+60);

        emit BuyTokens(beneficiary, amount);
    }

    function setFeeEnabled(bool newState) external onlyOwner {
        feeEnabled = newState;

        emit FeeEnabled(newState);
    }

    // Fee is in parts of 10,000:  0.05% = 5 , 0.5%  = 50 
    function setFee(uint256 newFee) external onlyOwner {

        require(newFee < 200, "The fee is too high");

        fee = newFee;

        emit SetFee(newFee);
    }

    function withdraw(address tokenContractAddress) external onlyOwner {
        uint256 amount = IERC20(tokenContractAddress).balanceOf(address(this));
        require(amount > 0);
        IERC20(tokenContractAddress).transfer( msg.sender , amount);

        emit Withdraw(tokenContractAddress, amount);
    }

    function withdrawBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        payable( msg.sender ).transfer( balance );
        
        emit WithDrawBNB(balance);
    }
  
    receive() external payable {
        buyTokenWithBNB();
    }

}