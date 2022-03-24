pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  
  constructor(address _exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(_exampleExternalContractAddress);
  }


  uint public constant threshold = 1 ether;              // threshold
  uint deadline = block.timestamp + 60 seconds;         //deadline time
  mapping (address => uint) public balances;            //balances mapping
  event Stake(address indexed _address, uint _amt);     //event 

  // for valid staking -> deadlineReached(F). ensure tt there is timeleft
  // for all others -> deadlineReached(T). execution can only be done after deadline
  modifier deadlineHit(bool requireReached) {
    uint timeleft = timeLeft();
    if(requireReached){
        require(timeleft == 0, "Deadline not reached");
    }else {
        require(timeleft > 0, "Deadline reached");
    }
    _;
  }  

  // threhold hit/no hit
  modifier thresholdHit(bool requireReached){
    if(requireReached){
      require(address(this).balance >= threshold, "Threshold has not been hit");
    }else {
      require(address(this).balance < threshold, "Threshold has been hit");
    }
    _;
  }
  
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display
  // condition: can stake before deadline. nothing after. 
  function stake() public payable deadlineHit(false) {
    emit Stake(msg.sender, msg.value);
    balances[msg.sender] += msg.value;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public deadlineHit(true) thresholdHit(true) {
    require(exampleExternalContract.completed() == false, "Execute was ran once already");       //execute shld only be called once.
    // send contract balance to external SC & call complete()
    (bool success,) = address(exampleExternalContract).call{value: address(this).balance}(abi.encodeWithSignature("complete()"));
    require(success,"Staking balance transfer failed!");
  } 

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw(address payable)` function lets users withdraw their balance
  function withdraw() public deadlineHit(true) thresholdHit(false) {
    require(balances[msg.sender] > 0, "You have nothing to withdraw!");  //sanity check

    //update internal state first
    uint usrBalance = balances[msg.sender];
    balances[msg.sender] = 0;

    //transfer via call
    (bool success,) = msg.sender.call{value: usrBalance}("");
    require(success,"Withdrawal has failed!");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint time) {
    if(block.timestamp < deadline){
      return deadline - block.timestamp;
    }else{
      return 0; 
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

}
