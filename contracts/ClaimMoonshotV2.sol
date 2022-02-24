/*

             ██████╗██╗      █████╗ ██╗███╗   ███╗                       
            ██╔════╝██║     ██╔══██╗██║████╗ ████║                       
            ██║     ██║     ███████║██║██╔████╔██║                       
            ██║     ██║     ██╔══██║██║██║╚██╔╝██║                       
            ╚██████╗███████╗██║  ██║██║██║ ╚═╝ ██║                       
             ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝                       
                                                                         
███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗███████╗██╗  ██╗ ██████╗ ████████╗
████╗ ████║██╔═══██╗██╔═══██╗████╗  ██║██╔════╝██║  ██║██╔═══██╗╚══██╔══╝
██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║███████╗███████║██║   ██║   ██║   
██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║╚════██║██╔══██║██║   ██║   ██║   
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║███████║██║  ██║╚██████╔╝   ██║   
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   
                                                                           

Let user claim tokens based on balance of another BEP20 token

Contract owner should:
  - set token from address
  - set token to address
 
Contract must be funded.
 
Tokens funded can never be withdrawn (but they can be burned by owner)

*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

import "contracts/IERC20.sol";
import "contracts/Context.sol";
import "contracts/Ownable.sol";

contract ClaimMoonshotV2 is Context, Ownable {
    
    address public fromContract = 0x000000000000000000000000000000000000dEaD;
    address public toContract = 0x000000000000000000000000000000000000dEaD;

    mapping (address => bool) private _claimed;
    mapping( address => bool) private _isBlackListed;

    uint256 public _totalClaimed = 0;
    
    event SetFromTokenAddress(address newTokenContract);
    event SetToTokenAddress(address newTokenContract);
    event Claimed(address account, uint256 amount);
    event AddToBlackList(address account);
    event RemoveFromBlackList(address account);
    event RescueBNB(uint256 amount);
    event Burn(uint256 amount);

    constructor () public {
    }
 
    function setFromTokenAddress(address newTokenContract) external onlyOwner() {
        fromContract = newTokenContract;

        emit SetFromTokenAddress(fromContract);
    }

    function setToTokenAddress(address newTokenContract) external onlyOwner() {
        toContract = newTokenContract;

        emit SetToTokenAddress(toContract);
    }

    function hasClaimed() external view returns (bool) {
        return _claimed[ msg.sender ];
    }

    function getClaimAmount() external view returns (uint256) {
        if( _claimed[msg.sender] || _isBlackListed[msg.sender]) {
            return 0;
        }
        return IERC20(fromContract).balanceOf(msg.sender);
    }

    function claim() external {

        require( !_claimed[ msg.sender ], "Already claimed" );
        require( !_isBlackListed[msg.sender], "Blacklisted account");

        uint256 amount = IERC20(fromContract).balanceOf(msg.sender);
        require( amount > 0, "Your balance must be greater than 0");

        uint256 contractAmount = IERC20(toContract).balanceOf( address(this) );
        require( contractAmount > 0 , "Out of tokens");
        require( amount <= contractAmount, "Not enough tokens");

        IERC20(toContract).transfer(msg.sender, amount);

        _claimed[ msg.sender ] = true;
        _totalClaimed += amount;

        emit Claimed(msg.sender, amount);
    }

    function claimByOwner(address beneficiary) external onlyOwner {

        require( !_claimed[beneficiary], "Already claimed");
        require( !_isBlackListed[beneficiary], "Blacklisted account");

        uint256 amount = IERC20(fromContract).balanceOf(beneficiary);
        require( amount > 0, "Account balance must be greater than 0");
        
        uint256 contractAmount = IERC20(toContract).balanceOf( address(this) );
        require( contractAmount > 0 , "Out of tokens");
        require( amount <= contractAmount, "Not enough tokens");

        IERC20(toContract).transfer(beneficiary , amount);

        _claimed[ msg.sender ] = true;
        _totalClaimed += amount;

        emit Claimed(msg.sender, amount);
    }
   
    function addToBlackList(address account) external onlyOwner {
        _isBlackListed[ account ] = true;

        emit AddToBlackList(account);
    }

    function removeFromBlackList(address account) external onlyOwner {
        _isBlackListed[ account ] = false;

        emit RemoveFromBlackList(account);
    }

    function isBlackListed(address account) external view returns(bool) {
        return _isBlackListed[ account ];
    }

    // owner can burn but not take
    function burn() external onlyOwner {
        address payable burnAddress = payable(0x000000000000000000000000000000000000dEaD);
        uint256 tokenBalance = IERC20(toContract).balanceOf( address(this) );
        IERC20(toContract).transfer(burnAddress, tokenBalance);
        emit Burn(tokenBalance);
    }

    // BNB sent by mistake can be returned
    function rescueBNB() external onlyOwner {
        uint256 balance = address(this).balance;

        payable( msg.sender ).transfer( balance );
        
        emit RescueBNB(balance);
    }
  
    receive() external payable {}

}