// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Wistake is ERC20, Ownable {
    constructor() ERC20("Wistake", "SWISTA") {
        _mint(msg.sender, 42000000 * (10 ** uint256(decimals())));
    }
}
