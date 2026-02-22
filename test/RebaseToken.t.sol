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
//(bool success,)=payable(address(vault)).calll{value:1e18}("");
// rather than guessing amount we create function to get amount of vault
   vm.stopPrank();
}

function addRewardsToVault(uint256 rewardAmount) public
{
(bool success,)=payable(address(vault)).call{value:rewardAmount}("");
}

function testDepositLinear() public
{
//vm.assume(amount>1e5); the reason below is why we dont use this
amount=bound(amount,1e5,type(uint96).max);// it will modify bound to be in that range 
//this is to prevent unecessary fuzz testing and to make sure we are testing the right things


//1 deposit
vm.startPrank(user);
vm.deal(user,amount);
vault.deposit{value:amount}("");
//2 check our rebase token balance
uint256 startBalance=rebaseToken.balanceOf(user);
console.log("start balance",startBalance);
assertEq(startBalance,amount);
//3 warp the time and check he balance
vm.warp(block.timestamp+1 hours);
uint256 middleBalance=rebaseToken.balanceOf(user);
assertGt(middleBalance,startBalance);
//4 warp time again by the same amount and check the balance again
vm.warp(block.timestamp+1 hours);
uint256 endBalance=rebaseToken.balanceOf(user);
assertGt(endBalance,middleBalance);

assertApproxEqAbs(endBalance-middleBalance,middleBalance-startBalance,1);


vm.stopPrank();



}

function testRedeemAfterTimePassed(uint256 depositAmount, uint256 time) public{
time=bound(time,100,type(uint96).max);//its more practical to use 96 instead of 256
depositAmount=bound(depositAmount,1e5,type(uint96).max)
//1 deposit

vm.deal(user,amount);//this doesnt count as a tx
vm.prank(user);
vault.deposit{value:amount}("");
//2 warp the time
vm.warp(block.timestamp+time);
uint256 balance=rebaseToken.balanceOf(user);
//2 b - add rewards to the vault
vm.deal(owner,balanceAfrerSomeTime-depositAmount)
vm.prank(owner);
addRewardsToVault(balanceAfterSomeTime-depositAmount);

//3 redeem
vm.prank(user);
vault.redeem(type(uint256).max)


uint256 ethBalance=address(user).balance;
assertEq(ethBalance,balance);//amount in eth is equal to the amount in rebase tokens
assertGt(ethBalance,depositAmount);//check if there balance has increased

}

/**
 * vm.deal and vm.warp
 * special testing utilities that let you manipulate blockchain state directly
 * for simulating scenarios without waiting for real-world conditions.
 * vm.deal - Sets the balance of a given address to a specified value.
 * vm.deal(owner,balanceAfrerSomeTime-depositAmount) -> forces the owner account to have exactly that balance, regardless of prior transactions.
 * 
 * vm.warp(timestamp)
 * Sets the block.timestamp to a specified value.
 */

}
