;; Leather Working Certification Contract
;; Manages licenses for custom leather goods and repair services

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-INPUT (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-EXISTS (err u103))
(define-constant ERR-EXPIRED (err u104))

;; Data Variables
(define-data-var next-cert-id uint u1)
(define-data-var total-certifications uint u0)

;; Data Maps
(define-map certifications
  { cert-id: uint }
  {
    artisan: principal,
    workshop-name: (string-ascii 50),
    skill-level: uint,
    certification-block: uint,
    expiry-block: uint,
    is-active: bool,
    techniques: (list 10 (string-ascii 25)),
    completed-projects: uint
  }
)

(define-map artisan-certifications
  { artisan: principal }
  { cert-id: uint }
)

(define-map skill-assessments
  { cert-id: uint, assessment-id: uint }
  {
    assessor: principal,
    assessment-block: uint,
    skill-areas: (list 5 (string-ascii 30)),
    scores: (list 5 uint),
    overall-score: uint,
    notes: (string-ascii 200)
  }
)

(define-map project-completions
  { cert-id: uint, project-id: uint }
  {
    project-type: (string-ascii 30),
    completion-block: uint,
    quality-rating: uint,
    client-feedback: (string-ascii 100)
  }
)

;; Private Functions
(define-private (is-valid-skill-level (level uint))
  (and (>= level u1) (<= level u5))
)

(define-private (calculate-cert-expiry (issue-block uint))
  (+ issue-block u105120) ;; Add approximately 2 years in blocks
)

(define-private (calculate-overall-score (scores (list 5 uint)))
  (/ (fold + scores u0) (len scores))
)

;; Public Functions
(define-public (issue-certification (workshop-name (string-ascii 50)) (skill-level uint))
  (let
    (
      (cert-id (var-get next-cert-id))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len workshop-name) u0) ERR-INVALID-INPUT)
    (asserts! (is-valid-skill-level skill-level) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? artisan-certifications { artisan: tx-sender })) ERR-ALREADY-EXISTS)

    (map-set certifications
      { cert-id: cert-id }
      {
        artisan: tx-sender,
        workshop-name: workshop-name,
        skill-level: skill-level,
        certification-block: current-block,
        expiry-block: (calculate-cert-expiry current-block),
        is-active: true,
        techniques: (list),
        completed-projects: u0
      }
    )

    (map-set artisan-certifications
      { artisan: tx-sender }
      { cert-id: cert-id }
    )

    (var-set next-cert-id (+ cert-id u1))
    (var-set total-certifications (+ (var-get total-certifications) u1))

    (ok cert-id)
  )
)

(define-public (upgrade-skill-level (cert-id uint) (new-level uint))
  (let
    (
      (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-skill-level new-level) ERR-INVALID-INPUT)
    (asserts! (> new-level (get skill-level cert-data)) ERR-INVALID-INPUT)
    (asserts! (get is-active cert-data) ERR-INVALID-INPUT)

    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data { skill-level: new-level })
    )

    (ok true)
  )
)

(define-public (record-skill-assessment
  (cert-id uint)
  (assessment-id uint)
  (skill-areas (list 5 (string-ascii 30)))
  (scores (list 5 uint))
  (notes (string-ascii 200))
)
  (let
    (
      (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-NOT-FOUND))
      (current-block block-height)
      (overall-score (calculate-overall-score scores))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active cert-data) ERR-INVALID-INPUT)
    (asserts! (is-eq (len skill-areas) (len scores)) ERR-INVALID-INPUT)

    (map-set skill-assessments
      { cert-id: cert-id, assessment-id: assessment-id }
      {
        assessor: tx-sender,
        assessment-block: current-block,
        skill-areas: skill-areas,
        scores: scores,
        overall-score: overall-score,
        notes: notes
      }
    )

    (ok overall-score)
  )
)

(define-public (record-project-completion
  (cert-id uint)
  (project-id uint)
  (project-type (string-ascii 30))
  (quality-rating uint)
  (client-feedback (string-ascii 100))
)
  (let
    (
      (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-NOT-FOUND))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender (get artisan cert-data)) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active cert-data) ERR-INVALID-INPUT)
    (asserts! (and (>= quality-rating u1) (<= quality-rating u10)) ERR-INVALID-INPUT)

    (map-set project-completions
      { cert-id: cert-id, project-id: project-id }
      {
        project-type: project-type,
        completion-block: current-block,
        quality-rating: quality-rating,
        client-feedback: client-feedback
      }
    )

    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data { completed-projects: (+ (get completed-projects cert-data) u1) })
    )

    (ok true)
  )
)

(define-public (renew-certification (cert-id uint))
  (let
    (
      (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-NOT-FOUND))
      (current-block block-height)
    )
    (asserts! (is-eq tx-sender (get artisan cert-data)) ERR-NOT-AUTHORIZED)
    (asserts! (get is-active cert-data) ERR-INVALID-INPUT)

    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data { expiry-block: (calculate-cert-expiry current-block) })
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-certification (cert-id uint))
  (map-get? certifications { cert-id: cert-id })
)

(define-read-only (get-artisan-certification (artisan principal))
  (match (map-get? artisan-certifications { artisan: artisan })
    cert-info (map-get? certifications { cert-id: (get cert-id cert-info) })
    none
  )
)

(define-read-only (is-certification-valid (cert-id uint))
  (match (map-get? certifications { cert-id: cert-id })
    cert-data
      (let
        (
          (current-block block-height)
        )
        (and
          (get is-active cert-data)
          (> (get expiry-block cert-data) current-block)
        )
      )
    false
  )
)

(define-read-only (get-skill-assessment (cert-id uint) (assessment-id uint))
  (map-get? skill-assessments { cert-id: cert-id, assessment-id: assessment-id })
)

(define-read-only (get-project-completion (cert-id uint) (project-id uint))
  (map-get? project-completions { cert-id: cert-id, project-id: project-id })
)

(define-read-only (get-total-certifications)
  (var-get total-certifications)
)
