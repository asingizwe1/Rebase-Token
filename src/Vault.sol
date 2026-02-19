// this is where users will lock and handle their eth
//SPDX-License-Identifier: MIT
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

contract Vault{
//we need to pass the token address to the constructor
//create a deposit and mint function
//creat redeem, burn tokens from the user and sends the user ETH

address private immutable _rebaseToken;
constructor(address _rebase)
{
i_rebaseToken=_rebaseToken
}
//adding a fallback
receive() external payable{}

function getRebaseTokenAddress() external view returns(address)
{
    return i_rebaseToken;
}
}