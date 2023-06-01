// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Wistaverse is ERC20, ERC20Votes, Ownable {
    mapping(address => bool) public isExemptedFromFee;

    uint256 public feePercentage = 0; // 1% = 100
    uint256 private immutable feeDecimal = 10000;

    address public feeRecipient;

    event FeePercentageChanged(uint256 feePercentage);

    /// @notice The constructor for the Wistaverse Token.
    constructor() ERC20("Wistaverse", "WISTA") ERC20Permit("Wistaverse") {
        // Initialize fee recipient
        feeRecipient = 0x61A9206B23d453c865c13Cd6B26dB132F180Ad6F; // treasury
        // Initialize fee exemptions
        isExemptedFromFee[0x136f63CB8817D397493a617f3FA5BE81917e2C9c] = true; // main wallet
        isExemptedFromFee[0x61A9206B23d453c865c13Cd6B26dB132F180Ad6F] = true; // treasury & cex
        isExemptedFromFee[0x80DeDfE37c110F9e071501C9F633602302024f7b] = true; // contributors
        isExemptedFromFee[0x3d957A430A70B5DF793B1D2412C226055CfdE756] = true; // advisors & partners
        isExemptedFromFee[0x65ce5B436e4073ca18DD62bAAE6024eecB69B315] = true; // team
        isExemptedFromFee[0xfF81B1B1E3bB1081c6585256C988f2eAca5d6113] = true; // marketing
        isExemptedFromFee[0x79E1D2a1D38dB40aB47ce177373C43bdc3a84A83] = true; // rewards & community incentives
        isExemptedFromFee[0xdd2a6615e28Ab9084f063015364FE21B1FAE6C8e] = true; // airdrops

        _mint(msg.sender, 42 * (10**24));
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        return _transferFrom(from, to, amount);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        if (_shouldPayFee(from) && _shouldPayFee(to)) {
            uint256 fee = (amount * feePercentage) / feeDecimal;

            if (fee > 0) {
                _transfer(from, feeRecipient, fee);
                unchecked {
                    amount = amount - fee;
                }
            }

            _transfer(from, to, amount);
        } else {
            _transfer(from, to, amount);
        }
        return true;
    }

    // ============ FEES ============

    function setFeePercentage(uint256 _fee) external onlyOwner {
        require(_fee <= 50, "Fee cannot exceed 0.5%");
        feePercentage = _fee;
        emit FeePercentageChanged(_fee);
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "Can't change to zero address");
        feeRecipient = _feeRecipient;
    }

    function setFeeExemption(address _address, bool _isExempted)
        external
        onlyOwner
    {
        isExemptedFromFee[_address] = _isExempted;
    }

    function _shouldPayFee(address _address) internal view returns (bool) {
        return !isExemptedFromFee[_address];
    }

    /// @dev Necessary overrides for votes
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
