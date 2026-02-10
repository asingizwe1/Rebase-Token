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
    uint256 private constant PRECISION_FACTOR=1e18;
    uint256 private s_interestRate=5e10;//you can work with decimals in solidity 
    //50/100 *1e18 = 5e10
mapping (address=>uint256) public s_userInterestRate;
mapping (address=>uint256) public s_lastUpdatedTimestamp;
//you need to calculate time so that you know the amnount of interest that has accrued


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
 * @notice mint the user tokens
 * @param _to the user to mint the tokens to
 * @param _amount the amount of tokens to mint
 * 
 */
function mint(address _to, uint256 _amount) external{
    // at point of minting we want to set our own interest rate
s_userInterestRate[_to]=s_interestRate;
_mint(_to,_amount);//from openzeppelin
//if someone has minted before, interest is done before acrued interest
_mintAccruedInterest(_to);//mint any interest that has accrued simnce last

}

function _mintAccruedInterest(address _user) internal (uint256){
//1find current balance
// 2 and also current balance including interest
//calculate the number of RebaseToken that need to be minted to the user 2-1->interest
//calll _mint to mint user tokens
//set user's last timestamp
s_userLastUpdatedTimestamp[]=block.timetsamp;



}

/**
 * @notice balance user
 * @param _to the user to mint the tokens to
 * @return balance of the user including the interest that has accumulated 
 * 
 */


function balanceOf(address _user)public view override returns (uint256){

//get current principal balance
//mulitply multiple balance with the interest that has accrumulated in the time since last update
return super.balanceOf(_user) * _calculateAccruedInterestSinceLastUpdate(_user)/PRECISION_FACTOR;
//to preseve precision you divide after as much multiplying as possible
//super.- means find fucntion in contract we are inheriting

}


/**
 * @notice calculate the interest that has accumulated since the last update
 * @param _user The user to calculate the interest accumulated for
 * @return the interest that has accumulated since the last update
 * 
 */
function _calculateUserAccumulatedInterestSinceLastUpdate(address _user) external view returns (uint256){
//calculate interest that has accumulated since last update
//this is going to be linear growth with time
//1. calculate time since last update
//2 calculate linear growth
//(principal amount)(1+user interest rate * time elapsed)
//(principal amount)+(principal amount * user interest rate * time elapsed)
uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
linearInterest=PRECISION_FACTOR+(s_userInterestRate[_user]*timeElapsed);//we have to set it to exact accuracy so instead of 1 we are using 1e18 for precision
//if you have 1e18 that is basically 1 token
}

function getUserInterestRate(address _user) external view returns (uint256){
return s_userInterstRate[_user];

}

}