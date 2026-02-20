// this is where users will lock and handle their eth
//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

//LOOK AT THE LOWLEVEL CALL AT REDEEM AND UNDERSTAND IT 

contract Vault{
//we need to pass the token address to the constructor
//create a deposit and mint function
//creat redeem, burn tokens from the user and sends the user ETH

IRebaseToken private immutable _rebaseToken;

//indexed helps you sort the events
event Deposit(address indexed user,uint256 amount);
//user is indexed because we want to see number of times they have redeemed 
event Redeem(address indexed user,uint256 amount);


   error Vault__RedeemFailed();


constructor(IRebaseToken _rebaseToken)
{
i_rebaseToken=_rebaseToken
}
//adding a fallback
receive() external payable{}

/**
 *  @notice allows users deposit and mint rebase tokens
 * 
 */
function deposit() external payable
{
  // IrebaseToken( i_rebaseToken) we can do this but its a better practice of putting it in constructor
   i_rebaseToken.mint(msg.sender,msg.value);
    emit Deposit(msg.sender,msg.value);
}


function redeem() external
{//1 burn
i_rebaseToken.burn(msg.sender,i_rebaseToken.balanceOf(msg.sender));
//2 send them eth
(bool success,)=payable(msg.sender).call{value:_amount}("");
//since no returnj data we leave it as bool,
if(!success){
    revert Vault__RedeemFailed();
}
emit Redeem(msg.sender,_amount);
}

function getRebaseTokenAddress() external view returns(address)
{
    return address(i_rebaseToken);
}
}