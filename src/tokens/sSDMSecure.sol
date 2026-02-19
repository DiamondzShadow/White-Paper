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
 * @title sSDMSecure
 * @notice Stablecoin-backed basket token: 20% SDM + 80% USDC.
 */
contract sSDMSecure is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable SDM;
    IERC20 public immutable USDC;
    IAggregatorV3 public immutable usdcUsdOracle;
    uint8 private immutable i_oracleDecimals;

    uint256 public sdmPrice;
    uint256 public sdmPriceUpdatedAt;
    address public treasury;
    uint256 public mintFee;
    uint256 public redeemFee;
    bool public enforceRatio;
    uint256 public ratioTolerance;

    uint256 public constant SUGGESTED_SDM_WEIGHT = 20;
    uint256 public constant SUGGESTED_USDC_WEIGHT = 80;

    uint256 private constant BASIS_POINTS = 10_000;
    uint256 private constant STALENESS_THRESHOLD = 24 hours;
    uint256 private constant MAX_FEE = 200; // 2%

    event Minted(
        address indexed user, uint256 sdmIn, uint256 usdcIn, uint256 ssdmOut, uint256 feeCharged
    );
    event Redeemed(
        address indexed user, uint256 ssdmIn, uint256 sdmOut, uint256 usdcOut, uint256 feeCharged
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
        address _usdc,
        address _usdcUsdOracle,
        uint256 _initialSdmPrice,
        address _treasury
    ) ERC20("Stable SDM", "sSDM") {
        if (_sdm == address(0) || _usdc == address(0) || _usdcUsdOracle == address(0)) {
            revert ZeroAddress();
        }
        if (_treasury == address(0)) revert ZeroAddress();
        if (_initialSdmPrice == 0) revert InvalidPrice();

        SDM = IERC20(_sdm);
        USDC = IERC20(_usdc);
        usdcUsdOracle = IAggregatorV3(_usdcUsdOracle);
        i_oracleDecimals = usdcUsdOracle.decimals();

        sdmPrice = _initialSdmPrice;
        sdmPriceUpdatedAt = block.timestamp;
        treasury = _treasury;
        ratioTolerance = 1000; // 10%
    }

    function mint(uint256 sdmAmount, uint256 usdcAmount, uint256 minSsdmOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 ssdmAmount)
    {
        if (sdmAmount == 0 && usdcAmount == 0) revert InvalidAmount();

        uint256 sdmValueUsd = _getSDMValueUSD(sdmAmount);
        uint256 usdcValueUsd = _getUSDCValueUSD(usdcAmount);

        if (enforceRatio && sdmAmount > 0 && usdcAmount > 0) {
            _validateRatio(sdmValueUsd, usdcValueUsd);
        }

        uint256 totalValueUsd = sdmValueUsd + usdcValueUsd;
        ssdmAmount = totalValueUsd * 1e12;

        uint256 feeCharged;
        if (mintFee > 0) {
            feeCharged = (ssdmAmount * mintFee) / BASIS_POINTS;
            ssdmAmount -= feeCharged;
        }

        if (ssdmAmount < minSsdmOut) revert SlippageExceeded();

        if (sdmAmount > 0) SDM.safeTransferFrom(msg.sender, address(this), sdmAmount);
        if (usdcAmount > 0) USDC.safeTransferFrom(msg.sender, address(this), usdcAmount);

        _mint(msg.sender, ssdmAmount);
        emit Minted(msg.sender, sdmAmount, usdcAmount, ssdmAmount, feeCharged);
    }

    function redeem(uint256 ssdmAmount, uint256 minSdmOut, uint256 minUsdcOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 sdmAmount, uint256 usdcAmount)
    {
        if (ssdmAmount == 0) revert InvalidAmount();

        uint256 supply = totalSupply();
        if (supply == 0) revert InvalidAmount();

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 usdcReserve = USDC.balanceOf(address(this));

        sdmAmount = (sdmReserve * ssdmAmount) / supply;
        usdcAmount = (usdcReserve * ssdmAmount) / supply;

        uint256 feeCharged;
        if (redeemFee > 0) {
            uint256 sdmFee = (sdmAmount * redeemFee) / BASIS_POINTS;
            uint256 usdcFee = (usdcAmount * redeemFee) / BASIS_POINTS;

            sdmAmount -= sdmFee;
            usdcAmount -= usdcFee;
            feeCharged = sdmFee + usdcFee;

            if (sdmFee > 0) SDM.safeTransfer(treasury, sdmFee);
            if (usdcFee > 0) USDC.safeTransfer(treasury, usdcFee);
        }

        if (sdmAmount < minSdmOut || usdcAmount < minUsdcOut) revert SlippageExceeded();

        _burn(msg.sender, ssdmAmount);

        if (sdmAmount > 0) SDM.safeTransfer(msg.sender, sdmAmount);
        if (usdcAmount > 0) USDC.safeTransfer(msg.sender, usdcAmount);

        emit Redeemed(msg.sender, ssdmAmount, sdmAmount, usdcAmount, feeCharged);
    }

    function getPrice() public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return 1e6;

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 usdcReserve = USDC.balanceOf(address(this));
        uint256 totalValueUsd = _getSDMValueUSD(sdmReserve) + _getUSDCValueUSD(usdcReserve);

        return (totalValueUsd * 1e18) / supply;
    }

    function getRedeemPrice() external view returns (uint256) {
        uint256 price = getPrice();
        if (redeemFee > 0) price -= (price * redeemFee) / BASIS_POINTS;
        return price;
    }

    function quoteMint(uint256 sdmAmount, uint256 usdcAmount)
        external
        view
        returns (uint256 ssdmOut, uint256 feeAmount)
    {
        uint256 totalValueUsd = _getSDMValueUSD(sdmAmount) + _getUSDCValueUSD(usdcAmount);
        ssdmOut = totalValueUsd * 1e12;

        if (mintFee > 0) {
            feeAmount = (ssdmOut * mintFee) / BASIS_POINTS;
            ssdmOut -= feeAmount;
        }
    }

    function quoteRedeem(uint256 ssdmAmount)
        external
        view
        returns (uint256 sdmOut, uint256 usdcOut, uint256 feeAmount)
    {
        uint256 supply = totalSupply();
        if (supply == 0) return (0, 0, 0);

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 usdcReserve = USDC.balanceOf(address(this));

        sdmOut = (sdmReserve * ssdmAmount) / supply;
        usdcOut = (usdcReserve * ssdmAmount) / supply;

        if (redeemFee > 0) {
            uint256 sdmFee = (sdmOut * redeemFee) / BASIS_POINTS;
            uint256 usdcFee = (usdcOut * redeemFee) / BASIS_POINTS;

            sdmOut -= sdmFee;
            usdcOut -= usdcFee;
            feeAmount = sdmFee + usdcFee;
        }
    }

    function suggestedSDM(uint256 usdcAmount) external view returns (uint256) {
        uint256 usdcValueUsd = _getUSDCValueUSD(usdcAmount);
        uint256 sdmValueTarget = usdcValueUsd / 4; // 20/80 split
        return (sdmValueTarget * 1e18) / _getSDMPriceUSD();
    }

    function suggestedUSDC(uint256 sdmAmount) external view returns (uint256) {
        uint256 sdmValueUsd = _getSDMValueUSD(sdmAmount);
        uint256 usdcValueTarget = sdmValueUsd * 4; // 20/80 split
        return (usdcValueTarget * 1e6) / _getUSDCPriceUSD();
    }

    function getReserves() external view returns (uint256 sdmReserve, uint256 usdcReserve) {
        sdmReserve = SDM.balanceOf(address(this));
        usdcReserve = USDC.balanceOf(address(this));
    }

    function getStabilityRatio() external view returns (uint256) {
        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 usdcReserve = USDC.balanceOf(address(this));
        uint256 sdmValueUsd = _getSDMValueUSD(sdmReserve);
        uint256 usdcValueUsd = _getUSDCValueUSD(usdcReserve);
        uint256 totalValueUsd = sdmValueUsd + usdcValueUsd;

        if (totalValueUsd == 0) return 8000;
        return (usdcValueUsd * BASIS_POINTS) / totalValueUsd;
    }

    function getCurrentRatio() external view returns (uint256 sdmRatioBps, uint256 usdcRatioBps) {
        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 usdcReserve = USDC.balanceOf(address(this));
        uint256 sdmValueUsd = _getSDMValueUSD(sdmReserve);
        uint256 usdcValueUsd = _getUSDCValueUSD(usdcReserve);
        uint256 totalValueUsd = sdmValueUsd + usdcValueUsd;

        if (totalValueUsd == 0) return (2000, 8000);

        sdmRatioBps = (sdmValueUsd * BASIS_POINTS) / totalValueUsd;
        usdcRatioBps = BASIS_POINTS - sdmRatioBps;
    }

    function updateSDMPrice(uint256 newPrice) external onlyOwner {
        if (newPrice == 0) revert InvalidPrice();
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
        if (_tolerance > 3000) revert InvalidRatio(); // max 30%
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
        if (token != address(SDM) && token != address(USDC)) revert Unauthorized();
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(treasury, amount);
    }

    function _getSDMValueUSD(uint256 sdmAmount) private view returns (uint256) {
        return (sdmAmount * _getSDMPriceUSD()) / 1e18;
    }

    function _getUSDCValueUSD(uint256 usdcAmount) private view returns (uint256) {
        return (usdcAmount * _getUSDCPriceUSD()) / 1e6;
    }

    function _getSDMPriceUSD() private view returns (uint256) {
        if (sdmPrice == 0) revert InvalidPrice();
        if (block.timestamp - sdmPriceUpdatedAt > STALENESS_THRESHOLD) revert StalePrice();
        return sdmPrice;
    }

    function _getUSDCPriceUSD() private view returns (uint256) {
        (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
            usdcUsdOracle.latestRoundData();

        if (answer <= 0 || updatedAt == 0 || answeredInRound < roundId) revert InvalidPrice();
        if (block.timestamp - updatedAt > STALENESS_THRESHOLD) revert StalePrice();

        uint256 price = uint256(answer);
        if (i_oracleDecimals > 6) return price / 10 ** (i_oracleDecimals - 6);
        return price * 10 ** (6 - i_oracleDecimals);
    }

    function _validateRatio(uint256 sdmValueUsd, uint256 usdcValueUsd) private view {
        uint256 totalValue = sdmValueUsd + usdcValueUsd;
        uint256 sdmRatioBps = (sdmValueUsd * BASIS_POINTS) / totalValue;
        uint256 deviation = sdmRatioBps > 2000 ? sdmRatioBps - 2000 : 2000 - sdmRatioBps;
        if (deviation > ratioTolerance) revert InvalidRatio();
    }
}
