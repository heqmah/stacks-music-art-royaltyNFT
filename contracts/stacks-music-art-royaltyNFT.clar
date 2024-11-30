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
