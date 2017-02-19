(deftemplate current_fact (slot fact) (slot cf))
(deftemplate current_goal (slot goal) (slot cf)) ;; the top-level
(deftemplate working_goal (slot goal) (slot cf)) ;;
;; store the final result
(deftemplate result
  (slot healthy)
  (slot at-risk)
  (slot diabetes-type-I)
  (slot diabetes-type-II)
  (slot gestational-diabetes)
  (slot more-consideration))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; load current diagnosis fact ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(deffacts load_facts
  (current_fact (fact healthy) (cf 0))
  (current_fact (fact at-risk) (cf 0))
  (current_fact (fact diabetes-type-I) (cf 0))
  (current_fact (fact diabetes-type-II) (cf 0))
  (current_fact (fact gestational-diabetes) (cf 0))
  (current_fact (fact more-consideration) (cf 0))

  (current_goal (goal healthy) (cf 0))
  (current_goal (goal at-risk) (cf 0))
  (current_goal (goal diabetes-type-I) (cf 0))
  (current_goal (goal diabetes-type-II) (cf 0))
  (current_goal (goal gestational-diabetes) (cf 0))
  (current_goal (goal more-consideration) (cf 0))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; initialise current goal when a new_goal is asserted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (defrule initialise-current-goal
;	(working_goal (goal ?ng) (cf ?cfng))
;	(not (current_goal (goal ?cg) (cf ?cfg)))
;	?newg <- (working_goal (goal ?ng) (cf ?cfng))
;=> 	(assert (current_goal (goal ?ng) (cf ?cfng)))
;	(retract ?newg)
;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CF combination for multiple conclusions RULES
;;; treat this as a black-box
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;combine POSITIVE certainty factors for multiple conclusions
;cf(cf1,cf2) = cf1 + cf2 * (1- cf1)

(defrule combine-positive-cf
  ?f1 <- (current_goal (goal ?g)(cf ?cf1&:(>= ?cf1 0)))
  ?f2 <- (working_goal (goal ?g)(cf ?cf2&:(>= ?cf2 0)))
  =>
  (retract ?f2)
  (modify ?f1 (cf =(+ ?cf1 (* ?cf2 (- 1 ?cf1)))))
)

;combine NEGATIVE cf
;cf(cf1,cf2) = cf1 + cf2 * (1 + cf1)

(defrule combine-neg-cf
 (declare (salience -1))
  ?f1 <- (current_goal   (goal ?g)(cf ?cf1&:(< ?cf1 0)))
  ?f2 <- (working_goal (goal ?g)(cf ?cf2&:(< ?cf2 0)))
  =>
  (retract ?f2)
  (modify ?f1 (cf =(+ ?cf1 (* ?cf2 (+ 1 ?cf1)))))
)

;combine one POSITIVE and one NEGATIVE
;cf(cf1,cf2) = (cf1 + cf2) / 1 - MIN[abs(cf1),abs(cf2)]

(defrule neg-pos-cf
 (declare (salience -1))
  ?f1 <- (current_goal (goal ?g) (cf ?cf1))
  ?f2 <- (working_goal (goal ?g) (cf ?cf2))
  (test (< (* ?cf1 ?cf2) 0))
  =>
  (retract ?f2)
  (modify ?f1 (cf =(/ (+ ?cf1 ?cf2) (- 1 (min (abs ?cf1) (abs ?cf2))))))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Question Triggering Rule
;;; to trigger the next question
;;; by replacing the current question with next question(working question)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; define question template
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate current_question (slot question) (slot desc) (slot option1) (slot option2) (slot option3) (slot option4))

(deftemplate working_question (slot question) (slot desc) (slot option1) (slot option2) (slot option3) (slot option4))

;;; triggering the next question
(defrule next_question
	(declare (salience 100))
	?cq <- (current_question (question ?q1) )
	?wq <- (working_question (question ?q2) (desc ?desc) (option1 ?option1) (option2 ?option2) (option3 ?option3) (option4 ?option4))
 =>
	(retract ?wq)
	(modify ?cq  (question ?q2) (desc ?desc) (option1 ?option1) (option2 ?option2) (option3 ?option3) (option4 ?option4))
	(printout t "triggering the next question" crlf)
)

(defglobal ?*age* = 0)

;;;******************************************************************************************
;;;* QUERY INFO *
;;;******************************************************************************************

(defrule collect-info-gender
  (declare (salience 10))
  (not (info-gender ?))
  (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
  =>
  (printout t crlf "What is your gender (Male(M)/Female(F))? ")
  (bind ?response (read))
  (if (or (eq ?response male) (eq ?response m))
      then
        (assert (info-gender male))
        (assert (info-pregnant no))
      else (assert (info-gender female))
    )
  )

(defrule collect-info-pregnant
  (declare (salience 10))
  (info-gender female)
  (not (info-pregnant ?))
  (current_fact (fact at-risk) (cf ?cf-risk))
  (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
  =>
  (printout t crlf "Are you pregnant (yes/no)? ")
	(bind ?response (read))
  (switch ?response
		(case yes then
				(assert (working_goal (goal at-risk) (cf (+ ?cf-risk 0.3))))
				(assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.3))))
        (assert (info-pregnant yes))
    )
		(case no then
        (assert (info-pregnant no))
    )
    (default (assert (info-pregnant no)))
	)
)

(defrule collect-info-age
  (declare (salience 10))
  (not (info-age ?))
  (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
  (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
  =>
  (printout t crlf "How old are you? ")
  (bind ?response (read))
  (bind ?*age* ?response)
  (if (and (>= ?response 20) (< ?response 40))
      then
      (assert (info-age-20 yes))
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.003))))
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.004))))
  )
  (if (>= ?response 40)
      then
      (assert (info-age yes))
      (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.009))))
      (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.01))))
      else
      (assert (info-age no))
  )
)

