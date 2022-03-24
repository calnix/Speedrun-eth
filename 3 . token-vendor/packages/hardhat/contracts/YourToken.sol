// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    
    // ERC20(token_name,token_symbol) is the constructor of ERC20.sol
    constructor() ERC20("Gold", "GLD") {
        _mint(msg.sender, 2000 * 10 ** 18); // mint 1000 tokens, allowing for 18 d.p.
        
    }
}


/*
msg.sender doesn wrk in part 1, cos we are not deploying from the FE address
- not sure where hardhat is deploying from

in ckpt3, we use msg.sender, since on deploying Vendor, we will deploy YourToken.
here, msg.sender = contract address of Vendor.sol

*/