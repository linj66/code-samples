
#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; put your code below

; #1: sequence
(define (sequence spacing low high)
  (if (> low high)
      null
      (cons low (sequence spacing (+ spacing low) high))))
      
; #2 string-append-map
(define (string-append-map xs suffix)
  (map (lambda (x)
         (string-append x suffix)) xs))

; #3 list-nth-mod
(define (list-nth-mod xs n)
  (cond
    [(< n 0) (error  "list-nth-mod: negative number")]
    [(null? xs) (error "list-nth-mod: empty list")]
    [#t (let ([i (remainder n (length xs))])
          (car (list-tail xs i)))]))

; #4 stream-for-k-steps
(define (stream-for-k-steps s k)
  (if (= 0 k)
      null
      (cons (car (s)) (stream-for-k-steps (cdr (s)) (- k 1)))))

; #5 funny-number-stream
;(define (f x) (cons (if (= 0 (remainder x 6)) (* x -1) x) (lambda () (f (+ x 1)))))
(define funny-number-stream
  (letrec ([f (lambda (x) (cons (if (= 0 (remainder x 6))
                                    (* x -1)
                                    x)
                                (lambda () (f (+ x 1)))))])
  (lambda () (f 1))))

; #6 dan-then-dog
(define dan-then-dog
  (letrec ([dog-then-dan (lambda () (cons "dog.jpg" dan-then-dog))])
    (lambda () (cons "dan.jpg" dog-then-dan))))

; #7 stream-add-one
  ; a stream is a thunk returning pair: '(next-answer, next-thunk)
  ; we want '('(1, next-answer) next-thunk)

(define (stream-add-one s)
  (letrec ([f (lambda (stream) (cons (cons 1 (car (stream))) (lambda () (f (cdr (stream))))))])
    (lambda () (f s))))

; #8 cycle-lists
(define (cycle-lists xs ys)
  (letrec ([f (lambda (n) (cons (cons (list-nth-mod xs n) (list-nth-mod ys n)) (lambda () (f (+ n 1)))))])
    (lambda () (f 0))))

; #9 vector-assoc
(define (vector-assoc v vec)
  ; takes a value and a vector of stuff
  ; if element of vector is not a pair, skip
  ; else see if value = car of pair
  (letrec ([f (lambda (n)
                (if
                 (= n (vector-length vec))
                 #f
                 (let ([current (vector-ref vec n)])
                   (if (pair? current)
                     (if (equal? (car current) v)
                         current
                         (f (+ n 1)))
                     (f (+ n 1))))))])
    (f 0)))

; #10 caching-assoc
(define (caching-assoc xs n)
  (letrec ([memo (make-vector n #f)]
           [memo-pos 0]
           [f (lambda (v)
                (let ([val-memo (vector-assoc v memo)])
                  (if val-memo
                      ; case is in memo
                      val-memo
                      ; case not in memo
                      (let ([val-xs (assoc v xs)])
                        (if val-xs
                            ; if v in xs
                            (begin
                              (vector-set! memo memo-pos val-xs)
                              (set! memo-pos (remainder (+ memo-pos 1) n))
                              val-xs)
                            ; if v not in xs
                            val-xs)))))])
    f))

; #11 while-greater
(define-syntax while-greater
  (syntax-rules (do)
    [(while-greater e1 do e2)
     (letrec ([x1 e1]
              [f (lambda (x2) (if (<= x2 x1) #t (f e2)))])
       (f e2))]))