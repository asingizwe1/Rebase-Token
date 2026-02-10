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
    ////////////////
    //Errors
    error RebaseToken__InterestRateCanOnlyDecrease();

     ////////////////
    //STATE VARIABLES
    uint256 private s_interestRate=5e10;//you can work with decimals in solidity 
    //50/100 *1e18 = 5e10
mapping (address=>uint256) public s_userInterestRate;


     ////////////////
    //EVENTS
    event InterestRateSet(uint256 newInterestRate);

constructor() ERC20("RebaseToken","RCT"){}

/**
 * @notice Set the interest rate in the contract
 * @param _newInterestRate The ne interest rate to be set
 * @dev The interest rate can only decrease
 * 
 */
function setInterestRate(uint256 _newInterestRate) external{
if (_newInterestRate<s_interestRate){
    revert RebaseToken__InterestRateCanOnlyDecrease();
}
     s_interestRate = _newInterestRate;
    emit InterestRateSet(_newInterestRate);

}

/**
 * @notice get interest rate for user
 * 
 * 
 */
function mint(address _to, uint256 _amount) external{
    // at point of minting we want to set our own interest rate
_mint(_to,_amount);//from openzeppelin

}

function getUserInterestRate(address _user) exterbal view returns (uint256){
return s_userInterstRate[_user];

}

}