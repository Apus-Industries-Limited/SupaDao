//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

error SwapToken__InvalidAmount();
error SwapToken__InsufficientLiquidity();

contract SwapToken is LiquidityPool{
      constructor(address _tokenA, address _tokenB) LiquidityPool(_tokenA, _tokenB){}


      // Swap tokenA for tokenB
    function swapAForB(uint256 amountA) public returns (uint256) {
        uint256 amountB = getAmountOut(amountA, reserveA, reserveB);
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        reserveA += amountA;
        reserveB -= amountB;

        return amountB;
    }

    // Swap tokenB for tokenA
    function swapBForA(uint256 amountB) public returns (uint256) {
        uint256 amountA = getAmountOut(amountB, reserveB, reserveA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        IERC20(tokenA).transfer(msg.sender, amountA);

        reserveB += amountB;
        reserveA -= amountA;

        return amountA;
    }

    // Helper function to calculate the output amount
    function getAmountOut(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) internal pure returns (uint256) {
        uint256 inputAmountWithFee = inputAmount * 997;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;
        return numerator / denominator;
    }

}