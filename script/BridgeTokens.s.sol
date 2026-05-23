//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
//it contains functions router is calling
contract BridgeTokens is Script{
function run(){
vm.startBroadcast();
//create ccip message, approve the router to spend tokens approve router to spend our fees
IRouterClient(routerAddress).ccipSend{value: fees}(destinationChainSelector, destinationAddress, message, feeToken, 0);
//that address will depend on which chain we are running the script

vm.stopBroadcast();
}

}