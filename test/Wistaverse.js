const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { BigNumber } = require("ethers");

const totalSupply = BigNumber.from("42").mul(BigNumber.from("10").pow(24));
const initialFee = 0.005;

describe("Wistaverse Token", function () {
  async function deployFixture() {
    const [owner, account1, account2] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Wistaverse");
    const token = await Token.deploy();
    await token.deployed();

    // Set fees to 0.5% for tests
    await token.setFeePercentage(50);

    return { token, owner, account1, account2 };
  }

  describe("Deployment", function () {
    it("Initial configuration should be properly set up", async function () {
      const { token } = await loadFixture(deployFixture);

      expect(await token.name()).to.equal("Wistaverse");
      expect(await token.symbol()).to.equal("WISTA");
      expect(await token.decimals()).to.equal(18);
      expect(await token.totalSupply()).to.equal(totalSupply);
    });

    it("Owner of the contract should be deployer", async function () {
      const { token, owner } = await loadFixture(deployFixture);
      expect(await token.owner()).to.equal(owner.address);
    });

    it("Total supply should be initially minted to deployer account", async function () {
      const { token, owner } = await loadFixture(deployFixture);
      expect(await token.balanceOf(owner.address)).to.equal(totalSupply);
    });
  });

  describe("Transfers", function () {
    it("Exempted account should be able to transfer tokens without fees", async function () {
      const { token, owner, account1, account2 } = await loadFixture(
        deployFixture
      );
      // Exempt account1 from fees
      await token.setFeeExemption(account1.address, true);
      // Owner transfers 1000 tokens to account1
      await token.transfer(account1.address, 1000);
      // Account1 transfers 1000 tokens to account2
      await token.connect(account1).transfer(account2.address, 1000);
      expect(await token.balanceOf(account1.address)).to.be.equal(0);
      expect(await token.balanceOf(account2.address)).to.be.equal(1000);
    });
  });

  describe("Fees", function () {
    it("Fees cannot be set above a max of 0.5%", async function () {
      const { token, owner } = await loadFixture(deployFixture);
      // Trying to set fees at 1% above the max of 0.5%
      await expect(token.setFeePercentage(100)).to.be.revertedWith(
        "Fee cannot exceed 0.5%"
      );
    });

    it("Owner should be able to revoke an account's fee exemption", async function () {
      const { token, owner, account1, account2 } = await loadFixture(
        deployFixture
      );
      // Exempt account1 from fees
      await token.setFeeExemption(account1.address, true);
      // Owner transfers 2000 tokens to account1
      await token.transfer(account1.address, 2000);
      // Account1 transfers 1000 tokens to account2 without fees
      await token.connect(account1).transfer(account2.address, 1000);
      expect(await token.balanceOf(account1.address)).to.be.equal(1000);
      expect(await token.balanceOf(account2.address)).to.be.equal(1000);
      // Revoke exemption from account1
      await token.setFeeExemption(account1.address, false);
      // Account1 transfers 1000 tokens to account2 paying fees
      await token.connect(account1).transfer(account2.address, 1000);
      expect(await token.balanceOf(account1.address)).to.be.equal(0);
      expect(await token.balanceOf(account2.address)).to.be.equal(
        2000 - 1000 * initialFee
      );
    });

    it("Only Owner should be able to change fees", async function () {
      const { token, owner, account1 } = await loadFixture(deployFixture);
      // Trying to set fees as account1
      await expect(
        token.connect(account1).setFeePercentage(0)
      ).to.be.revertedWith("Ownable: caller is not the owner");
      expect(await token.feePercentage()).to.be.equal(50);
      // Set fees to 0% as owner
      await token.setFeePercentage(0);
      expect(await token.feePercentage()).to.be.equal(0);
    });

    it("Only Owner should be able to set fee exemption status", async function () {
      const { token, owner, account1 } = await loadFixture(deployFixture);
      // Trying to set fee exemption as account1
      await expect(
        token.connect(account1).setFeeExemption(account1.address, true)
      ).to.be.revertedWith("Ownable: caller is not the owner");
      expect(await token.isExemptedFromFee(account1.address)).to.not.equal(
        true
      );
      // Set fee exemption for account1 as owner
      await token.setFeeExemption(account1.address, true);
      expect(await token.isExemptedFromFee(account1.address)).to.equal(true);
    });
  });
});
