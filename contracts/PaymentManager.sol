// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/// @title Payment manager for THWS utility token flows
/// @notice Handles service, laundry, and vending payments plus machine locking
contract PaymentManager is AccessControl, Pausable, ReentrancyGuard, EIP712 {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");
    // Pause yetkisi DEFAULT_ADMIN_ROLE'da kalsın; ayrıca PAUSER_ROLE tanımlamıyoruz.
    bytes32 private constant PAYMENT_TYPEHASH =
        keccak256("Payment(bytes32 service,uint256 amount,address payer,uint256 nonce,uint256 expiry)");

    IERC20 public immutable token;
    uint64 public laundryLockDuration = 1 hours;

    // Custom errors (gas optimized vs revert strings)
    error ZeroAddress();
    error InvalidPrice();
    error InvalidAmount();
    error InvalidDuration();
    error WalletNotConfigured(bytes32 key);
    error PriceNotConfigured(bytes32 key);
    error AmountMismatch(uint256 expected, uint256 provided);
    error MachineLocked(uint256 lockedUntil);

    // Generic service wallet mapping (e.g., "MENSA")
    mapping(bytes32 => address) public serviceWallets;
    mapping(bytes32 => uint256) public servicePrices; // amount in token units

    // Laundry and vending wallets can be configured separately
    address public laundryWallet; // default laundry wallet
    address public vendingWallet; // default vending wallet
    mapping(bytes32 => address) public laundryWallets; // dormCode -> wallet
    mapping(bytes32 => address) public vendingWallets; // campus/hall -> wallet
    uint256 public defaultLaundryPrice;
    uint256 public defaultVendingPrice;
    mapping(bytes32 => uint256) public laundryPrices; // machineKey -> price
    mapping(bytes32 => uint256) public vendingPrices; // vendingKey -> price
    mapping(bytes32 => address) public serviceSigners; // authorized signer per service for dynamic payments
    mapping(address => uint256) public nonces; // payer => nonce for signed payments

    struct MachineState {
        uint64 lockedUntil;
    }

    mapping(bytes32 => MachineState) private machineState;

    event ServicePayment(
        bytes32 indexed service,
        address indexed payer,
        address indexed recipient,
        uint256 amount
    );

    event LaundryPayment(
        bytes32 indexed dormCode,
        uint256 indexed machineId,
        address indexed payer,
        address recipient,
        uint256 amount,
        uint256 lockedUntil
    );

    event VendingPayment(
        bytes32 indexed campus,
        bytes32 indexed hall,
        uint256 indexed machineId,
        address payer,
        address recipient,
        uint256 amount
    );

    event ServiceWalletUpdated(bytes32 indexed service, address wallet);
    event ServicePriceUpdated(bytes32 indexed service, uint256 price);
    event LaundryWalletUpdated(address wallet);
    event VendingWalletUpdated(address wallet);
    event LaundryLockDurationUpdated(uint256 duration);
    event DefaultLaundryPriceUpdated(uint256 price);
    event DefaultVendingPriceUpdated(uint256 price);
    event LaundryWalletUpdatedForDorm(bytes32 indexed dormCode, address wallet);
    event VendingWalletUpdatedForHall(bytes32 indexed campus, bytes32 indexed hall, address wallet);
    event MachineForceUnlocked(bytes32 indexed dormCode, uint256 indexed machineId, uint256 previousLockedUntil, address indexed by);
    event TokensRecovered(address indexed token, address indexed to, uint256 amount);
    event ServiceSignerUpdated(bytes32 indexed service, address signer);

    constructor(address tokenAddress, address initialAdmin) EIP712("PaymentManager", "1") {
        if (tokenAddress == address(0)) revert ZeroAddress();
        token = IERC20(tokenAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(CONFIG_ROLE, initialAdmin);
    }

    // -----------------------
    // Admin configuration
    // -----------------------

    function setServiceWallet(bytes32 service, address wallet) external onlyRole(CONFIG_ROLE) {
        if (wallet == address(0)) revert ZeroAddress();
        serviceWallets[service] = wallet;
        emit ServiceWalletUpdated(service, wallet);
    }

    function setServicePrice(bytes32 service, uint256 price) external onlyRole(CONFIG_ROLE) {
        if (price == 0) revert InvalidPrice();
        servicePrices[service] = price;
        emit ServicePriceUpdated(service, price);
    }

    function setLaundryWallet(address wallet) external onlyRole(CONFIG_ROLE) {
        if (wallet == address(0)) revert ZeroAddress();
        laundryWallet = wallet;
        emit LaundryWalletUpdated(wallet);
    }

    function setLaundryWalletForDorm(bytes32 dormCode, address wallet) external onlyRole(CONFIG_ROLE) {
        if (wallet == address(0)) revert ZeroAddress();
        laundryWallets[dormCode] = wallet;
        emit LaundryWalletUpdatedForDorm(dormCode, wallet);
    }

    function setVendingWallet(address wallet) external onlyRole(CONFIG_ROLE) {
        if (wallet == address(0)) revert ZeroAddress();
        vendingWallet = wallet;
        emit VendingWalletUpdated(wallet);
    }

    function setVendingWalletForHall(bytes32 campus, bytes32 hall, address wallet) external onlyRole(CONFIG_ROLE) {
        if (wallet == address(0)) revert ZeroAddress();
        bytes32 key = _vendingAreaKey(campus, hall);
        vendingWallets[key] = wallet;
        emit VendingWalletUpdatedForHall(campus, hall, wallet);
    }

    function setServiceSigner(bytes32 service, address signer) external onlyRole(CONFIG_ROLE) {
        if (signer == address(0)) revert ZeroAddress();
        serviceSigners[service] = signer;
        emit ServiceSignerUpdated(service, signer);
    }

    function setLaundryLockDuration(uint256 duration) external onlyRole(CONFIG_ROLE) {
        if (duration == 0 || duration > type(uint64).max) revert InvalidDuration();
        laundryLockDuration = uint64(duration);
        emit LaundryLockDurationUpdated(duration);
    }

    function setLaundryPrice(bytes32 dormCode, uint256 machineId, uint256 price) external onlyRole(CONFIG_ROLE) {
        if (price == 0) revert InvalidPrice();
        bytes32 key = _machineKey(dormCode, machineId);
        laundryPrices[key] = price;
    }

    function setVendingPrice(bytes32 campus, bytes32 hall, uint256 machineId, uint256 price) external onlyRole(CONFIG_ROLE) {
        if (price == 0) revert InvalidPrice();
        bytes32 key = _vendingKey(campus, hall, machineId);
        vendingPrices[key] = price;
    }

    function setDefaultLaundryPrice(uint256 price) external onlyRole(CONFIG_ROLE) {
        if (price == 0) revert InvalidPrice();
        defaultLaundryPrice = price;
        emit DefaultLaundryPriceUpdated(price);
    }

    function setDefaultVendingPrice(uint256 price) external onlyRole(CONFIG_ROLE) {
        if (price == 0) revert InvalidPrice();
        defaultVendingPrice = price;
        emit DefaultVendingPriceUpdated(price);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // -----------------------
    // Payment flows
    // -----------------------

    function payService(bytes32 service, uint256 amount) external nonReentrant whenNotPaused {
        address recipient = serviceWallets[service];
        if (recipient == address(0)) revert WalletNotConfigured(service);
        uint256 price = servicePrices[service];
        if (price == 0) revert PriceNotConfigured(service);
        if (amount != price) revert AmountMismatch(price, amount);

        _transferFromPayer(msg.sender, recipient, price);

        emit ServicePayment(service, msg.sender, recipient, amount);
    }

    /// @notice Mensa dynamic payment with off-chain signature (prevents tampering with amount)
    function payServiceWithSig(
        bytes32 service,
        uint256 amount,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant whenNotPaused {
        if (block.timestamp > expiry) revert InvalidDuration();
        address signer = serviceSigners[service];
        if (signer == address(0)) revert WalletNotConfigured(service);

        address recipient = serviceWallets[service];
        if (recipient == address(0)) revert WalletNotConfigured(service);
        if (amount == 0) revert InvalidAmount();

        uint256 nonce = nonces[msg.sender];
        bytes32 structHash = keccak256(
            abi.encode(PAYMENT_TYPEHASH, service, amount, msg.sender, nonce, expiry)
        );
        bytes32 digest = _hashTypedDataV4(structHash);

        address recovered = ECDSA.recover(digest, v, r, s);
        if (recovered != signer) revert WalletNotConfigured(service);

        unchecked {
            nonces[msg.sender] = nonce + 1;
        }

        _transferFromPayer(msg.sender, recipient, amount);
        emit ServicePayment(service, msg.sender, recipient, amount);
    }

    function payLaundry(bytes32 dormCode, uint256 machineId) external nonReentrant whenNotPaused {
        address wallet = laundryWallets[dormCode];
        if (wallet == address(0)) {
            wallet = laundryWallet;
        }
        if (wallet == address(0)) revert WalletNotConfigured(dormCode);

        bytes32 key = _machineKey(dormCode, machineId);
        MachineState storage state = machineState[key];
        if (block.timestamp < state.lockedUntil) revert MachineLocked(state.lockedUntil);
        uint256 price = laundryPrices[key];
        if (price == 0) {
            price = defaultLaundryPrice;
        }
        if (price == 0) revert PriceNotConfigured(key);

        _transferFromPayer(msg.sender, wallet, price);

        state.lockedUntil = uint64(block.timestamp + laundryLockDuration);

        emit LaundryPayment(
            dormCode,
            machineId,
            msg.sender,
            wallet,
            price,
            state.lockedUntil
        );
    }

    function payVendingMachine(
        bytes32 campus,
        bytes32 hall,
        uint256 machineId
    ) external nonReentrant whenNotPaused {
        bytes32 areaKey = _vendingAreaKey(campus, hall);
        address wallet = vendingWallets[areaKey];
        if (wallet == address(0)) {
            wallet = vendingWallet;
        }
        if (wallet == address(0)) revert WalletNotConfigured(areaKey);

        bytes32 priceKey = _vendingKey(campus, hall, machineId);
        uint256 price = vendingPrices[priceKey];
        if (price == 0) {
            price = defaultVendingPrice;
        }
        if (price == 0) revert PriceNotConfigured(priceKey);

        _transferFromPayer(msg.sender, wallet, price);

        emit VendingPayment(
            campus,
            hall,
            machineId,
            msg.sender,
            wallet,
            price
        );
    }

    /// @notice Emergency unlock for a machine (e.g., stuck state in UI)
    function forceUnlock(bytes32 dormCode, uint256 machineId) external onlyRole(CONFIG_ROLE) {
        bytes32 key = _machineKey(dormCode, machineId);
        uint256 previous = machineState[key].lockedUntil;
        machineState[key].lockedUntil = 0;
        emit MachineForceUnlocked(dormCode, machineId, previous, msg.sender);
    }

    /// @notice Recover any ERC20 accidentally sent to this contract
    function recoverERC20(address erc20, address to, uint256 amount) external onlyRole(CONFIG_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        IERC20(erc20).safeTransfer(to, amount);
        emit TokensRecovered(erc20, to, amount);
    }

    // -----------------------
    // Views
    // -----------------------

    function getMachineLockedUntil(bytes32 dormCode, uint256 machineId) external view returns (uint256) {
        return machineState[_machineKey(dormCode, machineId)].lockedUntil;
    }

    // -----------------------
    // Internal helpers
    // -----------------------

    function _transferFromPayer(address payer, address recipient, uint256 amount) internal {
        if (amount == 0) revert InvalidAmount();
        token.safeTransferFrom(payer, recipient, amount);
    }

    function _machineKey(bytes32 dormCode, uint256 machineId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(dormCode, machineId));
    }

    function _vendingAreaKey(bytes32 campus, bytes32 hall) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(campus, hall));
    }

    function _vendingKey(bytes32 campus, bytes32 hall, uint256 machineId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(campus, hall, machineId));
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
