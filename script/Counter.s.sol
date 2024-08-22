// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IDex, Dex} from "src/Dex.sol";

contract DexScript is Script {
    IDex public dex;

    function setUp() public {}

    function run() public {
        dex = new Dex();
    }
}
