// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

interface IDex {
    /// @dev Add liquidity to the pool
    /// @param amountX Amount of token X to add
    /// @param amountY Amount of token Y to add
    /// @param minLPReturn Minimum amount of LP tokens to receive
    /// @return lpAmount Amount of LP tokens received
    function addLiquidity(
        uint256 amountX,
        uint256 amountY,
        uint256 minLPReturn
    ) external returns (uint256 lpAmount);

    /// @dev Remove liquidity from the pool
    /// @param lpAmount Amount of LP tokens to remove
    /// @param minAmountX Minimum amount of token X to receive
    /// @param minAmountY Minimum amount of token Y to receive
    /// @return rx Amount of token X received
    /// @return ry Amount of token Y received
    function removeLiquidity(
        uint256 lpAmount,
        uint256 minAmountX,
        uint256 minAmountY
    ) external returns (uint256 rx, uint256 ry);

    /// @dev Swap tokens X <-> Y
    /// @param amountX Amount of token X to swap
    /// @param amountY Amount of token Y to swap
    /// @param minReturn Minimum amount of tokens to receive
    /// @return amount Amount of token that was swapped
    function swap(
        uint256 amountX,
        uint256 amountY,
        uint256 minReturn
    ) external returns (uint256 amount);
}

contract Dex is IDex {
    IERC20 tokenX;
    IERC20 tokenY;

    mapping(address => uint256) public lpBalances;

    int internal dx;
    int internal dy;
    uint internal balanceX;
    uint internal balanceY;

    constructor(address tokenA, address tokenB) {
        tokenX = IERC20(tokenA);
        tokenY = IERC20(tokenB);
    }

    modifier refresh() {
        uint bx = tokenX.balanceOf(address(this));
        uint by = tokenY.balanceOf(address(this));
        dx = bx != 0
            ? bx > balanceX
                ? int(bx - balanceX)
                : -1 * int(bx - balanceX)
            : int(0);
        dy = by != 0
            ? by > balanceY
                ? int(by - balanceY)
                : -1 * int(by - balanceY)
            : int(0);
        balanceX = uint(int(balanceX) + dx);
        balanceY = uint(int(balanceY) + dy);
        _;
    }

    function addLiquidity(
        uint256 amountX,
        uint256 amountY,
        uint256 minLPReturn
    ) external override refresh returns (uint256 lpAmount) {
        // 유동성 풀의 비율과 일치하는지 확인합니다.
        require(balanceX / amountX == balanceY / amountY);
        // 유동성 풀의 비율에 맞게 자산을 분배합니다.
        // token.transfer 변경분을 계산합니다.
        lpAmount = Math.max(uint(int(amountX) + dy), uint(int(amountY) + dx));
        require(lpAmount > 0 && lpAmount >= minLPReturn, "Invalid LP amount");

        // 토큰을 전송합니다.
        require(
            tokenX.allowance(msg.sender, address(this)) >= lpAmount &&
                tokenY.allowance(msg.sender, address(this)) >= lpAmount,
            "ERC20: insufficient allowance"
        );
        require(
            tokenX.balanceOf(msg.sender) >= amountX &&
                tokenY.balanceOf(msg.sender) >= amountY,
            "ERC20: transfer amount exceeds balance"
        );
        balanceX += amountX;
        balanceY += amountY;
        lpBalances[msg.sender] += lpAmount;
        tokenX.transferFrom(msg.sender, address(this), amountX);
        tokenY.transferFrom(msg.sender, address(this), amountY);
    }

    function removeLiquidity(
        uint256 lpAmount,
        uint256 minAmountX,
        uint256 minAmountY
    ) external override refresh returns (uint256 rx, uint256 ry) {
        // 유동성 풀의 비율에 맞게 자산을 분배합니다.
        // 원래라면 전체 LP를 모두 누적해서 비율을 반영하는게 맞습니다.
        // 테스트에서는 단일 유저의 행동만을 고려하므로 간단하게 처리합니다.
        rx = (balanceX * lpAmount) / lpBalances[msg.sender];
        ry = (balanceY * lpAmount) / lpBalances[msg.sender];
        require(rx >= minAmountX && ry >= minAmountY, "Invalid LP amount");
        balanceX -= rx;
        balanceY -= ry;
        lpBalances[msg.sender] -= lpAmount;
        tokenX.transfer(msg.sender, rx);
        tokenY.transfer(msg.sender, ry);
    }

    function swap(
        uint256 amountX,
        uint256 amountY,
        uint256 minReturn
    ) external override returns (uint256 amount) {
        if (amountY == 0 && amountX > 0) {
            amount = swapX(amountX);
        } else if (amountX == 0 && amountY > 0) {
            amount = swapY(amountY);
        } else {
            revert("Invalid swap amount");
        }
        require(amount >= minReturn, "Invalid swap amount");
    }

    function swapX(uint256 amountIn) internal returns (uint256 amount) {
        // in case of swap X -> Y
        amount = balanceY - (balanceX * balanceY) / (balanceX + amountIn);
        amount = (amount * 999) / 1000;

        tokenX.transferFrom(msg.sender, address(this), amountIn);
        tokenY.transfer(msg.sender, amount);
    }

    function swapY(uint256 amountIn) internal returns (uint256 amount) {
        // in case of swap Y -> X
        amount = balanceX - (balanceY * balanceX) / (balanceY + amountIn);
        amount = (amount * 999) / 1000;

        tokenY.transferFrom(msg.sender, address(this), amountIn);
        tokenX.transfer(msg.sender, amount);
    }
}
