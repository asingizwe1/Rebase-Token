 //script to configure the token pools
//SPDX License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} "forge-std/Script.sol";
import {RateLimiter} from "@ccipcontracts/libraries/RateLimiter.sol";
import {TokenPool} from "@ccipcontracts/pools/TokenPool.sol";
contract ConfigurePool is Script {
    function run(address localpool, uint64 remoteChainSelector, address remotePool, address remoteToken, bool outboundRateLimiterIsEnabled,uint128 outboundRateLimiterRate, bool inboundRateLimiterIsEnabled,uint128 inboundRateLimiterRate ) external {
        vm.startBroadcast(); 
        bytes [] memory remotePoolAddresses = new bytes[](1);
        //we need to add the first element to be abi encoded as bytes, otherwise the function will revert with "Invalid remote pool address"
        remotePoolAddresses[0] = abi.encode(remotePool);
        TokenPool.ChainUpdate[] memory chainToAdd = new TokenPool.ChainUpdate[](1);
        chainsToAdd[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            remotePoolAddresses: remotePoolAddresses,
            remoteTokenAddress: abi.encode(remoteToken),
            outboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: outboundRateLimiterIsEnabled,
                rate: outboundRateLimiterRate,
                capacity:outboundRateLimiterCapacity
            }),
               inboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: inboundRateLimiterIsEnabled,
                rate: inboundRateLimiterRate,
                capacity:inboundRateLimiterCapacity
            }),
        });
        //we need to create the remote selector array to be able to call the function, otherwise it will revert with "Invalid remote chain selector"
        //we cast it to token pool so that we are able to access its necessary functions
        TokenPool(localpool).applyChainUpdates(new  uint64[](0), chainToAdd);
        vm.stopBroadcast();
    }
}