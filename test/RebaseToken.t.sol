//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";

contract RebaseTokenTest is Test{
RebaseToken private rebaseToken;
Vault private vault;


address public owner=makeADDR("owner");
address public user=makeADDR("user");


//we deploy our vault and set permissions for the vault
function setUp() public{
    vm.startPrank(owner);
rebaseToken = new RebaseToken();
//we can only castthe address of the rebase token to the interface
// because we have to pass it to the vault constructor
vault = new Vault(IRebaseToken(address(rebaseToken)));
rebaseToken.grantMintAndBurnRole(address(vault));
(bool success,)=payable(address(vault)).calll{value:1e18}("");
   vm.stopPrank();
}

function testDepositLinear() public
{
//1 deposit
//2 check 


}

}
