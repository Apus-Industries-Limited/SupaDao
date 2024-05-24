//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error LiquidityPool__InsufficientLiquidity();

contract LiquidityPool {
      address public tokenA;
      address public tokenB;
      uint256 public reserveA;
      uint256 public reserveB;
      uint256 public totalLiquidity;
      mapping(address => uint) public liquidity;
      
      constructor(address _tokenA, address _tokenB){
            tokenA = _tokenA;
            tokenB = _tokenB;
      }

      function addLiquidity(uint256 amountA, uint256 amountB) public returns(uint256){
            //first token pair
            IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
            //secon token pair
            IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

            uint256 liquidityMinted;

            if(totalLiquidity == 0){
                  liquidityMinted = sqrt(amountA * amountB);
            } else{
                  liquidityMinted = min((amountA*totalLiquidity)/reserveA,(amountB*totalLiquidity)/reserveB);
            }

            liquidity[msg.sender] += liquidityMinted;
            totalLiquidity += liquidityMinted;
            reserveA += amountA;
            reserveB += amountB;

            return liquidityMinted;
      }

      function removeLiquidity(uint256 liquidityAmount) public returns(uint256,uint256){
            if (liquidity[msg.sender] < liquidityAmount) {
                  revert LiquidityPool__InsufficientLiquidity(); 
            }

            uint256 amountA = (liquidityAmount * reserveA)/totalLiquidity;
            uint256 amountB = (liquidityAmount * reserveB)/totalLiquidity;
            liquidity[msg.sender] -= liquidityAmount;
            totalLiquidity -= liquidityAmount;
            reserveA -= amountA;
            reserveB -= amountB;
            IERC20(tokenA).transfer(msg.sender, amountA);
            IERC20(tokenB).transfer(msg.sender, amountB);

            return(amountA,amountB);
      }


      //helper Pure functions
      function min(uint256 a, uint256 b) internal pure returns(uint256){
            return a <= b ? a : b;
      }

      function sqrt(uint256 y) internal pure returns(uint256 z){
            if(y >3){
                  z = y;
                  uint x = y/2 + 1;
                  while ( x < y){
                        z = x;
                        x = (y/x+x)/2;
                  }
            }else if (y != 0){
                  z=1;
            }
      }
}