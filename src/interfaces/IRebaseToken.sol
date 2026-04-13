//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IRebaseToken
{
function mint(address _to,uint256 _amount,uint256 _interestRate) external;
function burn(address _from,uint256 _amount) external;
function getInterestRate(address _account) external view returns(uint256);
function balanceOf(address _account) external view returns(uint256);
function getUserInterestRate(address _account) external view returns(uint256);
function grantMintAndBurnRole(address _account) external;
}