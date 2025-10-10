(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CONTEST-NOT-FOUND (err u101))
(define-constant ERR-CONTEST-ENDED (err u102))
(define-constant ERR-ALREADY-VOTED (err u103))
(define-constant ERR-CAPTION-NOT-FOUND (err u104))
(define-constant ERR-INVALID-CONTEST (err u105))
(define-constant ERR-CONTEST-ACTIVE (err u106))

(define-data-var next-contest-id uint u1)
(define-data-var next-caption-id uint u1)

(define-map contests
  { contest-id: uint }
  {
    creator: principal,
    image-url: (string-utf8 256),
    title: (string-utf8 128),
    end-block: uint,
    winner-caption-id: (optional uint),
    prize-amount: uint,
    is-active: bool
  }
)

(define-map captions
  { caption-id: uint }
  {
    contest-id: uint,
    author: principal,
    text: (string-utf8 256),
    vote-count: uint
  }
)

(define-map votes
  { voter: principal, contest-id: uint }
  { caption-id: uint }
)

(define-map user-balances
  { user: principal }
  { balance: uint }
)

(define-public (create-contest (image-url (string-utf8 256)) (title (string-utf8 128)) (duration-blocks uint) (prize-amount uint))
  (let ((contest-id (var-get next-contest-id))
        (end-block (+ stacks-block-height duration-blocks)))
    (try! (stx-transfer? prize-amount tx-sender (as-contract tx-sender)))
    (map-set contests
      { contest-id: contest-id }
      {
        creator: tx-sender,
        image-url: image-url,
        title: title,
        end-block: end-block,
        winner-caption-id: none,
        prize-amount: prize-amount,
        is-active: true
      }
    )
    (var-set next-contest-id (+ contest-id u1))
    (ok contest-id)
  )
)

(define-public (submit-caption (contest-id uint) (caption-text (string-utf8 256)))
  (let ((contest (unwrap! (map-get? contests { contest-id: contest-id }) ERR-CONTEST-NOT-FOUND))
        (caption-id (var-get next-caption-id)))
    (asserts! (get is-active contest) ERR-CONTEST-ENDED)
    (asserts! (< stacks-block-height (get end-block contest)) ERR-CONTEST-ENDED)
    (map-set captions
      { caption-id: caption-id }
      {
        contest-id: contest-id,
        author: tx-sender,
        text: caption-text,
        vote-count: u0
      }
    )
    (var-set next-caption-id (+ caption-id u1))
    (ok caption-id)
  )
)

(define-public (vote-caption (contest-id uint) (caption-id uint))
  (let ((contest (unwrap! (map-get? contests { contest-id: contest-id }) ERR-CONTEST-NOT-FOUND))
        (caption (unwrap! (map-get? captions { caption-id: caption-id }) ERR-CAPTION-NOT-FOUND)))
    (asserts! (get is-active contest) ERR-CONTEST-ENDED)
    (asserts! (< stacks-block-height (get end-block contest)) ERR-CONTEST-ENDED)
    (asserts! (is-eq (get contest-id caption) contest-id) ERR-INVALID-CONTEST)
    (asserts! (is-none (map-get? votes { voter: tx-sender, contest-id: contest-id })) ERR-ALREADY-VOTED)
    (map-set votes
      { voter: tx-sender, contest-id: contest-id }
      { caption-id: caption-id }
    )
    (map-set captions
      { caption-id: caption-id }
      (merge caption { vote-count: (+ (get vote-count caption) u1) })
    )
    (ok true)
  )
)

(define-public (end-contest (contest-id uint))
  (let ((contest (unwrap! (map-get? contests { contest-id: contest-id }) ERR-CONTEST-NOT-FOUND))
        (winner-caption (find-winning-caption contest-id)))
    (asserts! (>= stacks-block-height (get end-block contest)) ERR-CONTEST-ACTIVE)
    (asserts! (get is-active contest) ERR-CONTEST-ENDED)
    (match winner-caption
      some-caption-id
      (let ((winning-caption (unwrap-panic (map-get? captions { caption-id: some-caption-id }))))
        (try! (as-contract (stx-transfer? (get prize-amount contest) tx-sender (get author winning-caption))))
        (map-set contests
          { contest-id: contest-id }
          (merge contest { winner-caption-id: (some some-caption-id), is-active: false })
        )
        (ok some-caption-id)
      )
      (begin
        (map-set contests
          { contest-id: contest-id }
          (merge contest { is-active: false })
        )
        (ok u0)
      )
    )
  )
)

(define-private (find-winning-caption (contest-id uint))
  (fold check-caption-votes (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15 u16 u17 u18 u19 u20) none)
)

(define-private (check-caption-votes (caption-id uint) (current-winner (optional uint)))
  (match (map-get? captions { caption-id: caption-id })
    some-caption
    (match current-winner
      some-winner
      (let ((winner-caption (unwrap-panic (map-get? captions { caption-id: some-winner }))))
        (if (> (get vote-count some-caption) (get vote-count winner-caption))
          (some caption-id)
          current-winner
        )
      )
      (some caption-id)
    )
    current-winner
  )
)

(define-read-only (get-contest (contest-id uint))
  (map-get? contests { contest-id: contest-id })
)

(define-read-only (get-caption (caption-id uint))
  (map-get? captions { caption-id: caption-id })
)

(define-read-only (get-user-vote (voter principal) (contest-id uint))
  (map-get? votes { voter: voter, contest-id: contest-id })
)

