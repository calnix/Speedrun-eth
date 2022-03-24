// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  uint public constant tokensPerEth = 100;   // token price for Eth: 1ETH = 100 tokens


  //event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event BuyTokens(address indexed buyer, uint amountOfETH, uint amountOfTokens);

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns(uint) {
    require(msg.value > 0, "No eth sent!");     //sanity check
    
    uint tokenQty = msg.value*tokensPerEth;     //purchase amt

  //check if vendor has required tokens
    uint vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= tokenQty, "Not enough inventory on Vendor Contract!");

  //transfer to buyer
    (bool transfer) = yourToken.transfer(msg.sender, tokenQty);
    require(transfer, "Transfer failed!");

  //emit event
    emit BuyTokens(msg.sender, msg.value, tokenQty);
    return(tokenQty);             //incase other SC call, can return a useful value to them. omittable. 
  }


  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner {        //onlyOwner from Ownable.sol
    require(address(this).balance > 0, "Nothing to withdraw");

    (bool sent,) = msg.sender.call{value:address(this).balance}("");
    require(sent, "Withdraw failed!");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint _sellamt) public {
    require(_sellamt > 0, "Specify a non-zero amt to sell");
    require(_sellamt <= yourToken.balanceOf(msg.sender), "Your balance is lower than sell amount");

    // Can Vendor buy? - enough eth
    uint _ethRequired = _sellamt/tokensPerEth;
    require(_ethRequired <= address(this).balance, "Vendor does not have enough ETH for this transaction");

    // approve how ?(bool sent,) = yourToken.approve(spender, amount);
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), _sellamt);
    require(sent, "Token transfer frm User to Vendor failed!");

    //send eth
    (sent,) = msg.sender.call{value:_ethRequired}("");
    require(sent, "Sending ETH from Vendor to User failed!");

 

  }
}
