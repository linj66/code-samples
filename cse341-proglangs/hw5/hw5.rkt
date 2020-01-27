;; CSE341, Programming Languages, Homework 5

#lang racket
(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct isgreater (e1 e2)    #:transparent) ;; if e1 > e2 then 1 else 0
(struct ifnz (e1 e2 e3) #:transparent) ;; if not zero e1 then e2 else e3
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair   (e1 e2) #:transparent) ;; make a new pair
(struct first   (e)     #:transparent) ;; get first part of a pair
(struct second  (e)     #:transparent) ;; get second part of a pair
(struct munit   ()      #:transparent) ;; unit value -- good for ending a list
(struct ismunit (e)     #:transparent) ;; if e1 is unit then 1 else 0

;; a closure is not in "source" programs; it is what functions evaluate to
(struct closure (env fun) #:transparent) 

;; Problem 1

;; CHANGE (put your solutions here)

; 1a: racketlist->mupllist
(define (racketlist->mupllist xs)
  (if (null? xs)
      (munit)
      (if (list? (car xs))
          (apair (racketlist->mupllist (car xs)) (racketlist->mupllist (cdr xs)))
          (apair (car xs) (racketlist->mupllist (cdr xs))))))

; 1b: mupllist->racketlist
(define (mupllist->racketlist xs)
  (if (munit? xs)
      null
      (cons (apair-e1 xs) (mupllist->racketlist (apair-e2 xs)))))
      

;; Problem 2

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(var? e) 
         (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
        ;; CHANGE add more cases here

        ; int
        [(int? e) e]

        ; isgreater
        [(isgreater? e)
         (let ([v1 (eval-under-env (isgreater-e1 e) env)]
               [v2 (eval-under-env (isgreater-e2 e) env)])
           (if (and (int? v1) (int? v2))
               (if (> (int-num v1) (int-num v2))
                   (int 1)
                   (int 0))
               (int 0)))]

        ; ifnz
        [(ifnz? e)
         (let ([v1 (eval-under-env (ifnz-e1 e) env)])
           (if (int? v1)
               (if (= 0 (int-num v1))
                   (eval-under-env (ifnz-e3 e) env)
                   (eval-under-env (ifnz-e2 e) env))
               (eval-under-env (ifnz-e3 e) env)))]

        ; apair
        [(apair? e) (apair (eval-under-env (apair-e1 e) env) (eval-under-env (apair-e2 e) env))]

        ; first
        [(first? e)
         (let ([exp (eval-under-env (first-e e) env)])
           (if (apair? exp)
               (apair-e1 exp)
               (error (format "not a pair" e))))]

        ; second
        [(second? e)
         (let ([exp (eval-under-env (second-e e) env)])
           (if (apair? exp)
               (apair-e2 exp)
               (error (format "not a pair" e))))]

        ; munit
        [(munit? e) e]

        ; ismunit
        [(ismunit? e) (if (munit? (eval-under-env (ismunit-e e) env)) (int 1) (int 0))]

        ; mlet
        [(mlet? e)
         (let* ([v1 (eval-under-env (mlet-e e) env)]
                [temp-env (append (list (cons (mlet-var e) v1)) env)])
           (eval-under-env (mlet-body e) temp-env))]

        ; fun
        [(fun? e) (closure env e)]

        ; closure
        [(closure? e) e]

        ; call
        [(call? e)
         (let ([v1 (eval-under-env (call-funexp e) env)])
           (if (closure? v1) ; if the first value a closure
               (let* ([f (closure-fun v1)] ; get function
                      [clo-env (closure-env v1)] ; get current closure env
                      [clo-env (if (fun-nameopt f)
                                   (cons (cons (fun-nameopt f) v1) clo-env)
                                   clo-env)] ; update current env to have f and f's closure if fun-nameopt not null
                      [eval-param (eval-under-env (call-actual e) env)] ; eval param of call in original env
                      [clo-env (cons (cons (fun-formal (closure-fun v1)) eval-param) clo-env)]) ; update current env with fun param name . eval param
                 (eval-under-env (fun-body f) clo-env)) ; evaluate body of function in closure in final closure env
               (error (format "not a closure"))))] ; if first value is not a closure, throw error
        [#t (error (format "bad MUPL expression: ~v" e))]))

;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))

;; Problem 3

; ifmunit
(define (ifmunit e1 e2 e3) (ifnz (isgreater (ismunit e1) (int 0)) e2 e3))

; mlet*
(define (mlet* bs e2)
  (if (null? bs)
      e2
      (mlet (caar bs) (cdar bs) (mlet* (cdr bs) e2))))

; ifeq
(define (ifeq e1 e2 e3 e4)
  (let ([_x (eval-exp e1)]
        [_y (eval-exp e2)])
    (if (and (int? _x) (int? _y))
        (if (= (int-num _x) (int-num _y))
            (eval-exp e3)
            (eval-exp e4))
        (error (format "e1 and e2 are not both ints")))))
        

;; Problem 4

(define mupl-filter
  (fun "fn" "fn-param"
       (fun "apply" "xs"
            (ifmunit (var "xs")
                     (munit)
                     (ifnz (call (var "fn-param") (first (var "xs")))
                           (apair (first (var "xs")) (call (var "apply") (second (var "xs"))))
                           (call (var "apply") (second (var "xs"))))))))

(define mupl-all-gt
  (mlet "filter" mupl-filter
        ; a mupl function f that takes an mupl integer i and
        (fun "f" "i"
             ; returns a mupl function g that takes a mupl list of mupl integers xs and returns
             (fun "g" "xs"
                  ;  and returns a new mupl list of mupl integers containing the elements of the input list (in order) that are greater than i
                  (call (call (var "filter") (fun "h" "x" (isgreater (var "x") (var "i")))) (var "xs"))))))

;; Challenge Problem

(struct fun-challenge (nameopt formal body freevars) #:transparent) ;; a recursive(?) 1-argument function

;; We will test this function directly, so it must do
;; as described in the assignment
(define (compute-free-vars e) "CHANGE")

;; Do NOT share code with eval-under-env because that will make grading
;; more difficult, so copy most of your interpreter here and make minor changes
(define (eval-under-env-c e env) "CHANGE")

;; Do NOT change this
(define (eval-exp-c e)
  (eval-under-env-c (compute-free-vars e) null))