(define-read-only (get-contest-status (contest-id uint))
  (match (map-get? contests { contest-id: contest-id })
    some-contest (get is-active some-contest)
    false
  )
)

(define-read-only (get-total-contests)
  (- (var-get next-contest-id) u1)
)

(define-read-only (get-total-captions)
  (- (var-get next-caption-id) u1)
)


(define-map user-profiles
  { user: principal }
  {
    total-captions: uint,
    total-wins: uint,
    total-earnings: uint,
    first-contest-block: uint,
    last-activity-block: uint
  }
)

(define-map user-captions
  { user: principal, index: uint }
  {
    caption-id: uint,
    contest-id: uint,
    submission-block: uint,
    vote-count: uint,
    is-winner: bool
  }
)

(define-map user-caption-count
  { user: principal }
  { count: uint }
)

(define-private (update-user-profile (user principal) (caption-id uint) (contest-id uint))
  (let ((current-profile (default-to 
          { total-captions: u0, total-wins: u0, total-earnings: u0, 
            first-contest-block: stacks-block-height, last-activity-block: stacks-block-height }
          (map-get? user-profiles { user: user })))
        (caption-count (default-to { count: u0 } (map-get? user-caption-count { user: user })))
        (new-index (get count caption-count)))
    (map-set user-profiles
      { user: user }
      (merge current-profile 
        { total-captions: (+ (get total-captions current-profile) u1),
          last-activity-block: stacks-block-height }))
    (map-set user-captions
      { user: user, index: new-index }
      { caption-id: caption-id, contest-id: contest-id, 
        submission-block: stacks-block-height, vote-count: u0, is-winner: false })
    (map-set user-caption-count
      { user: user }
      { count: (+ new-index u1) })
    (ok true)))

(define-private (update-winner-profile (winner principal) (earnings uint))
  (let ((current-profile (unwrap-panic (map-get? user-profiles { user: winner }))))
    (map-set user-profiles
      { user: winner }
      (merge current-profile 
        { total-wins: (+ (get total-wins current-profile) u1),
          total-earnings: (+ (get total-earnings current-profile) earnings) }))
    (ok true)))

(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles { user: user }))

(define-read-only (get-user-caption-history (user principal) (start-index uint) (count uint))
  (list (map-get? user-captions { user: user, index: start-index })
        (map-get? user-captions { user: user, index: (+ start-index u1) })
        (map-get? user-captions { user: user, index: (+ start-index u2) })
        (map-get? user-captions { user: user, index: (+ start-index u3) })
        (map-get? user-captions { user: user, index: (+ start-index u4) })))

(define-read-only (get-user-caption-at-index (user principal) (index uint))
  (map-get? user-captions { user: user, index: index }))

(define-read-only (get-user-stats (user principal))
  (let ((profile (get-user-profile user))
        (caption-count (default-to { count: u0 } (map-get? user-caption-count { user: user }))))
    { profile: profile, total-submissions: (get count caption-count) }))


(define-map user-reputation
  { user: principal }
  { 
    total-votes-received: uint,
    contests-participated: uint,
    reputation-score: uint,
    rank-tier: (string-ascii 16),
    last-score-update: uint
  }
)

(define-map global-rankings
  { rank-position: uint }
  { user: principal, score: uint }
)

(define-data-var total-ranked-users uint u0)

(define-private (calculate-reputation-score (wins uint) (total-votes uint) (participations uint))
  (+ (* wins u100) (* total-votes u5) participations)
)

(define-private (determine-rank-tier (score uint))
  (if (>= score u1000)
    "Legend"
    (if (>= score u500)
      "Master"
      (if (>= score u200)
        "Expert"
        (if (>= score u50)
          "Rising Star"
          "Beginner"
        )
      )
    )
  )
)

(define-private (update-user-reputation-on-vote (author principal))
  (let ((current-rep (default-to 
          { total-votes-received: u0, contests-participated: u0, 
            reputation-score: u0, rank-tier: "Beginner", last-score-update: u0 }
          (map-get? user-reputation { user: author })))
        (new-votes (+ (get total-votes-received current-rep) u1)))
    (map-set user-reputation
      { user: author }
      (merge current-rep 
        { total-votes-received: new-votes,
          last-score-update: stacks-block-height }))
    true
  )
)

(define-private (finalize-user-reputation (winner principal) (total-wins uint) (total-votes uint))
  (let ((current-rep (default-to 
          { total-votes-received: u0, contests-participated: u0, 
            reputation-score: u0, rank-tier: "Beginner", last-score-update: u0 }
          (map-get? user-reputation { user: winner })))
        (new-score (calculate-reputation-score total-wins total-votes (get contests-participated current-rep))))
    (map-set user-reputation
      { user: winner }
      { total-votes-received: total-votes,
        contests-participated: (+ (get contests-participated current-rep) u1),
        reputation-score: new-score,
        rank-tier: (determine-rank-tier new-score),
        last-score-update: stacks-block-height })
    true
  )
)

(define-read-only (get-user-reputation (user principal))
  (map-get? user-reputation { user: user })
)

(define-read-only (get-leaderboard-entry (rank-position uint))
  (map-get? global-rankings { rank-position: rank-position })
)

(define-read-only (get-top-users)
  (list 
    (map-get? global-rankings { rank-position: u1 })
    (map-get? global-rankings { rank-position: u2 })
    (map-get? global-rankings { rank-position: u3 })
    (map-get? global-rankings { rank-position: u4 })
    (map-get? global-rankings { rank-position: u5 })
  )
)