;; # ORG MODE Configuration
;; Setup the fonts for the org mode
(defun valsdav/org-font-setup ()
  ;;Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;;Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil    :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-table nil    :inherit 'fixed-pitch)
  (set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil     :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil    :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil  :inherit 'fixed-pitch)
  (set-face-attribute 'line-number nil :inherit 'fixed-pitch)
  (set-face-attribute 'line-number-current-line nil :inherit 'fixed-pitch)
  )



(defun valsdav/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :commands (org-capture org-agenda)
  :hook (org-mode . valsdav/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  ;(setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer 't)
  (setq org-startup-folded t)

  (setq org-hierarchical-todo-statistics nil)

  (setq org-agenda-files
        '("~/org/Inbox.org"
          "~/org/Clustering.org"
          "~/org/ttHbb.org"
          "~/org/CMS.org"
          "~/org/ETH.org"
          "~/org/Personal.org"
          "~/org/Reading.org"
          "~/org/People.org"
          "~/org/Mails.org"
          "~/org/Meetings.org"
          "~/org/Publications.org"
          ))

  ;; org-habit --> enable it later
  ;; (require 'org-habit)
  ;; (add-to-list 'org-modules 'org-habit)
  ;; (setq org-habit-graph-column 60)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "HOLD(h)" "|" "DONE(d)")
          (sequence "IDEA(i)" "PLAN(p)")
          (sequence "EMAIL(m)" "|" "SENT(s)")
          (sequence "MEETING(M)" "TALK(T)" "|" "DONE(d)")
          (sequence "WRITE" "WRITING" "REVIEW" "|"  "SUBMITTED")
          (sequence "READ(r)" "READING(i)" "|" "READ-DONE(d)")))

  ;; Refill targets
  (setq org-refile-targets
      '((nil :maxlevel . 3)
        (org-agenda-files :maxlevel . 3)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
      (:endgroup)
      ("personal" . ?p)
      ("cms" . ?C)
      ("ecal" . ?e)
      ("analysis" . ?a)
      ("ttHbb" . ?H)
      ("clustering" . ?c)
      ("code" . ?z)
      ("meeting" . ?m)
      ("log" . ?p)
      ("trigger" . ?t)
      ("ETHZ" . ?E)
      ("talk" . ?T)
      ("writing" . ?w)
      ("reading" . ?r)
      ("email" . ?l )
      ("student" . ?s)
      ("slides" . ?g)
      ("paper" . ?P)
     ))

  (setq org-clock-persist 'history)
  (org-clock-persistence-insinuate)

  (org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (shell . t)))


  
