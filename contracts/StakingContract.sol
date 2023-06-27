// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract StakingContract is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    ERC20 private wistaverseToken;
    ERC20 private wistakeToken;
    mapping(address => uint256) private balances;
    EnumerableSet.AddressSet private stakers;
    uint256 private totalStaked;
    uint256 private stakeAmount; // Variable pour le montant de mise
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address _wistaverseTokenAddress, address _wistakeTokenAddress, uint256 _stakeAmount) {
        wistaverseToken = ERC20(_wistaverseTokenAddress);
        wistakeToken = ERC20(_wistakeTokenAddress);
        stakeAmount = _stakeAmount;
    }

    function wistakeProvision(uint256 amount) external onlyOwner {
        wistakeToken.transferFrom(msg.sender, address(this), amount);
    }

    function stake(uint256 amount) external {
        require(amount == stakeAmount, "Amount must be equal to stake amount"); // Vérifier que le montant est égal au montant de mise
        require(
            wistaverseToken.balanceOf(msg.sender) >= amount,
            "Insufficient wistaverseToken balance"
        );
        balances[msg.sender] += amount;
        stakers.add(msg.sender);
        totalStaked += amount;
        wistaverseToken.transferFrom(msg.sender, address(this), amount);
        wistakeToken.transfer(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount == stakeAmount, "Amount must be equal to stake amount"); // Vérifier que le montant est égal au montant de mise
        require(
            balances[msg.sender] >= amount,
            "Insufficient staked balance"
        );

        balances[msg.sender] -= amount;
        wistakeToken.transferFrom(msg.sender, address(this), amount);
        wistaverseToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);

        if (balances[msg.sender] == 0) {
            stakers.remove(msg.sender);
        }

        totalStaked -= amount;
    }

    function getStakedBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function isStaker(address user) public view returns (bool) {
        return stakers.contains(user);
    }

    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        require(tokenAddress != address(wistaverseToken), "Cannot withdraw wistaverseToken");
        require(tokenAddress != address(wistakeToken), "Cannot withdraw wistakeToken");
        ERC20 token = ERC20(tokenAddress);
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient contract balance");
        token.transfer(msg.sender, amount);
    }

    function getStakeAmount() external view returns (uint256) {
        return stakeAmount;
    }
}
