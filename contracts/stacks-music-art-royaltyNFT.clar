;; Enhanced Stacks Music and Art Royalty NFT Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-funds (err u101))
(define-constant err-invalid-royalty (err u102))
(define-constant err-not-approved (err u103))
(define-constant err-token-not-found (err u104))

;; NFT trait implementation
(define-non-fungible-token royalty-nft uint)

(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-INVALID-PRICE (err u104))

;; Storage for tracking royalty percentages and metadata
(define-map royalty-percentage 
  { token-id: uint }
  { 
    percentage: uint, 
    creator: principal, 
    metadata: (string-utf8 256)
  }
)

;; Approval mapping for transfers
(define-map token-approvals 
  { token-id: uint }
  { approved-operator: (optional principal) }
)

;; Store total number of minted tokens
(define-data-var token-count uint u0)

;; Mint a new NFT with enhanced metadata and royalty
(define-public (mint-nft 
  (metadata (string-utf8 256)) 
  (royalty-percent uint)
)
  (begin
    ;; Validate royalty percentage (max 50%)
    (asserts! (< royalty-percent u50) err-invalid-royalty)

    ;; Increment token count
    (var-set token-count (+ (var-get token-count) u1))
    (let 
      ((new-token-id (var-get token-count)))
      ;; Mint the NFT to the sender
      (try! (nft-mint? royalty-nft new-token-id tx-sender))

      ;; Store royalty and metadata information
      (map-set royalty-percentage 
        { token-id: new-token-id }
        { 
          percentage: royalty-percent, 
          creator: tx-sender,
          metadata: metadata
        }
      )

      (ok new-token-id)
    )
  )
)

;; Approve an operator for a specific token
(define-public (approve 
  (token-id uint)
  (approved-operator (optional principal))
)
  (begin
    ;; Ensure only token owner can approve
    (asserts! 
      (is-eq tx-sender (unwrap-panic (nft-get-owner? royalty-nft token-id))) 
      err-owner-only
    )

    ;; Set approval
    (map-set token-approvals 
      { token-id: token-id }
      { approved-operator: approved-operator }
    )

    (ok true)
  )
)

;; Check if transfer is approved
(define-private (is-transfer-approved (token-id uint) (sender principal))
  (match (map-get? token-approvals { token-id: token-id })
    approval 
      (or
        (is-eq (get approved-operator approval) (some sender))
        (is-eq sender tx-sender)
      )
    true  ;; Default to true if no specific approval set
  )
)

;; Dynamic sale price calculation (placeholder)
(define-private (get-sale-price (token-id uint))
  ;; In a real implementation, this would fetch from an external oracle or marketplace
  ;; For now, we'll use a base price with some variation
  (let 
    ((base-price u1000))
    (+ base-price (* token-id u10))
  )
)

;; Batch minting for multiple NFTs
(define-public (batch-mint 
  (metadata-list (list 10 (string-utf8 256)))
  (royalty-percentages (list 10 uint))
)
  (let 
    ((minted-tokens 
      (map mint-single-nft 
        metadata-list 
        royalty-percentages
      )
    ))
    (ok minted-tokens)
  )
)

;; Helper function for batch minting
(define-private (mint-single-nft 
  (metadata (string-utf8 256))
  (royalty-percent uint)
)
  (let 
    ((result (mint-nft metadata royalty-percent)))
    (unwrap-panic result)
  )
)

;; View functions for royalty and token information
(define-read-only (get-royalty-info (token-id uint))
  (map-get? royalty-percentage { token-id: token-id })
)

(define-read-only (get-total-nfts)
  (var-get token-count)
)

(define-read-only (get-token-owner (token-id uint))
  (nft-get-owner? royalty-nft token-id)
)

;; Retrieve Listing Details
(define-read-only (get-listing-details (token-id uint))
  (map-get? market-listings { token-id: token-id })
)


;; Transfer function with royalty distribution
(define-public (transfer 
  (token-id uint)
  (sender principal)
  (recipient principal)
)
  (let 
    (
      ;; Get royalty information
      (royalty-info 
        (unwrap! 
          (map-get? royalty-percentage { token-id: token-id }) 
          (err u404)
        )
      )

      ;; Calculate royalty amount (assuming sale price is passed externally)
      (sale-price (get-last-sale-price token-id))
      (royalty-amount 
        (/ (* sale-price (get percentage royalty-info)) u100)
      )
      (creator (get creator royalty-info))
    )

    ;; Ensure only current owner can transfer
    (asserts! (is-eq sender (unwrap-panic (nft-get-owner? royalty-nft token-id))) err-owner-only)

    ;; Transfer royalty to creator
    (and (> royalty-amount u0)
      (try! (stx-transfer? royalty-amount sender creator))
    )

    ;; Standard NFT transfer
    (try! (nft-transfer? royalty-nft token-id sender recipient))

    (ok true)
  )
)
;; Get the last sale price (placeholder - would be implemented with external oracle)
(define-private (get-last-sale-price (token-id uint))
  ;; In a real implementation, this would fetch from an oracle or marketplace
  (default-to u1000 (some u1000))
)


;; Marketplace Listings Storage
(define-map market-listings 
  { token-id: uint }
  { 
    seller: principal, 
    price: uint, 
    is-active: bool 
  }
)



;; ;; ;; Delist NFT
(define-public (delist-nft (token-id uint))
  (let 
    ((listing (unwrap! 
      (map-get? market-listings { token-id: token-id }) 
      ERR-NOT-LISTED))
    )
    (asserts! 
      (is-eq tx-sender (get seller listing)) 
      ERR-OWNER-ONLY
    )

    (map-set market-listings 
      { token-id: token-id }
      { 
        seller: tx-sender, 
        price: u0, 
        is-active: false 
      }
    )

    (ok true)
  )
)


;; List NFT for Sale
(define-public (list-nft 
  (token-id uint)
  (price uint)
)
  (begin
    (asserts! 
      (is-eq tx-sender (unwrap-panic (nft-get-owner? royalty-nft token-id))) 
      ERR-OWNER-ONLY
    )
    (asserts! (> price u0) ERR-INVALID-PRICE)

    (map-set market-listings 
      { token-id: token-id }
      { 
        seller: tx-sender, 
        price: price, 
        is-active: true 
      }
    )

    (ok true)
  )
)