(setq org-agenda-custom-commands
      '(( "d" "Daily agenda"
          (
           (agenda "" ((org-agenda-span 1)
                      (org-deadline-warning-days 0)
                      (org-scheduled-past-days 0)
                      ;; We don't need the `org-agenda-date-today'
                      ;; highlight because that only has a practical
                      ;; utility in multi-day views.
                      (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                      (org-agenda-format-date "%A %-e %B %Y")
                      (org-agenda-overriding-header "Today's agenda")))
          
          (org-ql-block '(and (todo "NEXT")
                              (tags "@work"))
                         ((org-ql-block-header "Active Tasks\n")))

           (org-ql-block '(and (todo "HOLD")
                               (tags "@work")
                               )
                         ((org-ql-block-header "Tasks on HOLD\n")))

           (org-ql-block '(and (todo)
                               (tags "@work")
                               (not (tags "meeting"))
                               (scheduled :to today)
                               )
                         ((org-ql-block-header "Scheduled until today")))

           (org-ql-block '(and (todo)
                               (tags "@work")
                               (deadline auto)
                               )
                         ((org-ql-block-header "Deadlines in next 7 days")
                          (org-deadline-warning-days 7)))

           (org-ql-block '(  and (todo)
                             ;;(not (todo "HOLD"))
                             ;;(not (todo "NEXT"))
                             (tags "@work")
                             (not (todo "MEETING"))
                             (priority "A" "B")
                             )
                         ((org-ql-block-header "High priority tasks")
                          (org-agenda-sorting-strategy '(priority-down))))

           
           (org-ql-block '( and (todo)
                            (tags "meeting")
                            (ts :from today :to 7))
                         ((org-ql-block-header "Meetings in next 7 days")
                          (org-agenda-sorting-strategy '(timestamp-up))))
           
           (org-ql-block '(and (todo)
                               (tags "inbox")
                               )
                         ((org-ql-block-header "Inbox" )))

           (org-ql-block '(and (todo)
                               (tags "email")
                               )
                       ((org-ql-block-header "Mails" )))

                 
           (org-ql-block '(and (clocked :on today)
                               ;; (ts :on today)
                               (tags "@work")
                               )
                         ((org-ql-block-header "Clocked today")) )
           
           (org-ql-block '(and (closed)
                               (ts :on today)
                               (tags "@work")
                               )
                         ((org-ql-block-header "Closed today")) )
           ))
        ( "w" "Weekly review"
          (         
           (org-ql-block '(and (clocked :from -7 :to today)
                               (tags "@work")
                               )
                         ((org-ql-block-header "Clocked in the last 7 days")) )
           
           (org-ql-block '(and (closed)
                               (ts :from -7 :to today)
                               (tags "@work")
                               )
                         ((org-ql-block-header "Closed in the last 7 days")) )
           (org-ql-block '(and (todo "HOLD")
                               (tags "@work")
                               )
                         ((org-ql-block-header "Tasks on HOLD\n")))

           (org-ql-block '(and (todo)
                               (tags "@work")
                               (scheduled :to today)
                               )
                         ((org-ql-block-header "Scheduled until today")))

           (org-ql-block '(and (todo)
                               (tags "@work")
                               (deadline auto)
                               )
                         ((org-ql-block-header "Deadlines in next 14 days")
                          (org-deadline-warning-days 14)))

           (org-ql-block '(  and (todo)
                             ;;(not (todo "HOLD"))
                             ;;(not (todo "NEXT"))
                             (tags "@work")
                             (priority "A" "B")
                             )
                         ((org-ql-block-header "High priority tasks")
                          (org-agenda-sorting-strategy '(priority-down))))
           ))
        ))

  (setq org-capture-templates
     `(("t" "Tasks")
       
       ("tt" "Task to Inbox" entry (file+headline "~/org/Inbox.org" "Inbox") "* TODO %?")

       ("m" "Meetings")
       ("mo" "One-time meeting" entry (file+olp "~/org/Meetings.org" "Meetings" "One-time")
        "* MEETING %?\n %^T")
       ("mr" "Recurrent meeting" entry (file+olp "~/org/Meetings.org" "Meetings" "Recurrent")
        "* MEETING %?\n %^T")
       ("mg" "General meeting" entry (file+olp "~/org/Meetings.org", "Inbox")
        "* MEETING %?\n %^T")


       ("M", "Mail" entry (file+headline "~/org/Mails.org" "Inbox")  "* TODO %? %^G")

       ("c" "Chats")
       ("cc" "Chat" entry (file+olp "~/org/Meetings.org" "Chats")  "* TODO %?\n %^T")
       ("cs" "Chats with students")
       ("csm", "Matteo" plain (file+olp "~/org/Meetings.org", "Chats","Students","Chats with Matteo")
        "" :prepend t :clock-in t :immediate-finish t)

       ("n" "Notes to current clock")
       ("nn" "Plain note" item (clock) "- %?")
       ("nl" "Link to current file " item (clock) "- %a")
       ("nc" "Link to current file + comment" item (clock) "- %?\n  %a")

       ))

;  (define-key global-map (kbd "C-c j")
;    (lambda () (interactive) (org-capture nil "jj"))


  ;; (valsdav/org-font-setup)
  )


(use-package org-ql )

(use-package calfw)
(use-package calfw-org
  :config
  (setq cfw:org-agenda-schedule-args '(:timestamp)))
