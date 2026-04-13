//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} "forge-std/Script.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {Deployer} from "../src/Deployer.sol";
import {Vault} from "../src/Vault.sol";
contract TokenAndPoolDeployer{}

//we deploy below seperately  because we only want to deploy the vault on the source chain only
contract VaultDeployer is Script {
    //takes address of rebase token because we want to pass it in as constructor
    function run(address _rebaseToken) external returns (Vault vault)
     {
        vm.startBroadcast(); // start sending transactions
      //we dont need to decalre Vault vault here because we are returning it and we can declare it in the return statement
      vault = new Vault(IRebaseToken(_rebaseToken)); //we cast _rebasetoken to the type IrebaseToken
       // deploy the vault contract with the rebase token address
       IRebaseToken(_rebaseToken).grantMintAndBurnRole(address(vault)); //grant the vault contract the mint and burn role on the rebase token
        vm.stopBroadcast();
        //we want to return vault so that we can see the address\

    }
}
































































