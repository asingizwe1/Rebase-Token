//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {Vault} from "../src/Vault.sol";

import {IRebaseToken} from "..src/interfaces/IRebaseToken.sol";
import {CCIPLocalSimulatorFork} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

contract CrossChainTest is Test{
    address constant owner=makeAddr("owner");
uint256 sepoliaFork;
uint256 arbSepoliaFork;

CCIPLocalSimulatorFork ccipLocalSimulatorFork;

RebaseToken sepoliaToken;
RebaseToken arbSepoliaToken;

//deploying the vault
Vault vault;
function setUp() public
{
//we shall use our forked objects alot of the time
sepoliaFork=vm.createSelectFork("sepolia");
arbSepoliaFork=vm.createFork("arb-sepolia");//what you names your url in foundry.toml

ccipLocalSimulatorFork=new CCIPLocalSimulatorFork();
vm.makePersistent(address(ccipLocalSimulator));

//deploy and configure on sepolia
vm.startPrank(owner);
//we deploy new token to chain
sepoliaToken=new RebaseToken();
vault= new Vault(IRebaseToken(sepoliaToken));//users should be able to deposit to source chain
vm.stopPrank();

//deploy and configure on ArbSepolia
vm.selectFork(arbSepoliaFork);
arbSepoliaToken=new RebaseToken();
vm.startPrank(owner);
vm.stopPrank();

}
//create a way to simulate crosschain transactions
//chainlink cross chain local helps to achieve this


}