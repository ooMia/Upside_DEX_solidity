// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CustomERC20} from "test/Dex.t.sol";
import {IDex, Dex} from "src/Dex.sol";

contract DexScript is Script {
    IDex public dex;

    function setUp() public {
        IERC20 tokenX = CustomERC20(address(0x1));
        IERC20 tokenY = CustomERC20(address(0x2));
        dex = new Dex(address(tokenX), address(tokenY));
    }

    function run() public {}
}
