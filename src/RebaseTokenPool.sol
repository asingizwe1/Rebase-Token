//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {TokenPool} from "@ccip/contracts/pools/TokenPool.sol";
import {Pool} from "@ccip/contracts/src/v0.8/ccip/libraries/Pool.sol";

contract RebaseTokenPool is TokenPool
{
constructor(IERC20 _token, address[] memory _allowlist, address _rmProxy, address _router) TokenPool(_token, 18,_allowlist,_rmProxy,_router)
{

}

//from this token pool to another chain thats when this is called
function LockOrBurn(Pool.LockorBurnInV1 calldata lockOrBurnIn)
public returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut)
{
_validateLockOrBurnIn(lockOrBurnIn);//send info offchain before burning
address receiver=abi.decode(lockOrBurnIn.receiver, (address));
uint256 UserInterestRate=IRebaseToken(address(i_token)).getUserInterestRate(receiver);//you can cast one address into another directly
//CCIP you first do a token approval then ccip will send tokens to token pool
IRebaseToken(address(i_token)).burn(address,lockOrBurnIn.amount);//its address because not receiver -> because it sends token to token pool
lockOrBurn=Pool.LockOrBurnOutV1({ //name:value - > normal format for structs
    destTokenAddress:getRemoteToken(lockOrBurnIn.remoteChainSelector),
    destPoolData:abi.encode(userInterestRate)
});
}

//this is for the opposite
function releaseOrMint(Pool.ReleaseOrMintInV1 calldata ReleaseOrMintIn)
public returns (Pool.ReleaseOrMintOutV1 memory releaseOrMintOut)
{}


}