//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {RegistryModuleOwnerCustom} from "@ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.s.sol";
import {TokenAdminRegistry} from "@ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {Script} "forge-std/Script.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {Deployer} from "../src/Deployer.sol";
import {Vault} from "../src/Vault.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.s.sol";
import {CCIPLocalSimulatorFork,Register} from "@chainlink-local/src/CCIPLocalSimulatorFork.s.sol";//we add register to get network details fromt the fork
import {RebaseToken} from "../src/RebaseToken.s.sol";
import {IERC20} from "@openzeppelin/contracts@4.8.3/token/ERC20/IERC20.sol";
//steps in the ccip documentation /Enable your tokens in CCIP(burn&mint):Register from anEOA using foundry
contract TokenAndPoolDeployer is Script{//script to deploy the token annd the pool
function run() public returns (RebaseToken token, rebaseTokenPool pool) //returns both our contracts deployed
{
 Register.NetworkDetails networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid); ///chain id of script which the script is being run on 
    CCIPLocalSimulatorFork ccipLocalSimulatorFork=new CCIPLocalSimulatorFork(); //create a fork of the local simulator
vm.startBroadcast(); // start sending transactions
token=new RebaseToken();
pool = new RebaseTokenPool(IERC20(address(token), new address[](0), networkDetails.rnmProxyAddress,networkDetails.routerAddress) );// the parameters we put are what is in the constructor in the contract
token.grantMintAndBurnRole(address(pool)); //grant the pool contract the mint and burn role on the rebase token
//IERC20(address(token) - //Treat token as something that follows the IERC20 interface.
//an address alone doesnt have erc20 function
RegistryModuleOwnerCustom(networkDetails.registryModuleOwnerCustom).registerAdminViaOwner(address(token));//who ever calls this will be the owner //we have registered ad,min via this
TokenAdminRegistry(networkDetails.tokenAdminRegistry).acceptAdminRole(address(token)); //register the token in the registry
TokenAdminRegistry(networkDetails.tokenAdminRegistry).setPool(address(token),address(pool)); //grant the pool contract the admin role on the token in the registry
vm.stopBroadcast();
}
}
//we deploy below seperately  because we only want to deploy the vault on the source chain only
contract VaultDeployer is Script {//created vault and givem mint and burn role for the vault
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
































































