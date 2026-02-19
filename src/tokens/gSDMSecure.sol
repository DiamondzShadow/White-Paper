// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IAggregatorV3.sol";

/**
 * @title gSDMSecure
 * @notice Gold-backed basket token: 50% SDM + 50% XAUT.
 */
contract gSDMSecure is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable SDM;
    IERC20 public immutable XAUT;
    IAggregatorV3 public immutable xauUsdOracle;
    uint8 private immutable i_oracleDecimals;

    // SDM/USD price scaled to 6 decimals.
    uint256 public sdmPrice;
    uint256 public sdmPriceUpdatedAt;
    address public treasury;
    uint256 public mintFee;
    uint256 public redeemFee;
    bool public enforceRatio;
    uint256 public ratioTolerance;

    uint256 public constant SUGGESTED_SDM_WEIGHT = 50;
    uint256 public constant SUGGESTED_XAUT_WEIGHT = 50;

    uint256 private constant BASIS_POINTS = 10_000;
    uint256 private constant STALENESS_THRESHOLD = 3 hours;
    uint256 private constant MAX_FEE = 200; // 2%
    uint256 private constant MAX_SDM_PRICE = 1_000_000e6; // 1,000,000 USD, 6 decimals

    event Minted(
        address indexed user, uint256 sdmIn, uint256 xautIn, uint256 gsdmOut, uint256 feeCharged
    );
    event Redeemed(
        address indexed user, uint256 gsdmIn, uint256 sdmOut, uint256 xautOut, uint256 feeCharged
    );
    event SDMPriceUpdated(uint256 newPrice, uint256 timestamp);
    event FeesUpdated(uint256 mintFee, uint256 redeemFee);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event RatioEnforcementUpdated(bool enforced, uint256 tolerance);

    error StalePrice();
    error InvalidPrice();
    error InvalidAmount();
    error InvalidFee();
    error InvalidRatio();
    error SlippageExceeded();
    error ZeroAddress();
    error Unauthorized();

    constructor(
        address _sdm,
        address _xaut,
        address _xauUsdOracle,
        uint256 _initialSdmPrice,
        address _treasury
    ) ERC20("Gold-backed SDM", "gSDM") {
        if (_sdm == address(0) || _xaut == address(0) || _xauUsdOracle == address(0)) {
            revert ZeroAddress();
        }
        if (_treasury == address(0)) revert ZeroAddress();
        if (_initialSdmPrice == 0 || _initialSdmPrice > MAX_SDM_PRICE) revert InvalidPrice();

        SDM = IERC20(_sdm);
        XAUT = IERC20(_xaut);
        xauUsdOracle = IAggregatorV3(_xauUsdOracle);
        i_oracleDecimals = xauUsdOracle.decimals();

        sdmPrice = _initialSdmPrice;
        sdmPriceUpdatedAt = block.timestamp;
        treasury = _treasury;
        ratioTolerance = 500; // 5%
    }

    function mint(uint256 sdmAmount, uint256 xautAmount, uint256 minGsdmOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 gsdmAmount)
    {
        if (sdmAmount == 0 && xautAmount == 0) revert InvalidAmount();

        uint256 sdmValueUsd = _getSDMValueUSD(sdmAmount);
        uint256 xautValueUsd = _getXAUTValueUSD(xautAmount);

        if (enforceRatio && sdmAmount > 0 && xautAmount > 0) {
            _validateRatio(sdmValueUsd, xautValueUsd);
        }

        uint256 totalValueUsd = sdmValueUsd + xautValueUsd;
        uint256 grossGsdmAmount = totalValueUsd * 1e12;

        uint256 feeCharged;
        if (mintFee > 0) {
            feeCharged = (grossGsdmAmount * mintFee) / BASIS_POINTS;
        }
        gsdmAmount = grossGsdmAmount - feeCharged;

        if (gsdmAmount < minGsdmOut) revert SlippageExceeded();

        if (sdmAmount > 0) SDM.safeTransferFrom(msg.sender, address(this), sdmAmount);
        if (xautAmount > 0) XAUT.safeTransferFrom(msg.sender, address(this), xautAmount);

        _mint(msg.sender, gsdmAmount);
        if (feeCharged > 0) _mint(treasury, feeCharged);
        emit Minted(msg.sender, sdmAmount, xautAmount, gsdmAmount, feeCharged);
    }

    function redeem(uint256 gsdmAmount, uint256 minSdmOut, uint256 minXautOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 sdmAmount, uint256 xautAmount)
    {
        if (gsdmAmount == 0) revert InvalidAmount();

        uint256 supply = totalSupply();
        if (supply == 0) revert InvalidAmount();

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 xautReserve = XAUT.balanceOf(address(this));

        sdmAmount = (sdmReserve * gsdmAmount) / supply;
        xautAmount = (xautReserve * gsdmAmount) / supply;

        uint256 feeCharged;
        if (redeemFee > 0) {
            uint256 sdmFee = (sdmAmount * redeemFee) / BASIS_POINTS;
            uint256 xautFee = (xautAmount * redeemFee) / BASIS_POINTS;

            sdmAmount -= sdmFee;
            xautAmount -= xautFee;
            feeCharged = sdmFee + xautFee;

            if (sdmFee > 0) SDM.safeTransfer(treasury, sdmFee);
            if (xautFee > 0) XAUT.safeTransfer(treasury, xautFee);
        }

        if (sdmAmount < minSdmOut || xautAmount < minXautOut) revert SlippageExceeded();

        _burn(msg.sender, gsdmAmount);

        if (sdmAmount > 0) SDM.safeTransfer(msg.sender, sdmAmount);
        if (xautAmount > 0) XAUT.safeTransfer(msg.sender, xautAmount);

        emit Redeemed(msg.sender, gsdmAmount, sdmAmount, xautAmount, feeCharged);
    }

    function getPrice() public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return 1e6;

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 xautReserve = XAUT.balanceOf(address(this));
        uint256 totalValueUsd = _getSDMValueUSD(sdmReserve) + _getXAUTValueUSD(xautReserve);

        return (totalValueUsd * 1e18) / supply;
    }

    function getRedeemPrice() external view returns (uint256) {
        uint256 price = getPrice();
        if (redeemFee > 0) price -= (price * redeemFee) / BASIS_POINTS;
        return price;
    }

    function quoteMint(uint256 sdmAmount, uint256 xautAmount)
        external
        view
        returns (uint256 gsdmOut, uint256 feeAmount)
    {
        uint256 totalValueUsd = _getSDMValueUSD(sdmAmount) + _getXAUTValueUSD(xautAmount);
        gsdmOut = totalValueUsd * 1e12;

        if (mintFee > 0) {
            feeAmount = (gsdmOut * mintFee) / BASIS_POINTS;
            gsdmOut -= feeAmount;
        }
    }

    function quoteRedeem(uint256 gsdmAmount)
        external
        view
        returns (uint256 sdmOut, uint256 xautOut, uint256 feeAmount)
    {
        uint256 supply = totalSupply();
        if (supply == 0) return (0, 0, 0);

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 xautReserve = XAUT.balanceOf(address(this));

        sdmOut = (sdmReserve * gsdmAmount) / supply;
        xautOut = (xautReserve * gsdmAmount) / supply;

        if (redeemFee > 0) {
            uint256 sdmFee = (sdmOut * redeemFee) / BASIS_POINTS;
            uint256 xautFee = (xautOut * redeemFee) / BASIS_POINTS;

            sdmOut -= sdmFee;
            xautOut -= xautFee;
            feeAmount = sdmFee + xautFee;
        }
    }

    function suggestedSDM(uint256 xautAmount) external view returns (uint256) {
        uint256 xautValueUsd = _getXAUTValueUSD(xautAmount);
        return (xautValueUsd * 1e18) / _getSDMPriceUSD();
    }

    function suggestedXAUT(uint256 sdmAmount) external view returns (uint256) {
        uint256 sdmValueUsd = _getSDMValueUSD(sdmAmount);
        return (sdmValueUsd * 1e6) / _getXAUPriceUSD();
    }

    function getReserves() external view returns (uint256 sdmReserve, uint256 xautReserve) {
        sdmReserve = SDM.balanceOf(address(this));
        xautReserve = XAUT.balanceOf(address(this));
    }

    function getGoldBackingUSD() external view returns (uint256) {
        return _getXAUTValueUSD(XAUT.balanceOf(address(this)));
    }

    function getCurrentRatio() external view returns (uint256 sdmRatioBps, uint256 xautRatioBps) {
        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 xautReserve = XAUT.balanceOf(address(this));
        uint256 sdmValueUsd = _getSDMValueUSD(sdmReserve);
        uint256 xautValueUsd = _getXAUTValueUSD(xautReserve);
        uint256 totalValueUsd = sdmValueUsd + xautValueUsd;

        if (totalValueUsd == 0) return (5000, 5000);

        sdmRatioBps = (sdmValueUsd * BASIS_POINTS) / totalValueUsd;
        xautRatioBps = BASIS_POINTS - sdmRatioBps;
    }

    function updateSDMPrice(uint256 newPrice) external onlyOwner {
        if (newPrice == 0 || newPrice > MAX_SDM_PRICE) revert InvalidPrice();
        sdmPrice = newPrice;
        sdmPriceUpdatedAt = block.timestamp;
        emit SDMPriceUpdated(newPrice, block.timestamp);
    }

    function updateFees(uint256 _mintFee, uint256 _redeemFee) external onlyOwner {
        if (_mintFee > MAX_FEE || _redeemFee > MAX_FEE) revert InvalidFee();
        mintFee = _mintFee;
        redeemFee = _redeemFee;
        emit FeesUpdated(_mintFee, _redeemFee);
    }

    function updateTreasury(address _treasury) external onlyOwner {
        if (_treasury == address(0)) revert ZeroAddress();
        emit TreasuryUpdated(treasury, _treasury);
        treasury = _treasury;
    }

    function setRatioEnforcement(bool _enforce, uint256 _tolerance) external onlyOwner {
        if (_tolerance > 2000) revert InvalidRatio(); // max 20%
        enforceRatio = _enforce;
        ratioTolerance = _tolerance;
        emit RatioEnforcementUpdated(_enforce, _tolerance);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function emergencyWithdraw(address token, uint256 amount) external onlyOwner whenPaused {
        if (token != address(SDM) && token != address(XAUT)) revert Unauthorized();
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(treasury, amount);
    }

    function _getSDMValueUSD(uint256 sdmAmount) private view returns (uint256) {
        // SDM amount is 18 decimals, SDM price is 6 decimals, output is USD with 6 decimals.
        return (sdmAmount * _getSDMPriceUSD()) / 1e18;
    }

    function _getXAUTValueUSD(uint256 xautAmount) private view returns (uint256) {
        return (xautAmount * _getXAUPriceUSD()) / 1e6;
    }

    function _getSDMPriceUSD() private view returns (uint256) {
        if (sdmPrice == 0) revert InvalidPrice();
        if (block.timestamp - sdmPriceUpdatedAt > STALENESS_THRESHOLD) revert StalePrice();
        return sdmPrice;
    }

    function _getXAUPriceUSD() private view returns (uint256) {
        (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
            xauUsdOracle.latestRoundData();

        if (answer <= 0 || updatedAt == 0 || answeredInRound < roundId) revert InvalidPrice();
        if (block.timestamp - updatedAt > STALENESS_THRESHOLD) revert StalePrice();

        uint256 price = uint256(answer);
        if (i_oracleDecimals > 6) return price / 10 ** (i_oracleDecimals - 6);
        return price * 10 ** (6 - i_oracleDecimals);
    }

    function _validateRatio(uint256 sdmValueUsd, uint256 xautValueUsd) private view {
        uint256 totalValue = sdmValueUsd + xautValueUsd;
        uint256 sdmRatioBps = (sdmValueUsd * BASIS_POINTS) / totalValue;
        uint256 deviation = sdmRatioBps > 5000 ? sdmRatioBps - 5000 : 5000 - sdmRatioBps;
        if (deviation > ratioTolerance) revert InvalidRatio();
    }
}
