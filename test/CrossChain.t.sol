//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

//CHAINLINK CCIP documentation ....

import {IERC20} from ""; //from the ccip one not openzeppelin one due to the parameters taken up

import {TokenPool} from "@ccipcontracts/pools/TokenPool.sol";

import {Test,console} from "forge-std/test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {Vault} from "../src/Vault.sol";
import {IRebaseToken} from "..src/interfaces/IRebaseToken.sol";
import {CCIPLocalSimulatorFork,Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {registryModuleOwnerCustomAddress} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistrymoduleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/tokenAdminRegistry/TokenAdminRegistry.sol";
import {Client} from "@ccip/contracts/libraries/Client.sol";
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

//CONFIGURING OUR POOLS TO KNOW ABOUT EACH OTHER
//the tokens are of type rebase token pool thats why we cast them as addresses
configureTokenPool(sepoliaFork,address(sepoliaPool),arbSepoliaNetworkDetails.chainSelector,address(arbSepoliaPool),address(arbSepoliaToken));
configureTokenPool(arbSepoliaFork,address(arbSepoliaPool),sepoliaNetworkDetails.chainSelector,address(sepoliaPool),address(sepoliaToken));
//we do the above because we want to be able to send tokens from sepolia to arbitrum and vice versa
vm.stopPrank();

}
//create a way to simulate crosschain transactions
//chainlink cross chain local helps to achieve this

// set it in a way that we can configure pool for sepolia or arbitrum
//local - we are talking about

// if you are working with arbitrum
// local-arbitrum
// remote- sepolia
function configureTokenPool(uint256 fork, address localPool
//chain selector for the chain to enable
uint64 remoteChainSelector,address remotePool, address remoteTokenAddress
) public
 {
vm.selectFork(fork);
vm.prank(owner);// because we are going to prank one function

bytes[] memory remotePoolAddresses= new bytes[](1);
remotePoolAddresses[0] = abi.encode(remotePool);
TokenPool.ChainUpdate[] memory chainsToAdd =new TokenPool.ChainUpdate[](1) ;


// struct ChainUpdate
// {
// uint64 remoteChainSelector;
// bytes[] remotePoolAddresses;
// bytes remoteTokenAddresses;
// RateLimiter.Config outboundRateLimiterConfig;
// RateLimiter.Config inboundRateLimiterConfig;
// }

//since its a bytes[] we need to abiEncode

chainsToAdd[0]=TokenPool.ChainUpdate({
remoteChainSelector: remoteChainSelector,
remotePoolAddresses: remotePoolAddresses,
remoteTokenAddresses: abi.encode(remoteTokenAddress),
outboundRateLimiterConfig: RateLimiter.Config(isEnabled:false,capacity:0,rate:0),// we are not setting up rate limiter in this example so we set it to 0
}) ;
inboundRateLimiterConfig: RateLimiter.Config(isEnabled:false,capacity:0,rate:0)//because we arent allowing rate limiting
TokenPool(localPool).applyChainUpdates(new uint64[](0),chainToAdd);//first is array of chains we want to be moving
//to call applyChainUpdates we cast local pool as tokenpool
 }




//Register.NetworkDetails  - struct defined somewhere in your Register contract or library. It likely contains metadata about a blockchain network. Typical fields might include:
//we are going to do this in that we can send tokens from sepolia to arb and vice versa
function bridgeTokens(uint256 amountToBridge, uint256 localFork, uint256 remoteFork, Register.NetworkDetails memory localNetworkDetails,Register.NetworkDetails  memory remoteNetworkDetails,RebaseToken localToken, RebaseToken remoteToken) public
{///we first select fork we are working on
vm.selectFork(localFork);//since we are working on local fork first
// we set up the message to send
Client.EVMTokenAmount[] memory tokenAmounts=new Client.EVMTokenAmount[](1); 
tokenAmounts[0]=Client.EVMTokenAmount({
//we create an array of 1 since we are only sending one token, if we wanted to send multiple tokens we would increase the size of the array and add more token amounts
token:address(localToken),//we cast it to an address because its of type rebase token

})
//before the fees we create the message to send to the remote chain 
Client.EVM2AnyMessage memory message=Client.EVM2AnyMessage({

receiver: abi.encode(remoteToken),// we are sending to the remote token contract
data:"",
tokenAmounts:tokenAmounts;//we pass this to the token struct
feeToken:localNetworkDetails.linkAddress,// we pay fees in the native token of the local chain;
})


vm.startPrank(owner)//the user going to be initiating those transfers



}

}

//to configure token pool we apply chain updates
//enabling a token emeans you are allowing chain to receive tokens from the chain you are working on
// you do that by adding chain to chainupdates array
//we apply chain updates onto our token pools


