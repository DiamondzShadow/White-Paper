// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @custom:security-contact development@diamondzshadow.com
contract DiamondzShadowMovies is ERC20, ERC20Permit, Ownable {
    constructor(address initialOwner)
        ERC20("Diamondz Shadow Movies", "SDM")
        ERC20Permit("Diamondz Shadow Movies")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }
}
