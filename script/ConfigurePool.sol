 //script to configure the token pools
//SPDX License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} "forge-std/Script.sol";

contract ConfigurePool is Script {
    function run(address _pool, address _vault) external {
        vm.startBroadcast();
        RebaseTokenPool(_pool).setVault(_vault); //set the vault address in the pool contract
        vm.stopBroadcast();
    }
}