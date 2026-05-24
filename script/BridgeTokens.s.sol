//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {IRouterClient} from "@ccip/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
//it contains functions router is calling
import {Client} from "@ccip/contracts/src/v0.8/ccip/libraries/Client.sol";//to be able to send our message
import {IERX20} from "@ccip/contracts/src/v0.8/ccip/interfaces/IERC20.sol";//to be able to approve the router to spend our tokens and fees

contract BridgeTokens is Script{
function run(address receiverAddress,uint64 destinationChainSelector,address routerAddress,uint256 amountToSend,address tokentOSendAddress, address linkTokenAddress){

vm.startBroadcast();
Client.EVMTokenAmount[] memory tokens = new Client.EVMTokenAmount[](1);
//we need to fill the first element of the array with the token address and amount we want to bridge, otherwise the function will revert with "Invalid token amount"
tokens[0] = Client.EVMTokenAmount({
    token: tokentOSendAddress,
    amount: amountToSend,
   
});

Client.EVM2EVMMessage memory message = Client.EVM2EVMMessage({
    receiver: abi.encode(receiverAddress),//the address that will receive the tokens on the destination chain, it will depend on which chain we are running the script
    data: "",//not sending any data 
    //no gas limit because we dont have a ccip method to receive
    tokenAmount: tokenAmounts,
 feeToken: linkTokenAddress// its different on all chains thats why we pass it in the run
    extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({
       gasLimit: 0,
      
    }))
});
uint256 ccipFee= IRouterClient(routerAddress).getFee(destinationChainSelector, message);//same as ccipSend but we are just getting the fee for the message we want to send, we need to pay this fee in order to be able to send our message
//we need to approve the router to spend our tokens, otherwise the function will revert with "
IRC20(tokentOSendAddress).approve(routerAddress, amountToSend);
//we also need to approve the router to spend our fees, otherwise the function will revert with "ERC20: insufficient allowance"
IERC20(linkTokenAddress).approve(routerAddress, ccipFee);

//create ccip message, approve the router to spend tokens approve router to spend our fees
IRouterClient(routerAddress).ccipSend(destinationChainSelector, message);
//that address will depend on which chain we are running the script

vm.stopBroadcast();
}

}