const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("WistaverseStaking", function () {
  let stakingContract;
  let wistaverseToken;
  let owner;
  let user1;
  let user2;


  const AMOUNT = ethers.utils.parseEther("100");

  beforeEach(async function () {
    const WistaverseToken = await ethers.getContractFactory("Wistaverse");
    const StakingContract = await ethers.getContractFactory("StakingContract");

    [owner, user1, user2] = await ethers.getSigners();

    wistaverseToken = await WistaverseToken.deploy();
    await wistaverseToken.deployed();

    stakingContract = await StakingContract.deploy(wistaverseToken.address);
    await stakingContract.deployed();
  });

  it("should stake tokens", async function () {
    await wistaverseToken.transfer(user1.address, AMOUNT);
    await wistaverseToken.connect(user1).approve(stakingContract.address, AMOUNT);

    await stakingContract.connect(user1).stake(AMOUNT);

    const userBalance = await wistaverseToken.balanceOf(user1.address);
    const stakedBalance = await stakingContract.getStakedBalance(user1.address);

    expect(userBalance).to.equal(ethers.BigNumber.from(0));
    expect(stakedBalance).to.equal(AMOUNT);
  });

  it("should unstake tokens", async function () {
    await wistaverseToken.transfer(user1.address, AMOUNT);
    await wistaverseToken.connect(user1).approve(stakingContract.address, AMOUNT);

    await stakingContract.connect(user1).stake(AMOUNT);
    await stakingContract.connect(user1).unstake(AMOUNT);

    const userBalance = await wistaverseToken.balanceOf(user1.address);
    const stakedBalance = await stakingContract.getStakedBalance(user1.address);

    expect(userBalance).to.equal(AMOUNT);
    expect(stakedBalance).to.equal(ethers.BigNumber.from(0));
  });

  it("should return an empty array for stakers initially", async function () {
    const stakers = await stakingContract.getStakers();
    expect(stakers).to.have.lengthOf(0);
  });

  it("should add a staker when staking tokens", async function () {
    await wistaverseToken.transfer(user1.address, AMOUNT);
    await wistaverseToken.connect(user1).approve(stakingContract.address, AMOUNT);

    await stakingContract.connect(user1).stake(AMOUNT);
    const stakers = await stakingContract.getStakers();
    expect(stakers).to.have.lengthOf(1);
    expect(stakers[0]).to.equal(user1.address);
  });

  it("should not add a staker again when staking more tokens", async function () {
    await wistaverseToken.transfer(user1.address, AMOUNT);
    await wistaverseToken.connect(user1).approve(stakingContract.address, AMOUNT);

    await stakingContract.connect(user1).stake(10);
    await stakingContract.connect(user1).stake(10);

    const stakers = await stakingContract.getStakers();
    expect(stakers).to.have.lengthOf(1);
    expect(stakers[0]).to.equal(user1.address);
  });

  it("should return true for an existing staker and false for a non-staker", async function () {
    await wistaverseToken.transfer(user1.address, AMOUNT);
    await wistaverseToken.connect(user1).approve(stakingContract.address, AMOUNT);

    await stakingContract.connect(user1).stake(AMOUNT);

    const isAddr1Staker = await stakingContract.isStaker(user1.address);
    expect(isAddr1Staker).to.be.true;

    const isAddr2Staker = await stakingContract.isStaker(user2.address);
    expect(isAddr2Staker).to.be.false;
  });
});
