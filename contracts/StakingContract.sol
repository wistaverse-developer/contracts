// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    IERC20 private token;
    mapping(address => uint256) private balances;
    address[] private stakers; // Tableau pour stocker les adresses des stakers

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.balanceOf(msg.sender) >= amount,
            "Insufficient token balance"
        );

        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;

        // Enregistrer l'adresse du staker uniquement s'il n'est pas déjà enregistré
        if (!isStaker(msg.sender)) {
            stakers.push(msg.sender);
        }

        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            balances[msg.sender] >= amount,
            "Insufficient staked balance"
        );

        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    function getStakedBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function getStakers() external view returns (address[] memory) {
        return stakers;
    }

    function isStaker(address user) public view returns (bool) {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (stakers[i] == user) {
                return true;
            }
        }
        return false;
    }
}
