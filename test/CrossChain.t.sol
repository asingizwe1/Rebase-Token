//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

//CHAINLINK CCIP documentation ....

import {IERC20} from ""; //from the ccip one not openzeppelin one due to the parameters taken up

import {Test,console} from "forge-std/test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {Vault} from "../src/Vault.sol";
import {IRebaseToken} from "..src/interfaces/IRebaseToken.sol";
import {CCIPLocalSimulatorFork,Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {registryModuleOwnerCustomAddress} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistrymoduleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/tokenAdminRegistry/TokenAdminRegistry.sol";

contract CrossChainTest is Test{
    address constant owner=makeAddr("owner");
uint256 sepoliaFork;
uint256 arbSepoliaFork;

CCIPLocalSimulatorFork ccipLocalSimulatorFork;
//we must first store contracts in storage when we want to deploy them
RebaseToken sepoliaToken;
RebaseToken arbSepoliaToken;

//we add the token pools wheich we want to deploy to the storage
RebaseTokenPool sepoliaPool;

RebaseTokenPool arbSepoliaPool;

//type value
Register.NetworkDetails sepoliaNetworkDetails;
Register.NetworkDetails arbSepoliaNetworkDetails;


//deploying the vault
Vault vault;// we store it in storage wehn we want to deploy it
function setUp() public
{
//we shall use our forked objects alot of the time
sepoliaFork=vm.createSelectFork("sepolia");
arbSepoliaFork=vm.createFork("arb-sepolia");//what you names your url in foundry.toml

ccipLocalSimulatorFork=new CCIPLocalSimulatorFork();
vm.makePersistent(address(ccipLocalSimulator));

//deploy and configure on sepolia
sepoliaNetworkDetails=ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
vm.startPrank(owner);//becuase we shall pass in alot
//we deploy new token to chain
sepoliaToken=new RebaseToken();
//we do intermediate casting to that address
vault= new Vault(IRebaseToken(address(sepoliaToken)));//users should be able to deposit to source chain
//we shall only have it on sepolia because we want users to deploy everything on source chain
sepoliaPool=new RebaseTokenPool(IERC20(address(sepoliaToken)),new address[](0), sepoliaNetworkDetails.rmnProxy );
//we have to put constructor arguments.. ir rmnProxy but from CCIPLocal simulator
//we allow pool and vault to burn and mint by calling the burnandmint function
sepoliaToken.grantMintAndBurnRole(address(vault));
sepoliaToken.grantMintAndBurnRole(address(sepoliaPool));
RegistryOwnerModuleCustom(sepoliaNetworkdetails.registryModuleOwnerCustomAddress).registerAdminViaOwner();
TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(sepoliaToken));
TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(address(sepoliaToken),address(sepoliaPool))

vm.stopPrank();

//deploy and configure on ArbSepolia
vm.selectFork(arbSepoliaFork);//we use select fork to ensure everything is interacting on arbitrum sepolia
arbSepoliaNetworkDetails=ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
arbSepoliaToken=new RebaseToken();
//below we are deploying the pool on both sepolia and arbSepolia
arbSepoliaPool=new RebaseTokenPool(IERC20(address(sepoliaToken)),new address[](0), sepoliaNetworkDetails.rmnProxy );
//we also grant mint and burn function for the pool
sepoliaToken.grantMintAndBurnRole(address(arbSepoliaPool));
RegistryOwnerModuleCustom(arbSepoliaNetworkdetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(adddress(arbSepoliaToken));//intermediate casting
TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(arbSepoliaToken));
TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(address(arbSepoliaToken),address(arbSepoliaPool));
vm.startPrank(owner);
vm.stopPrank();

}
//create a way to simulate crosschain transactions
//chainlink cross chain local helps to achieve this


}

//to configure token pool we apply chain updates