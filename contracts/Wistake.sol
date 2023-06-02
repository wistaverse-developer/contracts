// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice The constructor for the Wistake Token.
contract Wistake is ERC20, Ownable {
    constructor() ERC20("Wistake", "SWISTA") {
        _mint(msg.sender, 42 * (10**24));
    }
}
