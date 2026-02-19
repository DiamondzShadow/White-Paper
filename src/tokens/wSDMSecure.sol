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
 * @title wSDMSecure
 * @notice Bitcoin-backed basket token: 50% SDM + 50% WBTC.
 */
contract wSDMSecure is ERC20, Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable SDM;
    IERC20 public immutable WBTC;
    IAggregatorV3 public immutable btcUsdOracle;
    uint8 private immutable i_oracleDecimals;

    uint256 public sdmPrice;
    uint256 public sdmPriceUpdatedAt;
    address public treasury;
    uint256 public mintFee;
    uint256 public redeemFee;
    bool public enforceRatio;
    uint256 public ratioTolerance;

    uint256 public constant SUGGESTED_SDM_WEIGHT = 50;
    uint256 public constant SUGGESTED_WBTC_WEIGHT = 50;

    uint256 private constant BASIS_POINTS = 10_000;
    uint256 private constant STALENESS_THRESHOLD = 24 hours;
    uint256 private constant MAX_FEE = 200; // 2%

    event Minted(
        address indexed user, uint256 sdmIn, uint256 wbtcIn, uint256 wsdmOut, uint256 feeCharged
    );
    event Redeemed(
        address indexed user, uint256 wsdmIn, uint256 sdmOut, uint256 wbtcOut, uint256 feeCharged
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
        address _wbtc,
        address _btcUsdOracle,
        uint256 _initialSdmPrice,
        address _treasury
    ) ERC20("Wrapped SDM - Bitcoin Backed", "wSDM") {
        if (_sdm == address(0) || _wbtc == address(0) || _btcUsdOracle == address(0)) {
            revert ZeroAddress();
        }
        if (_treasury == address(0)) revert ZeroAddress();
        if (_initialSdmPrice == 0) revert InvalidPrice();

        SDM = IERC20(_sdm);
        WBTC = IERC20(_wbtc);
        btcUsdOracle = IAggregatorV3(_btcUsdOracle);
        i_oracleDecimals = btcUsdOracle.decimals();

        sdmPrice = _initialSdmPrice;
        sdmPriceUpdatedAt = block.timestamp;
        treasury = _treasury;
        ratioTolerance = 500; // 5%
    }

    function mint(uint256 sdmAmount, uint256 wbtcAmount, uint256 minWsdmOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 wsdmAmount)
    {
        if (sdmAmount == 0 && wbtcAmount == 0) revert InvalidAmount();

        uint256 sdmValueUsd = _getSDMValueUSD(sdmAmount);
        uint256 wbtcValueUsd = _getWBTCValueUSD(wbtcAmount);

        if (enforceRatio && sdmAmount > 0 && wbtcAmount > 0) {
            _validateRatio(sdmValueUsd, wbtcValueUsd);
        }

        uint256 totalValueUsd = sdmValueUsd + wbtcValueUsd;
        wsdmAmount = totalValueUsd * 1e12;

        uint256 feeCharged;
        if (mintFee > 0) {
            feeCharged = (wsdmAmount * mintFee) / BASIS_POINTS;
            wsdmAmount -= feeCharged;
        }

        if (wsdmAmount < minWsdmOut) revert SlippageExceeded();

        if (sdmAmount > 0) SDM.safeTransferFrom(msg.sender, address(this), sdmAmount);
        if (wbtcAmount > 0) WBTC.safeTransferFrom(msg.sender, address(this), wbtcAmount);

        _mint(msg.sender, wsdmAmount);
        emit Minted(msg.sender, sdmAmount, wbtcAmount, wsdmAmount, feeCharged);
    }

    function redeem(uint256 wsdmAmount, uint256 minSdmOut, uint256 minWbtcOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 sdmAmount, uint256 wbtcAmount)
    {
        if (wsdmAmount == 0) revert InvalidAmount();

        uint256 supply = totalSupply();
        if (supply == 0) revert InvalidAmount();

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 wbtcReserve = WBTC.balanceOf(address(this));

        sdmAmount = (sdmReserve * wsdmAmount) / supply;
        wbtcAmount = (wbtcReserve * wsdmAmount) / supply;

        uint256 feeCharged;
        if (redeemFee > 0) {
            uint256 sdmFee = (sdmAmount * redeemFee) / BASIS_POINTS;
            uint256 wbtcFee = (wbtcAmount * redeemFee) / BASIS_POINTS;

            sdmAmount -= sdmFee;
            wbtcAmount -= wbtcFee;
            feeCharged = sdmFee + wbtcFee;

            if (sdmFee > 0) SDM.safeTransfer(treasury, sdmFee);
            if (wbtcFee > 0) WBTC.safeTransfer(treasury, wbtcFee);
        }

        if (sdmAmount < minSdmOut || wbtcAmount < minWbtcOut) revert SlippageExceeded();

        _burn(msg.sender, wsdmAmount);

        if (sdmAmount > 0) SDM.safeTransfer(msg.sender, sdmAmount);
        if (wbtcAmount > 0) WBTC.safeTransfer(msg.sender, wbtcAmount);

        emit Redeemed(msg.sender, wsdmAmount, sdmAmount, wbtcAmount, feeCharged);
    }

    function getPrice() public view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return 1e6;

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 wbtcReserve = WBTC.balanceOf(address(this));
        uint256 totalValueUsd = _getSDMValueUSD(sdmReserve) + _getWBTCValueUSD(wbtcReserve);

        return (totalValueUsd * 1e18) / supply;
    }

    function getRedeemPrice() external view returns (uint256) {
        uint256 price = getPrice();
        if (redeemFee > 0) price -= (price * redeemFee) / BASIS_POINTS;
        return price;
    }

    function quoteMint(uint256 sdmAmount, uint256 wbtcAmount)
        external
        view
        returns (uint256 wsdmOut, uint256 feeAmount)
    {
        uint256 totalValueUsd = _getSDMValueUSD(sdmAmount) + _getWBTCValueUSD(wbtcAmount);
        wsdmOut = totalValueUsd * 1e12;

        if (mintFee > 0) {
            feeAmount = (wsdmOut * mintFee) / BASIS_POINTS;
            wsdmOut -= feeAmount;
        }
    }

    function quoteRedeem(uint256 wsdmAmount)
        external
        view
        returns (uint256 sdmOut, uint256 wbtcOut, uint256 feeAmount)
    {
        uint256 supply = totalSupply();
        if (supply == 0) return (0, 0, 0);

        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 wbtcReserve = WBTC.balanceOf(address(this));

        sdmOut = (sdmReserve * wsdmAmount) / supply;
        wbtcOut = (wbtcReserve * wsdmAmount) / supply;

        if (redeemFee > 0) {
            uint256 sdmFee = (sdmOut * redeemFee) / BASIS_POINTS;
            uint256 wbtcFee = (wbtcOut * redeemFee) / BASIS_POINTS;

            sdmOut -= sdmFee;
            wbtcOut -= wbtcFee;
            feeAmount = sdmFee + wbtcFee;
        }
    }

    function suggestedSDM(uint256 wbtcAmount) external view returns (uint256) {
        uint256 wbtcValueUsd = _getWBTCValueUSD(wbtcAmount);
        return (wbtcValueUsd * 1e18) / _getSDMPriceUSD();
    }

    function suggestedWBTC(uint256 sdmAmount) external view returns (uint256) {
        uint256 sdmValueUsd = _getSDMValueUSD(sdmAmount);
        return (sdmValueUsd * 1e8) / _getBTCPriceUSD();
    }

    function getReserves() external view returns (uint256 sdmReserve, uint256 wbtcReserve) {
        sdmReserve = SDM.balanceOf(address(this));
        wbtcReserve = WBTC.balanceOf(address(this));
    }

    function getCurrentRatio() external view returns (uint256 sdmRatioBps, uint256 wbtcRatioBps) {
        uint256 sdmReserve = SDM.balanceOf(address(this));
        uint256 wbtcReserve = WBTC.balanceOf(address(this));
        uint256 sdmValueUsd = _getSDMValueUSD(sdmReserve);
        uint256 wbtcValueUsd = _getWBTCValueUSD(wbtcReserve);
        uint256 totalValueUsd = sdmValueUsd + wbtcValueUsd;

        if (totalValueUsd == 0) return (5000, 5000);

        sdmRatioBps = (sdmValueUsd * BASIS_POINTS) / totalValueUsd;
        wbtcRatioBps = BASIS_POINTS - sdmRatioBps;
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
        if (token != address(SDM) && token != address(WBTC)) revert Unauthorized();
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(treasury, amount);
    }

    function _getSDMValueUSD(uint256 sdmAmount) private view returns (uint256) {
        return (sdmAmount * _getSDMPriceUSD()) / 1e18;
    }

    function _getWBTCValueUSD(uint256 wbtcAmount) private view returns (uint256) {
        return (wbtcAmount * _getBTCPriceUSD()) / 1e8;
    }

    function _getSDMPriceUSD() private view returns (uint256) {
        if (sdmPrice == 0) revert InvalidPrice();
        if (block.timestamp - sdmPriceUpdatedAt > STALENESS_THRESHOLD) revert StalePrice();
        return sdmPrice;
    }

    function _getBTCPriceUSD() private view returns (uint256) {
        (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
            btcUsdOracle.latestRoundData();

        if (answer <= 0 || updatedAt == 0 || answeredInRound < roundId) revert InvalidPrice();
        if (block.timestamp - updatedAt > STALENESS_THRESHOLD) revert StalePrice();

        uint256 price = uint256(answer);
        if (i_oracleDecimals > 6) return price / 10 ** (i_oracleDecimals - 6);
        return price * 10 ** (6 - i_oracleDecimals);
    }

    function _validateRatio(uint256 sdmValueUsd, uint256 wbtcValueUsd) private view {
        uint256 totalValue = sdmValueUsd + wbtcValueUsd;
        uint256 sdmRatioBps = (sdmValueUsd * BASIS_POINTS) / totalValue;
        uint256 deviation = sdmRatioBps > 5000 ? sdmRatioBps - 5000 : 5000 - sdmRatioBps;
        if (deviation > ratioTolerance) revert InvalidRatio();
    }
}
