# THWS Utility Token System – Übersicht (DE)

Dieses Repo enthält zwei Smart Contracts (THWSToken, PaymentManager) plus Tests/Beispiele, um Mensa-, Laundry- und Vending-Zahlungen on-chain abzuwickeln. Ziel: transparente Zahlungen mit Rollen/Signaturen, per-Service-Wallets und Preisen, optional Pausenfunktion.

## Komponenten
- **THWSToken**: ERC20 mit 2 Dezimalstellen, `mint/burn` nur durch Admin.
- **PaymentManager** (AccessControl): Rollen `DEFAULT_ADMIN_ROLE` (alles, inkl. pause/unpause) und `CONFIG_ROLE` (Preise/Wallets/Signer setzen).
  - Per-Service-Wallets (`serviceWallets`), servicebasierte Signer (`serviceSigners`).
  - Laundry/Vending: Default- und Bereichs-Wallets (`laundryWallet` + `laundryWallets[dorm]`, `vendingWallet` + `vendingWallets[campus/hall]`), Defaultpreise + Overrides.
  - Events: `ServicePayment`, `LaundryPayment`, `MensaMachinePayment` (für Listener/DB).
  - Imzalı (EIP-712) Mensa-Zahlung via `payServiceWithSig`.

## Deployment & Rollen
Constructor: `PaymentManager(tokenAddress, initialAdmin)`  
`initialAdmin` erhält `DEFAULT_ADMIN_ROLE` + `CONFIG_ROLE`. Weitere Admins: `grantRole(CONFIG_ROLE, addr)`.

## Konfiguration (CONFIG_ROLE)
- Service/Mensa: `setServiceWallet(bytes32 service, address wallet)`, `setServicePrice` (falls fest), `setServiceSigner` (für EIP-712).
- Laundry: `setLaundryWallet(default)`, optional `setLaundryWalletForDorm(dorm, wallet)`, Preise: `setDefaultLaundryPrice`, `setLaundryPrice(dorm, machineId, price)`.
- Vending: `setVendingWallet(default)`, optional `setVendingWalletForHall(campus, hall, wallet)`, Preise: `setDefaultVendingPrice`, `setVendingPrice(campus, hall, machineId, price)`.
- Sonstiges: `setLaundryLockDuration(seconds)`, `pause/unpause` nur `DEFAULT_ADMIN_ROLE`.

## Zahlungspfad (Schnittstellen)
- **Sabit Service**: `payService(service, amount)` (Amount muss on-chain-Preis entsprechen).  
- **Mensa dynamisch (EIP-712)**: `payServiceWithSig(service, amount, expiry, v, r, s)`; nonce/expiry geprüft, signer aus `serviceSigners[service]`.
- **Laundry**: `payLaundry(dormCode, machineId)`; nutzt Override-Preis oder Default, blockiert Maschine für `laundryLockDuration`.
- **Vending**: `payMensaMachine(campus, hall, machineId)`; nutzt Override- oder Defaultpreis.

## EIP-712 Imza (Beispiel Backend, ethers v6)
```js
const domain = { name: "PaymentManager", version: "1", chainId, verifyingContract: manager };
const types = { Payment: [
  { name: "service", type: "bytes32" },
  { name: "amount", type: "uint256" },
  { name: "payer", type: "address" },
  { name: "nonce", type: "uint256" },
  { name: "expiry", type: "uint256" },
]};
const payment = { service, amount, payer, nonce, expiry };
const signature = await signer.signTypedData(domain, types, payment);
const { v, r, s } = ethers.Signature.from(signature);
// Frontend ruft dann payServiceWithSig(service, amount, expiry, v, r, s)
```

## Event Listener (Idee)
`ServicePayment`, `LaundryPayment`, `MensaMachinePayment` filtern, nach DB schreiben (payer, recipient, amount, txHash, blockTime) für Profil/Verlauf. Der Listener ist off-chain; Contract loggt nur Events.

## Tests & Nutzung
```bash
npm install
npx hardhat test      # alle Tests (17 green)
npx hardhat compile
```
Empfohlene Node-Version: 18/20 (Hardhat warnt bei 25).

## TL;DR
Rollenbasiertes Payment-Gateway: Service-/Bereichs-Wallets, Default/Override-Preise, EIP-712 signierte Mensa-Zahlungen, Events für Auswertungen. Konfigurierbar über CONFIG_ROLE, Pause über DEFAULT_ADMIN_ROLE.
