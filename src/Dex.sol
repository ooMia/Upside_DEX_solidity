// IDex.sol
pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IDex {
    function addLiquidity(uint256 amount) external;
    function removeLiquidity(uint256 amount) external;
    function swapTokens(
        address tokenA,
        address tokenB,
        uint256 amount
    ) external;
}

contract Dex is IDex {
    IERC20 tokenX;
    IERC20 tokenY;

    constructor(address tokenA, address tokenB) {
        tokenX = IERC20(tokenA);
        tokenY = IERC20(tokenB);
    }

    function addLiquidity(uint256 amount) public override {
        // Implementation
    }

    function removeLiquidity(uint256 amount) public override {
        // Implementation
    }

    function swapTokens(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public override {
        // Implementation
    }
}
