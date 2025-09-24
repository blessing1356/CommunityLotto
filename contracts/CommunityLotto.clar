;; ------------------------------------------------------------
;; Contract: CommunityLotto
;; Description: Community Lottery Poolplayers buy tickets (STX).
;; Owner draws a winner by providing a numeric seed. Prize = pool.
;; License: MIT
;; ------------------------------------------------------------

;; ------------------
;; Constants & Errors
;; ------------------
(define-constant ERR-NOT-ENOUGH (err u100))
(define-constant ERR-NO-ENTRIES (err u101))
(define-constant ERR-ALREADY-DRAWN (err u102))
(define-constant ERR-ONLY-OWNER (err u103))
(define-constant ERR-TRANSFER-FAILED (err u104))
(define-constant ERR-INVALID-FEE (err u105))

;; ------------------
;; Global state & maps
;; ------------------
(define-data-var contract-owner principal tx-sender)
(define-data-var current-round uint u1)
(define-data-var entry-fee uint u1000000) ;; default 1 STX in micro-STX

;; entries keyed by (round, idx) -> principal
(define-map entries { round: uint, idx: uint } principal)

;; round -> number of entries
(define-map round-count uint uint)

;; round -> winner principal (populated after draw)
(define-map winners uint principal)

;; round -> drawn? bool
(define-map round-drawn uint bool)

;; ------------------
;; Helpers / modifiers
;; ------------------
(define-private (only-owner)
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-ONLY-OWNER)
    (ok true)))

;; ------------------
;; Public: set entry fee (owner)
;; ------------------
(define-public (set-entry-fee (fee uint))
  (begin
    (try! (only-owner))
    (asserts! (> fee u0) ERR-INVALID-FEE)
    (var-set entry-fee fee)
    (print { event: "EntryFeeSet", fee: fee })
    (ok true)))

;; ------------------
;; Public: owner withdraw accidental STX from contract (owner-only)
;; ------------------
(define-public (owner-withdraw (amount uint) (to principal))
  (begin
    (try! (only-owner))
    (asserts! (> amount u0) ERR-NOT-ENOUGH)
    (match (stx-transfer? amount (as-contract tx-sender) to)
      success (begin (print { event: "OwnerWithdraw", to: to, amount: amount }) (ok true))
      error ERR-TRANSFER-FAILED)))

;; ------------------
;; Public: enter lottery
;; Caller must send current entry-fee to contract in same transaction.
;; ------------------
(define-public (enter-lottery)
  (begin
    ;; Ensure payment to contract equals entry-fee
    (let ((fee (var-get entry-fee)))
      (try! (stx-transfer? fee tx-sender (as-contract tx-sender)))
      (let ((rid (var-get current-round))
            (count (default-to u0 (map-get? round-count (var-get current-round)))))
        ;; store entry at index = count (0-based)
        (map-set entries { round: rid, idx: count } tx-sender)
        ;; bump count
        (map-set round-count rid (+ count u1))
        (print { event: "Entered", player: tx-sender, round: rid, index: count })
        (ok { round: rid, index: count })))))

;; ------------------
;; Public: draw winner
;; Only owner. Provide a numeric seed (uint). Owner must be honest or use a commitment scheme / oracle.
;; Prize = entry-fee * count
;; After drawing the winner, the contract marks round drawn, records the winner,
;; transfers prize to winner, and increments current-round (auto starts next round).
;; ------------------


;; ------------------
;; Read-only helpers
;; ------------------

(define-read-only (get-current-round)
  (ok (var-get current-round)))

(define-read-only (get-entry-fee)
  (ok (var-get entry-fee)))

(define-read-only (get-round-count (rid uint))
  (ok (default-to u0 (map-get? round-count rid))))





(define-read-only (is-round-drawn (rid uint))
  (ok (default-to false (map-get? round-drawn rid))))
