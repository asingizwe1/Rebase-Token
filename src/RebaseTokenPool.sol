//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {TokenPool} from "@ccip/contracts/pools/TokenPool.sol";

contract RebaseTokenPool is TokenPool
{
constructor(IERC20 _token, address[] memory _allowlist, address _rmProxy, address _router) TokenPool(_token, 18,_allowlist,_rmProxy,_router)
{


}

}