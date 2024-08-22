// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDex {
    /// @dev Add liquidity to the pool
    /// @param amountX Amount of token X to add
    /// @param amountY Amount of token Y to add
    /// @param minLPReturn Minimum amount of LP tokens to receive
    /// @return lpAmount Amount of LP tokens received
    function addLiquidity(
        uint amountX,
        uint amountY,
        uint minLPReturn
    ) external returns (uint lpAmount);

    /// @dev Remove liquidity from the pool
    /// @param lpAmount Amount of LP tokens to remove
    /// @param minAmountX Minimum amount of token X to receive
    /// @param minAmountY Minimum amount of token Y to receive
    /// @return rx Amount of token X received
    /// @return ry Amount of token Y received
    function removeLiquidity(
        uint lpAmount,
        uint minAmountX,
        uint minAmountY
    ) external returns (uint rx, uint ry);

    /// @dev Swap tokens X <-> Y
    /// @param amountX Amount of token X to swap
    /// @param amountY Amount of token Y to swap
    /// @param minReturn Minimum amount of tokens to receive
    /// @return amount Amount of token that was swapped
    function swap(
        uint amountX,
        uint amountY,
        uint minReturn
    ) external returns (uint amount);
}

contract Dex is IDex {
    IERC20 tokenX;
    IERC20 tokenY;

    constructor(address tokenA, address tokenB) {
        tokenX = IERC20(tokenA);
        tokenY = IERC20(tokenB);
    }

    function addLiquidity(
        uint amountX,
        uint amountY,
        uint minLPReturn
    ) external override returns (uint lpAmount) {
        tokenX.transferFrom(msg.sender, address(this), amountX);
        tokenY.transferFrom(msg.sender, address(this), amountY);
        lpAmount = amountX + amountY;
        tokenX.approve(msg.sender, lpAmount);
    }

    function removeLiquidity(
        uint lpAmount,
        uint minAmountX,
        uint minAmountY
    ) external override returns (uint rx, uint ry) {
        tokenX.transfer(msg.sender, minAmountX);
        tokenY.transfer(msg.sender, minAmountY);
        tokenX.approve(msg.sender, lpAmount);
    }

    function swap(
        uint amountX,
        uint amountY,
        uint minReturn
    ) external override returns (uint amount) {
        tokenX.transferFrom(msg.sender, address(this), amountX);
        tokenY.transfer(msg.sender, amountY);
        tokenX.approve(msg.sender, amount);
    }
}