;;;******************************************************************************************
;;;* QUERY TEST RESULS *
;;;******************************************************************************************

(defrule collect-ogtt-pregnant
    (declare (salience 9))
    (not (test-ogtt ?))
    (info-pregnant yes)
    (current_fact (fact gestational-diabetes) (cf ?cf-gestational))
    (current_fact (fact healthy) (cf ?cf-healthy))
    =>
    (printout t crlf "How much is your blood glucose level (mmol/L) shown in 2-hours post Oral Glucose Tolerance test (OGTT) ? ")
    (bind ?response (float (read)))
    (if (numberp ?response)
        then
          (if (> ?response 7.7)
            then
            (assert (test-ogtt unhealthy))
            (assert (working_goal (goal gestational-diabetes) (cf (+ ?cf-gestational 0.7))))
            (assert (working_goal (goal healthy) (cf (* ?cf-healthy 0.1))))
            (printout t crlf "gestational")
            else
            (assert (test-ogtt healthy))
            (assert (working_goal (goal gestational-diabetes) (cf (- ?cf-gestational 0.7))))
            (assert (working_goal (goal healthy) (cf (+ ?cf-healthy 0.6))))
            (printout t crlf "gestational healthy")
          )
        else (assert (test-ogtt not-available))
        (printout t crlf "not a")
    )
)

(defrule collect-ogtt-non-pregnant
    (declare (salience 9))
    (not (test-ogtt ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    (printout t crlf "How much is your blood glucose level (mmol/L) shown in 2-hours post Oral Glucose Tolerance test (OGTT) ? ")
    (bind ?response (float (read)))
    (if (numberp ?response)
        then
          (if (< ?response 11.1)
            then (assert (test-ogtt healthy))
            else
            (assert (test-ogtt unhealthy))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
              (printout t "diabetes 1 +0.4")
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
            )
          )
        else (assert (test-ogtt not-available))
    )
)

(defrule collect-fpg
    (declare (salience 8))
    (not (test-fpg ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    (printout t crlf "How much is your blood glucose level (mmol/L) shown in Fasting Plasma Glucose test (FPG) ? ")
    (bind ?response (float (read)))
    (if (numberp ?response)
        then
          (if (< ?response 7.0)
            then (assert (test-fpg healthy))
            else
            (assert (test-fpg unhealthy))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
              (printout t "diabetes 1 +0.4")
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
            )
          )
        else (assert (test-fpg not-available))
    )
)

(defrule collect-cpg
    (declare (salience 7))
    (not (test-cpg ?))
    (info-pregnant no)
    (current_fact (fact diabetes-type-I) (cf ?cf-diabetes-I))
    (current_fact (fact diabetes-type-II) (cf ?cf-diabetes-II))
    =>
    (printout t crlf "How much is your blood glucose level (mmol/L) shown in Casual Plasma Glucose test (CPG) ? ")
    (bind ?response (float (read)))
    (if (numberp ?response)
        then
          (if (< ?response 11.1)
            then (assert (test-cpg healthy))
            else
            (assert (test-cpg unhealthy))
            (if (< ?*age* 20) then
              (assert (working_goal (goal diabetes-type-I) (cf (+ ?cf-diabetes-I 0.4))))
              (printout t "diabetes 1 +0.4")
              else
              (assert (working_goal (goal diabetes-type-II) (cf (+ ?cf-diabetes-II 0.4))))
            )
          )
        else (assert (test-cpg not-available))
    )
)


;;;******************************************************************************************
;;;* QUERY SYMPTOMS *
;;;******************************************************************************************


;;;******************************************************************************************
;;;* RESULTS *
;;;******************************************************************************************

(defrule compile_results
	(declare (salience -10))
	(current_goal (goal healthy) (cf ?cf-healthy))
	(current_goal (goal at-risk) (cf ?cf-risk))
	(current_goal (goal diabetes-type-I) (cf ?cf-diabetes-I))
	(current_goal (goal diabetes-type-II) (cf ?cf-diabetes-II))
	(current_goal (goal gestational-diabetes) (cf ?cf-gestational))
  (current_goal (goal more-consideration) (cf ?cf-consideration))
=>
  (assert (result
        (healthy ?cf-healthy) (at-risk ?cf-risk) (diabetes-type-I ?cf-diabetes-I)
        (diabetes-type-II ?cf-diabetes-II) (gestational-diabetes ?cf-gestational)
        (more-consideration ?cf-consideration)
      )
  )
	(printout t crlf "Diabetes Diagnosis result :")
	(printout t crlf "Healthy: " (float (* ?cf-healthy 100)) "%")
	(printout t crlf "At Risk   : " (float (* ?cf-risk 100)) "%")
	(printout t crlf "Diabetes I   : " (float (* ?cf-diabetes-I 100)) "%")
	(printout t crlf "Diabetes II    : " (float (* ?cf-diabetes-II 100)) "%")
  (printout t crlf "Gestational diabetes    : " (float (* ?cf-gestational 100)) "%")
	(printout t crlf "Further medial consulation    : " (float (* ?cf-consideration 100)) "%" crlf)
)
