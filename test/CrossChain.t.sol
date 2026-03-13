//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {Vault} from "../src/Vault.sol";

import {IRebaseToken} from "..src/interfaces/IRebaseToken.sol";
import {CCIPLocalSimulatorFork} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

contract CrossChainTest is Test{
uint256 sepoliaFork;
uint256 arbSepoliaFork;

CCIPLocalSimulatorFork ccipLocalSimulatorFork;

function setUp() public
{
//we shall use our forked objects alot of the time
sepoliaFork=vm.createSelectFork("sepolia");
arbSepoliaFork=vm.createFork("arb-sepolia");//what you names your url in foundry.toml

ccipLocalSimulatorFork=new CCIPLocalSimulatorFork();
vm.makePersistent(address(ccipLocalSimulator));
}
//create a way to simulate crosschain transactions
//chainlink cross chain local helps to achieve this


}