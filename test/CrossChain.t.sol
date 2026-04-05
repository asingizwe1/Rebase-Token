//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

//CHAINLINK CCIP documentation ....

import {IERC20} from ""; //from the ccip one not openzeppelin one due to the parameters taken up

import {TokenPool} from "@ccipcontracts/pools/TokenPool.sol";
import {IRouterClient} from "@ccip/contracts/interfaces/IRouterClient.sol";
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
//vm.startPrank(owner)//the user going to be initiating those transfers
//Tells the Foundry VM: “From now on, treat all calls as if they’re coming from this address.”
//Every external call you make after this will have msg.sender = address
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
extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gaslimit:0//we dont want a custom gas limit
}))//from client library


});

//we call the router contract to pass the fees
// we cast it to an interface that has the available functions in the router contract
uint256 fee= IRouterClient(localnetworkDetails.routerAddress).getFee(remoteNetworkDetails.chainSelector,message);//calling router contract
vm.prank(user);
//approve router contract for a fee
IERC20(localNetworkDetails.linkAddress).approve(localNetworkDetails.routerAddress,fee);
//we pretend like we have some link
ccipLocalSimulatorFork.requestLinkFromFaucet(user,fee);

vm.prank(user);//WE USE LINE PRANK BECAUSE 
IERC20(localToken).approve(localNetworkDetails.routerAddress,amountToBridge);//the router address can spend local tokens/router is allowed to spend amount to bridge
//WE WANTTO GET LOCAL CHAIN BALANCE BEFORE WE SEND CROSS CHAIN MESSAGE
uint256 localBalanceBefore=localToken.balanceOf(user);
vm.prank(user);
IRouterClient(localNetworkDetails.routerAddress).ccipSend(remoteNetworkDetails.chainSelector,message);// we call ccip send to send the message to the remote chain
uint256 localBalanceAfter=localToken.balanceOf(user);
//we are casting it to IRouter so that we can access ccipSend
//vm.stopPrank(); - we cant use vm.stop/start prank - because we need to ensire that our prank has ended else our pranks are gonna mess up
//we want to wait for the message to be received on the remote chain before we check the balance there, we can use vm.warp or vm.roll to simulate the passage of time and blocks
uint256 localUserInterestRate=localToken.getUserInterestRate(user);
//If you wrap everything in a long vm.startPrank(user) block, then every single call (including your local fee simulation) runs as user. That can cause mismatches or unintended behavior, because the simulation function may expect to be called from the test contract (address(this)), not the impersonated use
assertEq(localBalanceBefore - localBalanceAfter, amountToBridge + fee, "Local balance should decrease by the bridged amount plus fees") ;
vm.selectFork(remoteFork);
vm.warp(block.timestamp + 20 minutes);//to ensure nothing funcky happens with the message being received on the remote chain
//remote balance 
uint256 remoteBalance=remoteToken.balanceOf(user); //inital balance of remote chain
//balance on remote chain after the message is received
ccipLocalSimulatorFork.switchChainAndRouteMessage(remoteFork);// we call the function to receive the message on the remote chain
uint256 remoteBalanceAfter=remoteToken.balanceOf(user);
assertEq(remoteBalanceAfter - remoteBalance+amountToBridge);
//assert interst rate is equal to interest rate on source chain
uint256 remoteUserInterestRate=remoteToken.getUserInterestRate(user);
assertEq(localUserInterestRate,remoteUserInterestRate,"Interest rates should be the same on both chains after bridging");

}

}

//to configure token pool we apply chain updates
//enabling a token emeans you are allowing chain to receive tokens from the chain you are working on
// you do that by adding chain to chainupdates array
//we apply chain updates onto our token pools

// 12:34 / 21:10