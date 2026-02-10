//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title RebaseToken
 * @author Louis
 * @notice This is a rebase token that incentivises users to deposit
 * @notice Interest rate can only deposit
 * @notice each user will have global interest rate at the point of deposit
 */
contract RebaseToken is ERC20
{
    error RebaseToken__InterestRateCanOnlyDecrease();
    uint256 private s_interestRate=5e10;//you can work with decimals in solidity 
    //50/100 *1e18 = 5e10
constructor() ERC20("RebaseToken","RCT"){}
function setInterestRate(uint256 _newInterestRate) external{
if (_newInterestRate<s_interestRate){
    emit RebaseToken__InterestRateCanOnlyDecrease();
}
     s_interestRate = _newInterestRate;
    

}

}