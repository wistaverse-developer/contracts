// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Wistake is ERC20, Ownable {
    address public stakingContract;

    constructor() ERC20("Wistake", "SWISTA") {
        _mint(msg.sender, 42000000 * (10 ** uint256(decimals())));
    }

    function setStakingContract(address _stakingContract) external onlyOwner {
        stakingContract = _stakingContract;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(msg.sender == owner() || msg.sender == stakingContract, "Wistake Only allowed from owner or staking contract");
        return super.transfer(recipient, amount);
    }

    function getOwnerBalance() public view onlyOwner returns (uint256) {
        return balanceOf(owner());
    }
}
