// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    ERC20 private wistaverseToken;
    ERC20 private wistakeToken;
    mapping(address => uint256) private balances;
    address[] private stakers;
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    constructor(address _wistaverseTokenAddress, address _wistakeTokenAddress) {
        wistaverseToken = ERC20(_wistaverseTokenAddress);
        wistakeToken = ERC20(_wistakeTokenAddress);
    }

    function wistakeProvision(uint256 amount) external onlyOwner {
        wistakeToken.transferFrom(msg.sender, address(this), amount);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            wistaverseToken.balanceOf(msg.sender) >= amount,
            "Insufficient wistaverseToken balance"
        );
        balances[msg.sender] += amount;
        if (!isStaker(msg.sender)) {
            stakers.push(msg.sender);
        }
        wistaverseToken.transferFrom(msg.sender, address(this), amount);
        wistakeToken.transfer(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            balances[msg.sender] >= amount,
            "Insufficient staked balance"
        );
        balances[msg.sender] -= amount;
        wistakeToken.transferFrom(msg.sender, address(this), amount);
        wistaverseToken.transfer(msg.sender, amount);
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
