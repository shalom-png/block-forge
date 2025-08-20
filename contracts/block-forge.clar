;; Title: BlockForge - NFT Staking & Fractionalized Marketplace Protocol
;;
;; Summary:
;; BlockForge is a next-generation NFT infrastructure on Stacks that fuses
;; digital asset creation, decentralized trading, fractional ownership,
;; and staking-powered yield into a unified protocol. It leverages Bitcoin's
;; settlement security and Stacks' smart contracts to deliver a trustless
;; NFT marketplace with embedded financial utilities.
;;
;; Overview:
;; BlockForge introduces a comprehensive framework for digital collectibles
;; and tokenized assets. The protocol allows users to:
;;  - Mint NFTs backed by collateralized value
;;  - Trade NFTs peer-to-peer via a decentralized marketplace
;;  - Fractionalize NFTs into divisible ownership shares
;;  - Stake NFTs to generate yield with transparent rewards
;; By combining these primitives, BlockForge establishes a robust and scalable
;; ecosystem for Bitcoin-secured digital asset innovation.

;; Constants

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-token (err u103))
(define-constant err-listing-not-found (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-insufficient-collateral (err u106))
(define-constant err-already-staked (err u107))
(define-constant err-not-staked (err u108))
(define-constant err-invalid-percentage (err u109))
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-recipient (err u111))
(define-constant err-overflow (err u112))

;; Data Variables

(define-data-var min-collateral-ratio uint u150) ;; 150% minimum collateral ratio
(define-data-var protocol-fee uint u25) ;; 2.5% protocol fee (basis points)
(define-data-var total-staked uint u0)
(define-data-var yield-rate uint u50) ;; 5% annual yield (basis points)
(define-data-var total-supply uint u0)

;; Data Maps

(define-map tokens
  { token-id: uint }
  {
    owner: principal,
    uri: (string-ascii 256),
    collateral: uint,
    is-staked: bool,
    stake-timestamp: uint,
    fractional-shares: uint,
  }
)

(define-map token-listings
  { token-id: uint }
  {
    price: uint,
    seller: principal,
    active: bool,
  }
)

(define-map fractional-ownership
  {
    token-id: uint,
    owner: principal,
  }
  { shares: uint }
)

(define-map staking-rewards
  { token-id: uint }
  {
    accumulated-yield: uint,
    last-claim: uint,
  }
)

;; Private Validation & Utility Functions

(define-private (validate-uri (uri (string-ascii 256)))
  (let ((uri-len (len uri)))
    (and (> uri-len u0) (<= uri-len u256))
  )
)

(define-private (validate-recipient (recipient principal))
  (not (is-eq recipient (as-contract tx-sender)))
)