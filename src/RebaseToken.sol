//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/**
 * @title RebaseToken
 * @author Louis
 * @notice This is a rebase token that incentivises users to deposit
 * @notice Interest rate can only deposit
 * @notice each user will have global interest rate at the point of deposit
 */

// to add access control we have to make this contract ownable
contract RebaseToken is ERC20,Ownable,AccessControl
{
    ////////////////
    //Errors
    error RebaseToken__InterestRateCanOnlyDecrease();

     ////////////////
    //STATE VARIABLES
    uint256 private constant PRECISION_FACTOR=1e18;
    //we can reduce precision factor to prevent overflow but we want to be able to have very small interest rates
    //grant a role by hashing a string which represents  a role
    byes32 private constant MINT_AND_BURN_ROLE=keccak256("MINT_AND_BURN_ROLE");
    //THIS IS HOW YOU CREATE A SPECIFIC ROLE
    uint256 private s_interestRate=(5*PRECISION_FACTOR)/1e8;//you can work with decimals in solidity 
    //50/100 *1e18 = 5e10
mapping (address=>uint256) public s_userInterestRate;
mapping (address=>uint256) public s_lastUpdatedTimestamp;
//you need to calculate time so that you know the amnount of interest that has accrued


     ////////////////
    //EVENTS
    event InterestRateSet(uint256 newInterestRate);

//transfer function of ERC20.sol ->we have to override the transfer function because people can send small amounts to drive the interest down for people

constructor() ERC20("RebaseToken","RCT") Ownable(msg.sender)// we pass in whoever wants to be the owner
{}

function grantMintAndBurnRole(address _account) external onlyOwner{
_grantRole(MINT_AND_BURN_ROLE,_account);

}

/**
 * @notice Set the interest rate in the contract
 * @param _newInterestRate The ne interest rate to be set
 * @dev The interest rate can only decrease
 * 
 */
//we add only owner because set interest is only callable by owner,
 //thats why we import Owner from Openzeppelin
function setInterestRate(uint256 _newInterestRate) external onlyOwner{
if (_newInterestRate>s_interestRate){
    revert RebaseToken__InterestRateCanOnlyDecrease();
}
     s_interestRate = _newInterestRate;
    emit InterestRateSet(_newInterestRate);

// in openzeppelin we have AccessControl.sol
//this helps you give certain addresses certain roles ie you can call this if you have a certain role
//you can grant role or revoke role
//we create role for minting nad burning

}

/**
 * @notice mint the user tokens
 * @param _to the user to mint the tokens to
 * @param _amount the amount of tokens to mint
 * 
 */
function mint(address _to, uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE)
{
    // at point of minting we want to set our own interest rate
s_userInterestRate[_to]=s_interestRate;
_mint(_to,_amount);//from openzeppelin
//if someone has minted before, interest is done before acrued interest
_mintAccruedInterest(_to);//mint any interest that has accrued simnce last
_mint(_to,_address);
}

/**
 * @notice burn the user tokens when they withdraw from the vault
 * @param _from the user to burn the tokens from
 * @param _amount the amount of tokens to burn
 */
function burn(address _from,uint256 _amount)external//called when we transfer tokens cross chain
onlyRole(MINT_AND_BURN_ROLE)
{
    if (_amount==type(uint256).max){
_amount = balanceOf(_from);
}
    //redeem all tokens

_mintAccruedInterest(_from);
_burn(_from,_amount);

}




/**
 * @notice Mint interest of user since the last time they interacted with the protocol
 * @param _user The user to mint the accrued interest

 * 
 */
function _mintAccruedInterest(address _user) internal (uint256){
//1find current balance
uint256 previousPricipleBalance=super.balanceof(_user);//implementaion of the ERC20 contract method using super
// 2 and also current balance including interest
uint256 currentBalance =balanceOf(_user);
//calculate the number of RebaseToken that need to be minted to the user 2-1->interest
uint256 balanceIncrease=currentBalance-previousPricipleBalance;
//calll _mint to mint user tokens
//set user's last timestamp
//Effects
s_userLastUpdatedTimestamp[]=block.timetsamp;
//interactions
_mint(_user,balanceIncrease);



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
 * @notice Transfer tokens from one user to another
 * @param _recepient user tokens to
 * @param value _amount of tokens to transfer
 * 
 */
function transfer(address _recepient,uint256 value) public virtual returns (bool){
// address owner = _msg.Sender();
// _transfer(owner,to,value);
// return true;
//before we send tokens we have to check if interest nas accrued
//if they have any pending interest it will be minted to them
_mintAccruedInterest(msg.sender);
_mintAccruedInterest(_recepient);


if(_amount==type(uint256).max){
_amount=balanceOf(msg.sender);
}//check if recepient has interest rate, if not we set it
if (balanceOf(_recepient)==0){
s_userInterestRate[_recepient]=s_userInterestRate[msg.sender];
}
return super.transfer(_recepient,_amount);
//this will call the transfer function

}

/**
 * @notice Transfer tokens from one user to another
 * @param _recepient user tokens to
 * @param value _amount of tokens to transfer
 * 
 */
function transferFrom(address _sender, address _recepient, uint256 _amount) public override returns()
{
_mintAccruedInterest(_sender);
_mintAccruedInterest(_recepient);


if(_amount==type(uint256).max){
_amount=balanceOf(msg.sender);
}//check if recepient has interest rate, if not we set it
if (balanceOf(_recepient)==0){
s_userInterestRate[_recepient]=s_userInterestRate[_sender];//sent interest of sender

}
return super.transfer(_recepient,_amount);


}

/**
 * @notice Get principle balance of a user, this is the number of tokens that have been minted to user, excluding interest minted since last time of using the protocol
 * @param _user user to get baoance of
 * @return Principle balance of user
 * 
 */
function principleBalanceOf(address _user) external view returns (uint256)
{
return super.balanceOf[_user];
}

/**
 * @notice Get interest rate that is currently set for the contract. Any future deposit will receive this interest
 * @return Principle balance of user
 * 
 */
function getIntrestRate() external virw returns(uint256){
return s_interestRate;

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